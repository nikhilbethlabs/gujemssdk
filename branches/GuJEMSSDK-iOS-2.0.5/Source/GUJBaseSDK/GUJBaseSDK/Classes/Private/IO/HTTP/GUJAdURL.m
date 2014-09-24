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
#import "GUJAdURL.h"

@implementation GUJAdURL

@synthesize urlBuilder = _urlBuilder;

+(GUJAdURL*)URLForType:(GUJBannerType)bannerType configuration:(GUJAdConfiguration*)configuration
{
    GUJAdURLBuilder *urlBuilder = [[GUJAdURLBuilder alloc] initWithAdConfiguration:configuration];
    [urlBuilder setBannerType:bannerType];
    
    GUJAdURL *result = [GUJAdURL URLWithString:[urlBuilder buildURLString]];
    [result setUrlBuilder:urlBuilder];
    return result;
}

+(GUJAdURL*)URLForType:(GUJBannerType)bannerType andMarkupType:(GUJBannerMarkup)markupType configuration:(GUJAdConfiguration*)configuration
{
    GUJAdURLBuilder *urlBuilder = [[GUJAdURLBuilder alloc] initWithAdConfiguration:configuration];
    [urlBuilder setBannerType:bannerType];
    [urlBuilder setBannerMarkup:markupType];
    
    GUJAdURL *result = [GUJAdURL URLWithString:[urlBuilder buildURLString]];
    [result setUrlBuilder:urlBuilder];
    return result;
}

- (id)valueForURLParameter:(GUJURLParameter)parameter
{
    return [_urlBuilder valueForURLParameter:parameter];
}

- (void)addParameter:(NSString*)key value:(id)value
{
    @autoreleasepool {
        NSString *url = [self absoluteString];
        if( url != nil ) {
            if( ([url rangeOfString:@"="].location != NSNotFound) ||
               ([url rangeOfString:@"?"].location != NSNotFound) ) {
                url = [url stringByAppendingString:@"&"];
            } else {
                url = [url stringByAppendingString:@"?"];
            }
            url = [url stringByAppendingFormat:kGUJURLParameterKeyValueFormat,key,value];
            __attribute__((unused))
            id _self = [self initWithString:url];
            url = nil;
        }
    }
}

- (NSString*)replaceParameter:(NSString*)key value:(id)value
{
    NSString *result = nil;
    @autoreleasepool {
        NSString *url = [self absoluteString];
        if( url != nil ) {
            if( ([url rangeOfString:key].location != NSNotFound) ) {
                NSString *leadingURLPart    = [url substringToIndex:[url rangeOfString:key].location];
                NSString *trailingURLPart   = [url substringFromIndex:[url rangeOfString:key].location];
                NSString *untouchedURLPart  = kEmptyString;
                NSString *parameterURLPart  = kEmptyString;
                NSUInteger ampLocation      = [trailingURLPart rangeOfString:@"&"].location;
                
                if( ampLocation != NSNotFound ) {
                    untouchedURLPart = [trailingURLPart substringFromIndex:ampLocation];
                    parameterURLPart = [trailingURLPart substringToIndex:ampLocation];
                } else {
                    parameterURLPart = trailingURLPart;
                }
                if( [parameterURLPart rangeOfString:@"="].location != NSNotFound ) {
                    result = [[parameterURLPart componentsSeparatedByString:@"="] objectAtIndex:1];
                }
                
                parameterURLPart = [NSString stringWithFormat:kGUJURLParameterKeyValueFormat,key,value];
                url = [NSString stringWithFormat:@"%@%@%@",leadingURLPart,parameterURLPart,untouchedURLPart];
                
                __attribute__((unused))
                id _self        = [self initWithString:url];
                url             = nil;
                leadingURLPart  = nil;
                trailingURLPart = nil;
                untouchedURLPart= nil;
                parameterURLPart= nil;
                
            }
        }
    }
    return result;
}

@end
