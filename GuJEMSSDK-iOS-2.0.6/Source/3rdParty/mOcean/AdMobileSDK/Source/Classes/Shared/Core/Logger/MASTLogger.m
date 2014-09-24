//
//  Logger.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 8/19/10.
//

#import "MASTLogger.h"
#import "MASTMessages.h"
#import "GTMNSString+HTML.h"

@interface MASTLogger()

- (void)registerObserver;

- (void)printNotification:(NSNotification*)notification;
- (void)enableLogForAd:(MASTAdView*)adView withLevel:(AdLogMode)logMode;
- (void)disableLogForAd:(MASTAdView*)adView;
- (BOOL)isLogEnabled:(MASTAdView*)adView forLevel:(AdLogMode)level;
- (void)printLogInFileWithMessage:(NSString*)message;

+ (void)showAlertWithMessage:(NSString*)message;
+ (void)printLogWithMessage:(NSString*)message;

+ (void)logWithString:(NSString*)message;
+ (void)logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

+ (void)logUsingAlertWithString:(NSString*)message;
+ (void)logUsingAlertWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end


@implementation MASTLogger

static MASTLogger* sharedInstance = nil;


#pragma mark -
#pragma mark Singleton


- (id) init {
    self =[super init];
    
	if (self) {
        _ads = [NSMutableDictionary new];
        _allLogAds = [NSMutableArray new];
        [self registerObserver];
	}
	
	return self;
}

+ (id)sharedInstance {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [[self alloc] init];
		}
	}
	return sharedInstance;
}

- (oneway void)superRelease {
    [_ads release];
	[super release];
}

+ (void)releaseSharedInstance {
	@synchronized(self) {
		[sharedInstance superRelease];
		sharedInstance = nil;
	}
}

+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if (nil == sharedInstance) {
			sharedInstance = [super allocWithZone:zone];
		}
	}
	
	return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
	return sharedInstance;
}

- (id)retain {
	return sharedInstance;
}

- (unsigned)retainCount {
	return NSUIntegerMax;
}

- (oneway void)release {
	// Do nothing.
}

- (id)autorelease {
	return sharedInstance;
}


#pragma mark -
#pragma mark Public


- (void)registerObserver {
	[[MASTNotificationCenter sharedInstance] addObserver:self selector:@selector(printNotification:) name:nil object:nil];
}

+ (void) logWithString:(NSString*)message
{
	[MASTLogger printLogWithMessage:message];
}

+ (void) logWithFormat:(NSString*)format, ...
{
	va_list args;
	va_start(args, format);
	NSString* message = [MASTLogBasicFormatter stringWithFormat:format valist:args];
	va_end(args);
	
	[MASTLogger logWithString:message];
}

+ (void) logUsingAlertWithString:(NSString*)message
{
	[MASTLogger printLogWithMessage:message];
	[MASTLogger showAlertWithMessage:message];
}


+ (void) logUsingAlertWithFormat:(NSString*)format, ...
{
	va_list args;
	va_start(args, format);
	NSString* message = [MASTLogBasicFormatter stringWithFormat:format valist:args];
	va_end(args);
	[MASTLogger logUsingAlertWithString:message];
}


#pragma mark -
#pragma mark Private


- (void)enableLogForAd:(MASTAdView*)adView withLevel:(AdLogMode)logMode {
    NSString* adPtr = [adView uid];
    @synchronized(_ads) {
        if (logMode == AdLogModeAll) {
            [_allLogAds addObject:adPtr];
        }
        
        [_ads setObject:[NSNumber numberWithInt:logMode] forKey:adPtr];
    }
}

- (void)disableLogForAd:(MASTAdView*)adView {
    NSString* adPtr = [adView uid];
    
    @synchronized(_ads) {
        if ([_allLogAds containsObject:adPtr]) {
            [_allLogAds removeObject:adPtr];
        }
        
        [_ads removeObjectForKey:adPtr];
    }
}

- (BOOL)isLogEnabled:(MASTAdView*)adView forLevel:(AdLogMode)level {
    NSString* adPtr = [NSString stringWithFormat:@"%ld", adView];
    
    @synchronized(_ads) {
        for (NSString* ptr in _ads) {
            if ([ptr isEqualToString:adPtr]) {
                NSNumber* num = [_ads objectForKey:ptr];
                AdLogMode logMode = (AdLogMode)[num intValue];
                if (logMode == level) {
                    return YES;
                } else if (logMode == AdLogModeAll) {
                    return YES;
                }  else {
                    return NO;
                }
            }
        }
    }
    
    return NO;
}

