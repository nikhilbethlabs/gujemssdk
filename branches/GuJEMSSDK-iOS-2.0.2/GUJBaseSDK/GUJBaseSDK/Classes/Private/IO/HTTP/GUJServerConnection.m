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

@implementation GUJServerConnection (Private)

- (void)__preprocessResponseHeader
{
    @autoreleasepool {
        if( [self response] != nil && [[self response] allHeaderFields] != nil ) {
            
            if( [[self adConfiguration] bannerType] == GUJBannerTypeInterstitial ||
               [[self adConfiguration] requestedBannerType] == GUJBannerTypeInterstitial ) {
                [[self adConfiguration] setAdShouldShowModal:YES];
            }
            
            // reset banner type
            [[self adConfiguration] setBannerType:GUJBannerTypeUndefined];
            
            // get all headers
            [self setHttpHeaderFields:[NSMutableDictionary dictionaryWithDictionary:[[self response] allHeaderFields]]];
            _logd_tm(self, @"ResponseHeader:",[self httpHeaderFields],nil);
            
            NSString *flightsFormatHeader = [[self httpHeaderFields] objectForKey:KGUJServerConnectionAdditionalHTTPHeaderFlightsFormat];
            
            if( flightsFormatHeader != nil ) {
                _logd_tm(self, @"sendAdServerRequest:response:",@"MobileBannerFormat:",flightsFormatHeader,nil);
                
                if([flightsFormatHeader isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForMobileBanner] ||
                   [flightsFormatHeader isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForMobileBannerImageOnly] ) {
                    [[self adConfiguration] setBannerType:GUJBannerTypeMobile];
                } else if( [flightsFormatHeader isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForMobileBannerExpandable] ) {
                    [[self adConfiguration] setBannerType:GUJBannerTypeRichMedia];
                } else if( [flightsFormatHeader isEqualToString:KGUJServerConnectionHTTPHeaderFieldValueForInterstitial] ) {
                    [[self adConfiguration] setBannerType:GUJBannerTypeInterstitial];
                } else if( [flightsFormatHeader isEqualToString:KGUJServerConnectionAdditionalHTTPHeaderEmptyFlightsFormatBody] ) {
                    [[self adConfiguration] setBannerType:GUJBannerTypeUndefined];
                    [self setError:[GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_INVALID_AD_FORMAT_HEADER withUserInfo:nil]];
                } else {
                    [[self adConfiguration] setBannerType:GUJBannerTypeUndefined];
                }
                
            } else {
                [self setError:[GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_INCORRECT_AD_FORMAT withUserInfo:nil]];
            }
            
        } else {
            [self setError:[GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_INVALID_AD_SERVER_RESPONSE withUserInfo:nil]];
        }
    }
}

@end


@implementation GUJServerConnection

+ (void)adServerRequestWithConfiguration:(GUJAdConfiguration*)configuration completion:(requestCompletionHandler)completionBlock
{
    GUJServerConnection *connection = [[GUJServerConnection alloc] initWithAdConfiguration:configuration];
    [connection sendAdServerRequest:completionBlock];
}

- (id)initWithAdConfiguration:(GUJAdConfiguration*)configuration
{
    self = [super init];
    if( self ) {
        [self setAdConfiguration:configuration];
    }
    return self;
}

- (void)sendAdServerRequest:(requestCompletionHandler)completionBlock
{
    [self setError:nil];
    if( [self adConfiguration] == nil ) {
        [self setError:[GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_MISSING_ADCONFIGURATION withUserInfo:nil]];
        return;
    }
    @autoreleasepool {
        
        [self setUrl:[GUJAdURL URLForType:[[self adConfiguration] bannerType] configuration:[self adConfiguration]]];
        [self setRequest:[NSMutableURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kGUJServerConnectionTimeout]];
        
        [[self request] setValue:[GUJUtil formattedHttpUserAgentString] forHTTPHeaderField:kGUJServerConnectionHTTPHeaderFieldKeyForUserAgent];
        [[self request] setValue:[GUJUtil md5HashedApplicationAdSpaceUUID] forHTTPHeaderField:kGUJServerConnectionHTTPHeaderFieldKeyForUserId];
        
        if( [[self adConfiguration] hasCustomAdServerHeaderFields] ) {
            NSDictionary *customHeader = [[self adConfiguration] customAdServerHeaderFields];
            for (NSString *headerName in customHeader) {
                NSString *headerValue = [customHeader objectForKey:headerName];
                [[self request] setValue:headerValue forHTTPHeaderField:headerName];
            }
        }
        
        _logd_tm(self, @"sendAdServerRequest URL:",[_url description],nil);
        _logd_tm(self, kGUJServerConnectionHTTPHeaderFieldKeyForUserAgent,[GUJUtil formattedHttpUserAgentString],nil);
        _logd_tm(self, @"requestHeader",   [_request allHTTPHeaderFields],nil);
        
        __strong id _safeSelf = self;
        [NSURLConnection sendAsynchronousRequest:[self request]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   [_safeSelf setResponse:(NSHTTPURLResponse*)[response copy]];
                                   [_safeSelf setAdData:[GUJAdData dataWithData:data]];
                                   if( error != nil ) {
                                       [_safeSelf setError:[GUJUtil errorForDomain:kGUJServerConnectionErrorDomain andCode:GUJ_ERROR_CODE_SERVER_ERROR withUserInfo:[error userInfo]]];
                                   }
                                   [_safeSelf __preprocessResponseHeader];
                                   completionBlock(_safeSelf,error);
                               }];
        
    }
}

@end
