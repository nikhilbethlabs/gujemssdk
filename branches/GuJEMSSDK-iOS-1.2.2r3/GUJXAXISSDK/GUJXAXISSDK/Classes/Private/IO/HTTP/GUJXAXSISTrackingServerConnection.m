/*
 * BSD LICENSE
 * Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, 
 * this list of conditions and the following disclaimer .
 * Redistributions in binary form must reproduce the above copyright notice, 
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The source code is just allowed for private use, not for commercial use.
 * 
 */
#import "GUJXAXSISTrackingServerConnection.h"

@implementation GUJXAXSISTrackingServerConnection

static GUJXAXSISTrackingServerConnection *instance;

- (NSString*)__formattedDateForReporting
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:kGUJURLParameterFormateForReportingTimeStamp];    
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (GUJServerConnection*)instance
{
    return [GUJXAXSISTrackingServerConnection instanceWithDelegate:nil];
}

+ (GUJXAXSISTrackingServerConnection*)instanceWithDelegate:(id<GUJAdViewDelegate>)delegate
{
    if( instance == nil ) {
        instance = [[self alloc] init];
    }
    if( delegate != nil ) {
        instance->delegate_ = delegate;
    }
    @synchronized(instance) {    
        return instance;
    }
}

- (void)sendAdServerRequest
{
    [GUJServerConnection instance].error = [GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_UNAVAILABLE withUserInfo:nil];
}

- (void)sendAdServerRequestWithReportingAdSpaceId:(NSString*)reportingAdSpaceId placementId:(NSString*)placementId
{
    super.error = nil;
    @autoreleasepool {
        NSHTTPURLResponse   *response   = nil;
        NSError             *error      = nil;   
        
        GUJAdURL *reportingURL = [GUJAdURL URLForType:[[GUJAdConfiguration sharedInstance] bannerType]];
        [reportingURL addParameter:kGUJURLParameterSmartStreamPlacementId value:placementId];
        [reportingURL addParameter:kGUJURLParameterSmartStreamReportTimeStamp value:[self __formattedDateForReporting]];        
        [reportingURL replaceParameter:kGUJURLParameterAdSpace value:reportingAdSpaceId];
        super.url =  reportingURL;
        
        super.request = [NSMutableURLRequest requestWithURL:super.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kGUJServerConnectionTimeout];
        [super.request setValue:[GUJUtil formattedHttpUserAgentString] forHTTPHeaderField:kGUJServerConnectionHTTPHeaderFieldKeyForUserAgent];
        [super.request setValue:[GUJUtil md5HashedApplicationAdSpaceUUID] forHTTPHeaderField:kGUJServerConnectionHTTPHeaderFieldKeyForUserId];
        
        _logd_tm(self, @"sendAdServerRequest URL:",[super.url description],nil);
        _logd_tm(self, kGUJServerConnectionHTTPHeaderFieldKeyForUserAgent,[GUJUtil formattedHttpUserAgentString],nil);
        _logd_tm(self, @"requestHeader",   [super.request allHTTPHeaderFields],nil);
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:super.request returningResponse:&response error:&error];  
        
        super.adData = [GUJAdData dataWithData:resultData];
        resultData = nil;
        
        if( error != nil ) {
            [GUJServerConnection instance].error = [GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_SERVER_ERROR withUserInfo:[error userInfo]];
            [[GUJNativeErrorObserver sharedInstance] distributeError:error];
        }
        
        @autoreleasepool {
            if( response != nil ) {
                super.response = [response copy];
                if( super.response.statusCode == 200 ) {
                    // everything is fine
                    _logd_tm(self, @"AdServerResponse StatusCode:",[NSString stringWithFormat:@"%i",super.response.statusCode],nil);
                } else {
                    [GUJServerConnection instance].error = [GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_SERVER_ERROR withUserInfo:nil];
                }
            } else {
                [GUJServerConnection instance].error = [GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_SERVER_ERROR withUserInfo:nil];                
            }
        }
        error       = nil;
        response    = nil;;
    }
}
@end