- (void)printNotification:(NSNotification*)notification {    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if ([[notification name] isEqualToString:kAdStartLoggingAllNotification]) {
            NSObject* obj = [notification object];
            MASTAdView* adView = (MASTAdView*)obj;
            [self enableLogForAd:adView withLevel:AdLogModeAll];
        } else if ([[notification name] isEqualToString:kAdStartLoggingErrorsNotification]) {
            NSObject* obj = [notification object];
            MASTAdView* adView = (MASTAdView*)obj;
            [self enableLogForAd:adView withLevel:AdLogModeErrorsOnly];
        } else if ([[notification name] isEqualToString:kAdStopLoggingNotification]) {
            NSObject* obj = [notification object];
            MASTAdView* adView = (MASTAdView*)obj;
            [self disableLogForAd:adView];
        } else if ([_ads count] > 0) {
            NSObject* obj = [notification object];
            
            if ([obj isKindOfClass:[MASTAdView class]]) {
                MASTAdView* adView = (MASTAdView*)obj;
                
                if ([self isLogEnabled:adView forLevel:AdLogModeAll]) {
                    if ([[notification name] isEqualToString:kStartAdDownloadNotification]) {
                        NSString* url = [[adView adModel] urlIgnoreValifation];
                        [MASTLogger logWithFormat:@" ad(%ld) - %@ | url: %@", adView, [notification name], url];
                    } else {
                        [MASTLogger logWithFormat:@" ad(%ld) - %@", adView, [notification name]];
                    }
                }
            } else if ([obj isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dic = (NSDictionary*)obj;
                MASTAdView* adView = [dic objectForKey:@"adView"];
                NSError* error = [dic objectForKey:@"error"];
                
                if ([self isLogEnabled:adView forLevel:AdLogModeErrorsOnly]) {
                    if ([adView isKindOfClass:[MASTAdView class]] && [error isKindOfClass:[NSError class]]) {
                        [MASTLogger logWithFormat:@" ad(%ld) - %@ | error: %@", adView, [notification name], [error description]];
                    } else if ([self isLogEnabled:adView forLevel:AdLogModeAll]) {
                        if ([adView isKindOfClass:[MASTAdView class]]) {
                            [MASTLogger logWithFormat:@" ad(%ld) - %@", adView, [notification name]];
                        }
                        else {
                            [MASTLogger logWithFormat:@" - %@", [notification name]];
                        }
                    }
                }
            } else if ([obj respondsToSelector:@selector(description)]) {
                [MASTLogger logWithFormat:@" - %@ - %@", [notification name], [obj description]];
            } else if ([_allLogAds count] > 0) {
                [MASTLogger logWithFormat:@" - %@", [notification name]];
            }
        }
   //});
}

- (void)printLogInFileWithMessage:(NSString*)message {    
    NSString* dirPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    NSString* path = [dirPath stringByAppendingPathComponent:@"mOcean_SDK_log.txt"];
    
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy.MM.dd hh:mm:ss"];
    
    NSString *newMessage = [NSString stringWithFormat:[NSString stringWithFormat:@"%@ :: Ad %@\n", [dateFormatter stringFromDate:[NSDate date]], message]];
    
    // convert the string to an NSData object
    NSData *textData = [newMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:textData attributes:nil];
    } else {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        
        // move to the end of the file
        [fileHandle seekToEndOfFile];
		
        // write the data to the end of the file
        [fileHandle writeData:textData];
		
        // clean up
        [fileHandle closeFile];
    }
}

+ (void)showAlertWithMessage:(NSString*)message
{
	if (TARGET_IPHONE_SIMULATOR) {
		if (message && [message length] > 0) {
			NSString* debugMessage = [[NSString alloc] initWithFormat:@":: Ad %@\n%@", kLoggerWarningMessage, message];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:debugMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
			[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES]; 
			[alert release];
			
			[debugMessage release];
		}
	}
}

+ (void) printLogWithMessage:(NSString*)message
{
	if (message && [message length] > 0) {
		NSLog(@":: Ad %@", message);
        
        [sharedInstance printLogInFileWithMessage:message];
	}
}

@end
