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

static GUJAdConfiguration *sharedInstance_;

+ (GUJAdConfiguration*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[super alloc] init];  
        sharedInstance_->reloadInterval_ = kGUJDefaultAdReloadInterval;
    }
    @synchronized(sharedInstance_) {
        return sharedInstance_;
    }
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    sharedInstance_ = nil;
}

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

- (void)setDebug:(BOOL)debug
{
    debug_ = debug;
}

- (BOOL)debug
{
    return debug_;
}

- (void)setAdServerURL:(NSString*)adServerURL
{
    adServerURL_ = adServerURL;
}

- (NSString*)adServerURL
{
    NSString *result = adServerURL_;
    if( debug_ ) {
        result = kGUJURLAdSpaceTest;
    } else if( adServerURL_ == nil ) {
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
    return willShowAdModal_; 
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

- (NSError*)error
{
    return error_;
}

@end
