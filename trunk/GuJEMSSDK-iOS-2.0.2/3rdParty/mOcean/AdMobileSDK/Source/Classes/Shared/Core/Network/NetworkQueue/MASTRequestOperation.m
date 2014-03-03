// Operation.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MASTRequestOperation.h"
#import "MASTMessages.h"

static NSUInteger const kMinimumInitialDataCapacity = 1024;
static NSUInteger const kMaximumInitialDataCapacity = 1024 * 1024 * 8;

typedef enum {
    OperationReadyState       = 1,
    OperationExecutingState   = 2,
    OperationFinishedState    = 3,
    OperationCancelledState   = 4,
} OperationState;

NSString * const NetworkingErrorDomain = @"com.alamofire.networking.error";

NSString * const OperationDidStartNotification = @"com.alamofire.networking.http-operation.start";
NSString * const OperationDidFinishNotification = @"com.alamofire.networking.http-operation.finish";

typedef void (^RequestOperationProgressBlock)(NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected);
typedef void (^RequestOperationCompletionBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error);

static inline NSString * KeyPathFromOperationState(OperationState state) {
    switch (state) {
        case OperationReadyState:
            return @"isReady";
        case OperationExecutingState:
            return @"isExecuting";
        case OperationFinishedState:
            return @"isFinished";
        default:
            return @"state";
    }
}

static inline BOOL OperationStateTransitionIsValid(OperationState from, OperationState to) {
    switch (from) {
        case OperationReadyState:
            switch (to) {
                case OperationExecutingState:
                    return YES;
                default:
                    return NO;
            }
        case OperationExecutingState:
            switch (to) {
                case OperationReadyState:
                    return NO;
                default:
                    return YES;
            }
        case OperationFinishedState:
            return NO;
        default:
            return YES;
    }
}

@interface MASTRequestOperation ()
@property (readwrite, nonatomic, assign) OperationState state;
@property (readwrite, nonatomic, assign, getter = isCancelled) BOOL cancelled;
@property (readwrite, nonatomic, retain) NSURLConnection *connection;
@property (readwrite, nonatomic, retain) NSURLRequest *request;
@property (readwrite, nonatomic, retain) NSHTTPURLResponse *response;
@property (readwrite, nonatomic, retain) NSError *error;
@property (readwrite, nonatomic, retain) NSData *responseBody;
@property (readwrite, nonatomic, assign) NSInteger totalBytesRead;
@property (readwrite, nonatomic, retain) NSMutableData *dataAccumulator;
@property (readwrite, nonatomic, retain) NSOutputStream *outputStream;
@property (readwrite, nonatomic, copy) RequestOperationProgressBlock uploadProgress;
@property (readwrite, nonatomic, copy) RequestOperationProgressBlock downloadProgress;
@property (readwrite, nonatomic, copy) RequestOperationCompletionBlock completion;

- (void)operationDidStart;
- (void)finish;
@end

@implementation MASTRequestOperation
@synthesize state = _state;
@synthesize cancelled = _cancelled;
@synthesize connection = _connection;
@synthesize runLoopModes = _runLoopModes;
@synthesize request = _request;
@synthesize response = _response;
@synthesize error = _error;
@synthesize connectionDelegate;
@synthesize responseBody = _responseBody;
@synthesize totalBytesRead = _totalBytesRead;
@synthesize dataAccumulator = _dataAccumulator;
@synthesize outputStream = _outputStream;
@synthesize uploadProgress = _uploadProgress;
@synthesize downloadProgress = _downloadProgress;
@synthesize completion = _completion;

static NSThread *_networkRequestThread = nil;

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while (YES);
}

+ (NSThread *)networkRequestThread {
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
        
    return _networkRequestThread;
}

+ (MASTRequestOperation *)operationWithRequest:(NSURLRequest *)urlRequest 
                completion:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error))completion
{
    MASTRequestOperation *operation = [[[self alloc] init] autorelease];
    operation.request = urlRequest;
    operation.completion = completion;
    
    return operation;
}

+ (MASTRequestOperation *)streamingOperationWithRequest:(NSURLRequest *)urlRequest
                                              inputStream:(NSInputStream *)inputStream
                                             outputStream:(NSOutputStream *)outputStream
                                               completion:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))completion
{
    NSMutableURLRequest *mutableURLRequest = [[urlRequest mutableCopy] autorelease];
    if (inputStream) {
        [mutableURLRequest setHTTPBodyStream:inputStream];
        if ([[mutableURLRequest HTTPMethod] isEqualToString:@"GET"]) {
            [mutableURLRequest setHTTPMethod:@"POST"];
        }
    }

    MASTRequestOperation *operation = [self operationWithRequest:mutableURLRequest completion:^(NSURLRequest *request, NSHTTPURLResponse *response, __unused NSData *data, NSError *error) {
        if (completion) {
            completion(request, response, error);
        }
    }];
    
    operation.outputStream = outputStream;
    
    return operation;
}

- (id)init {
    self = [super init];
    if (!self) {
		return nil;
    }
    	
    self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    
    self.state = OperationReadyState;
	
    return self;
}

- (void)dealloc {
    self.connectionDelegate = nil;
    
    [_runLoopModes release];
    
    [_request release];
    [_response release];
    [_responseBody release];
    [_dataAccumulator release];
    [_outputStream release]; _outputStream = nil;
    
    [_connection release]; _connection = nil;
    [_error release]; _error = nil;
	
    [_uploadProgress release];
    [_downloadProgress release];
    [_completion release];
    [super dealloc];
}

