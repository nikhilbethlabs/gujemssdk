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

#import "GUJServerConnection.h"

@implementation GUJServerConnection

@synthesize url                 = _url;
@synthesize httpHeaderFields    = _httpHeaderFields;
@synthesize request             = _request;
@synthesize response            = _response;
@synthesize adData              = _adData;
@synthesize error               = _error;

static GUJServerConnection *instance;

+ (GUJServerConnection*)instance
{
    if( instance == nil ) {
        instance = [[self alloc] init];
    }
    @synchronized(instance) {    
        return instance;
    }
}

- (void)releaseInstance
{
    if( [GUJUtil iosVersion] >= __IPHONE_5_0 ) {
        instance.url                = nil;
        instance.httpHeaderFields   = nil;
        instance.request            = nil;
        instance.response           = nil;
        instance.adData             = nil;
        instance.error              = nil;
        instance                    = nil;
    }
}

- (void)sendAdServerRequest
{
    [GUJServerConnection instance].error = nil;
    @autoreleasepool {
        NSHTTPURLResponse   *response   = nil;
        NSError             *error      = nil;   
        
        _url = [GUJAdURL URLForType:[[GUJAdConfiguration sharedInstance] bannerType]];
        _request = [NSMutableURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kGUJServerConnectionTimeout];
        [_request setValue:[GUJUtil formattedHttpUserAgentString] forHTTPHeaderField:kGUJServerConnectionHTTPHeaderFieldKeyForUserAgent];
        [_request setValue:[GUJUtil md5HashedApplicationAdSpaceUUID] forHTTPHeaderField:kGUJServerConnectionHTTPHeaderFieldKeyForUserId];
        
        _logd_tm(self, @"sendAdServerRequest URL:",[_url description],nil);
        _logd_tm(self, kGUJServerConnectionHTTPHeaderFieldKeyForUserAgent,[GUJUtil formattedHttpUserAgentString],nil);
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];  
        
        _adData = [GUJAdData dataWithData:resultData];
        resultData = nil;
        
        if( error != nil ) {
            [GUJServerConnection instance].error = [GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_SERVER_ERROR withUserInfo:[error userInfo]];
            error  = nil;
        }   
        
        @autoreleasepool {
            if( response != nil ) {
                _response = [response copy];
                /*
                 *
                 * Analyse headers.
                 * Maybe the adType has changed.
                 * This will happend if RichMedia and MobileBanner will be served by the same AdSpaceId.
                 * Nasty!
                 */                
                if( [_response respondsToSelector:@selector(allHeaderFields)] ) {
                    /*
                     * Okay. this sucks hard.
                     * Again a workaround. seems that the ad server response ANY header type 
                     * for interstitial expecept the correct interstitial type
                     */
                    BOOL forceInterstitial = NO;
#ifdef __GUJ_SDK_ENABLE_INTERSTITIAL_FORMAT_CHECK__    
                    forceInterstitial = ([[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeInterstitial);
                    if( !forceInterstitial ) {
                        [[GUJAdConfiguration sharedInstance] setBannerType:GUJBannerTypeUndefined];   
                    }
#endif
                    if( [[GUJAdConfiguration sharedInstance] bannerType] == GUJBannerTypeInterstitial) {
                        [[GUJAdConfiguration sharedInstance] setAdShouldShowModal:YES];
                    }
                    [[GUJAdConfiguration sharedInstance] setBannerType:GUJBannerTypeUndefined];
                    
                    NSDictionary *header = [_response performSelector:@selector(allHeaderFields)];      
                    _logd_tm(self, @"ResponseHeader:",header,nil);
                    
                    NSString *flightsFormatHeader = [header objectForKey:KGUJServerConnectionAdditionalHTTPHeaderFlightsFormat];                 
                    if( flightsFormatHeader != nil ) {
                        _logd_tm(self, @"sendAdServerRequest:response:",@"MobileBannerFormat:",flightsFormatHeader,nil);
                        if( forceInterstitial ) {
#ifdef __GUJ_SDK_ENABLE_INTERSTITIAL_FORMAT_CHECK__                            
                            if( ![flightsFormatHeader 
                                  isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForInterstitial] ) {
                                // error: banner format IS not Interstitial
                                [[GUJAdConfiguration sharedInstance] setBannerType:GUJBannerTypeUndefined];
                                [GUJServerConnection instance].error = [GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_NOT_REQUESTED_AD_FORMAT withUserInfo:nil];                                
                            }
#endif                            
                        } else {
                            if([flightsFormatHeader 
                                isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForMobileBanner] ||
                               [flightsFormatHeader 
                                isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForMobileBannerImageOnly] ) {
                                   [[GUJAdConfiguration sharedInstance] setBannerType:GUJBannerTypeMobile];
                               } else if( [flightsFormatHeader 
                                           isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForMobileBannerExpandable] ) {
                                   [[GUJAdConfiguration sharedInstance] setBannerType:GUJBannerTypeRichMedia];                            
                               } else if( [flightsFormatHeader 
                                           isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForInterstitial] ) {
                                   [[GUJAdConfiguration sharedInstance] setBannerType:GUJBannerTypeInterstitial];                            
                               } else {
                                   [[GUJAdConfiguration sharedInstance] setBannerType:GUJBannerTypeUndefined];                            
                               }                           
                        }
                    } else {
                        [GUJServerConnection instance].error = [GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_INCORRECT_AD_FORMAT withUserInfo:nil];   
                    }
                }
            }
        }
        response  = nil;        
    }
}

- (NSInteger)statusCode
{
    NSInteger result = -1;
    if( _response != nil ) {
        result = _response.statusCode;   
    }    
    return result;
}

@end
