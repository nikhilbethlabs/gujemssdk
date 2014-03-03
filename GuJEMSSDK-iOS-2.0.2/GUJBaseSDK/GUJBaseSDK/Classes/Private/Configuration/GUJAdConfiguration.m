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
#import "GUJAdConfiguration.h"

@implementation GUJAdConfiguration

- (BOOL)isValid
{
    BOOL result = YES;
    if( (!adSpaceId_) ) {
        result = NO;
        error_ = [GUJUtil errorForDomain:kGUJConfigurationErrorDomain andCode:GUJ_ERROR_CODE_ADSPACE_ID];
    }
    _logd_tm(self, @"AdSpaceId:", adSpaceId_,nil);
    return result;
}

- (void)setAdServerURL:(NSString*)adServerURL
{
    adServerURL_ = adServerURL;
}

- (NSString*)adServerURL
{
    NSString *result = adServerURL_;
    if( adServerURL_ == nil ) {
        result = kGUJURLAdSpace;
    }
    return result;
}

- (void)setAdSpaceId:(NSString*)adSpaceId
{
    adSpaceId_ = adSpaceId;
}

- (NSString*)adSpaceId
{
    return adSpaceId_;
}

- (void)setBannerType:(GUJBannerType)bannerType
{
    bannerType_ = bannerType;
}

- (GUJBannerType)bannerType
{
    return bannerType_;
}

- (void)setRequestedBannerType:(GUJBannerType)bannerType
{
    requestedBannerType_ = bannerType;
}

- (GUJBannerType)requestedBannerType
{
    return requestedBannerType_;
}

- (void)setReloadInterval:(NSTimeInterval)interval
{
    reloadInterval_ = interval;
}

- (NSTimeInterval)reloadInterval
{
    return reloadInterval_;
}

- (void)setDisableLocationService:(BOOL)disable
{
    locationServiceDisabled_ = disable;
}

- (void)setAdShouldShowModal:(BOOL)should
{
    willShowAdModal_ = should;
}

- (BOOL)willShowAdModal
{
    if( [self bannerType] == GUJBannerTypeInterstitial ) {
        return YES;
    } else {
        return willShowAdModal_;
    }
}

- (BOOL)locationServiceDisabled
{
    return locationServiceDisabled_;
}

- (void)setKeywords:(NSArray*)keywords
{
    @autoreleasepool {
        keywords_ = [keywords copy];
    }
}

- (NSArray*)keywords
{
    return keywords_;
}

- (NSString*)keywordsFormatted
{
    NSMutableString *result = [[NSMutableString alloc] init];
    if( keywords_ != nil && [keywords_ count] > 0 ) {
        for (int i=0; i<[keywords_ count]; i++) {
            [result appendFormat:@"%@",[keywords_ objectAtIndex:i]];
            if( [keywords_ count] > (i+1) ) {
                [result appendString:@"|"];
            }
        }
    }
    return result;
}

- (NSString*)keywordsFormattedWithURLEncoding
{
    NSString *result = [self keywordsFormatted];
    if( result ) {
        result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return result;
}

- (BOOL)hasCustomAdServerHeaderFields
{
    BOOL result = NO;
    if( customAdServerHeaderFields_ != nil && [customAdServerHeaderFields_ count] > 0 ) {
        result = YES;
    }
    return result;
}

- (void)addCustomAdServerHeaderField:(NSString*)name value:(NSString*)value
{
    if( customAdServerHeaderFields_ == nil ) {
        customAdServerHeaderFields_ = [[NSMutableDictionary alloc] init];
    }
    [customAdServerHeaderFields_ setObject:value forKey:name];
}

- (NSString*)getCustomAdServerHeaderField:(NSString*)name
{
    NSString *result = nil;
    if( customAdServerHeaderFields_ != nil ) {
        result = [customAdServerHeaderFields_ objectForKey:name];
    }
    return result;
}

- (void)setCustomAdServerHeaderField:(NSDictionary*)headerFields
{
    customAdServerHeaderFields_ = [NSMutableDictionary dictionaryWithDictionary:headerFields];
}

- (void)removeCustomAdServerHeaderField:(NSString*)name
{
    if( customAdServerHeaderFields_ != nil ) {
        [customAdServerHeaderFields_ removeObjectForKey:name];
    }
}

- (NSMutableDictionary*)customAdServerHeaderFields
{
    return customAdServerHeaderFields_;
}

- (BOOL)hasCustomAdServerRequestParameters
{
    BOOL result = NO;
    if( customAdServerRequestParameters_ != nil && [customAdServerRequestParameters_ count] > 0 ) {
        result = YES;
    }
    return result;
}

- (void)addCustomAdServerRequestParameter:(NSString*)name value:(NSString*)value
{
    if( customAdServerRequestParameters_ == nil ) {
        customAdServerRequestParameters_ = [[NSMutableDictionary alloc] init];
    }
    [customAdServerRequestParameters_ setObject:value forKey:name];
}

- (NSString*)getCustomAdServerRequestParameter:(NSString*)name
{
    NSString *result = nil;
    if( customAdServerRequestParameters_ != nil ) {
        result = [customAdServerRequestParameters_ objectForKey:name];
    }
    return result;
}

- (void)setCustomAdServerRequestParameters:(NSDictionary*)requestParameters
{
    customAdServerRequestParameters_ = [NSMutableDictionary dictionaryWithDictionary:requestParameters];
}

- (void)removeCustomAdServerRequestParameter:(NSString*)name
{
    if( customAdServerRequestParameters_ != nil ) {
        [customAdServerRequestParameters_ removeObjectForKey:name];
    }
}

- (NSMutableDictionary*)customAdServerRequestParameters
{
    return customAdServerRequestParameters_;
}

- (void)addCustomConfiguration:(id)value forKey:(NSString*)key
{
    if( customConfiguration_ == nil ) {
        customConfiguration_ = [[NSMutableDictionary alloc] init];
    }
    [customConfiguration_ setObject:value forKey:key];
}

- (id)getCustomConfigurationForKey:(NSString*)key
{
    id result = nil;
    if( customConfiguration_ != nil ) {
        result = [customConfiguration_ objectForKey:key];
    }
    return result;
}

- (id)setCustomConfiguration:(id)value forKey:(NSString*)key
{
    id result = nil;
    if( (customConfiguration_ != nil) && ([customConfiguration_ objectForKey:key] != nil) ) {
        result = [customConfiguration_ objectForKey:key];
        [customConfiguration_ setObject:value forKey:key];
    }
    return result;
}

- (void)setCustomConfiguration:(NSDictionary*)costumConfiguration
{
    customConfiguration_ = [[NSMutableDictionary alloc] initWithDictionary:costumConfiguration];
}

- (id)removeCustomConfigurationForKey:(NSString*)key
{
    id result = nil;
    if( (customConfiguration_ != nil) && ([customConfiguration_ objectForKey:key] != nil) ) {
        result = [customConfiguration_ objectForKey:key];
        [customConfiguration_ removeObjectForKey:key];
    }
    return result;
}

- (NSMutableDictionary*)customConfiguration
{
    return customConfiguration_;
}

- (NSError*)error
{
    return error_;
}

- (NSUInteger)initializationAttempts
{
    return initializationAttempts_;
}

- (void)setInitializationAttempts:(NSUInteger)attempts
{
    initializationAttempts_ = attempts;
}

@end