- (void)setUploadProgressBlock:(void (^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))block {
    self.uploadProgress = block;
}

- (void)setDownloadProgressBlock:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))block {
    self.downloadProgress = block;
}

- (void)setState:(OperationState)state {
    if (self.state == state) {
        return;
    }
    
    if (!OperationStateTransitionIsValid(self.state, state)) {
        return;
    }
    
    NSString *oldStateKey = KeyPathFromOperationState(self.state);
    NSString *newStateKey = KeyPathFromOperationState(state);
    
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    
    switch (state) {
        case OperationExecutingState:
            [[NSNotificationCenter defaultCenter] postNotificationName:OperationDidStartNotification object:self];
            break;
        case OperationFinishedState:
            [[NSNotificationCenter defaultCenter] postNotificationName:OperationDidFinishNotification object:self];
            break;
        default:
            break;
    }
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"isCancelled"];
    
    if ([self isCancelled]) {
        self.state = OperationFinishedState;
    }
}

- (NSString *)responseString {
    if (!self.response || !self.responseBody) {
        return nil;
    }
    
    NSStringEncoding textEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)self.response.textEncodingName));
    
    return [[[NSString alloc] initWithData:self.responseBody encoding:textEncoding] autorelease];
}

#pragma mark - NSOperation

- (BOOL)isReady {
    return self.state == OperationReadyState;
}

- (BOOL)isExecuting {
    return self.state == OperationExecutingState;
}

- (BOOL)isFinished {
    return self.state == OperationFinishedState;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    if (![self isReady]) {
        return;
    }
        
    self.state = OperationExecutingState;

    [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:YES modes:[self.runLoopModes allObjects]];
}

- (void)operationDidStart {
    self.connection = [[[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO] autorelease];
    
    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    for (NSString *runLoopMode in self.runLoopModes) {
        [self.connection scheduleInRunLoop:runLoop forMode:runLoopMode];
        [self.outputStream scheduleInRunLoop:runLoop forMode:runLoopMode];
    }
    
    [self.connection start];
}

- (void)cancel {
    if ([self isFinished]) {
        return;
    }
    
    [super cancel];
    
    self.cancelled = YES;
    
    [self.connection cancel];
}

- (void)finish {
    self.state = OperationFinishedState;
    
    if ([self isCancelled]) {
        return;
    }
    
    if (self.completion) {
        //@autoreleasepool {
            self.completion(self.request, self.response, self.responseBody, self.error);
        //}
    }
}

#pragma mark - NSURLConnection

- (void)connection:(NSURLConnection *)__unused connection 
didReceiveResponse:(NSURLResponse *)response 
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]] == NO) {
        return;
    }

    self.response = (NSHTTPURLResponse *)response;
    
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [connectionDelegate connection:connection didReceiveResponse:response];
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] == 204) {
        self.error = [NSError errorWithDomain:kErrorNoContentMessage code:777 userInfo:nil];
    } else if ([httpResponse statusCode] != 200) {
        self.error = [NSError errorWithDomain:kErrorServerResponseMessage code:[httpResponse statusCode] userInfo:nil];
    }
    
    if (self.outputStream) {
        [self.outputStream open];
    } else {
        NSUInteger maxCapacity = MAX((NSUInteger)llabs(response.expectedContentLength), kMinimumInitialDataCapacity);
        NSUInteger capacity = MIN(maxCapacity, kMaximumInitialDataCapacity);
        self.dataAccumulator = [NSMutableData dataWithCapacity:capacity];
    }
}

- (void)connection:(NSURLConnection *)__unused connection 
    didReceiveData:(NSData *)data 
{
    self.totalBytesRead += [data length];
    
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [connectionDelegate connection:connection didReceiveData:data];
    }
    
    if (self.outputStream) {
        if ([self.outputStream hasSpaceAvailable]) {
            const uint8_t *dataBuffer = [data bytes];
            [self.outputStream write:&dataBuffer[0] maxLength:[data length]];
        }
    } else {
        [self.dataAccumulator appendData:data];
    }
    
    if (self.downloadProgress) {
        self.downloadProgress([data length], self.totalBytesRead, (NSInteger)self.response.expectedContentLength);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)__unused connection {    
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [connectionDelegate connectionDidFinishLoading:connection];
    }
    
    if (self.outputStream) {
        [self.outputStream close];
    } else {
        self.responseBody = [NSData dataWithData:self.dataAccumulator];
        [_dataAccumulator release]; _dataAccumulator = nil;
    }

    [self finish];
}

- (void)connection:(NSURLConnection *)__unused connection 
  didFailWithError:(NSError *)error 
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [connectionDelegate connection:connection didFailWithError:error];
    }     
    
    self.error = error;
    
    if (self.outputStream) {
        [self.outputStream close];
    } else {
        [_dataAccumulator release]; _dataAccumulator = nil;
    }
    
    [self finish];
}

- (void)connection:(NSURLConnection *)__unused connection 
   didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten 
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [connectionDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
    
    if (self.uploadProgress) {
        self.uploadProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)__unused connection 
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse 
{
    if (connectionDelegate && [connectionDelegate respondsToSelector:@selector(connection:willCacheResponse:)]) {
        [connectionDelegate connection:connection willCacheResponse:cachedResponse];
    }
    
    if ([self isCancelled]) {
        return nil;
    }
    
    return cachedResponse;
}

@end
