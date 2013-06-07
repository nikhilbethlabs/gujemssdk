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
#import "GUJmOceanUtil.h"

@implementation GUJmOceanUtil

+ (NSString*)adTypeForMASTAdView:(id)adView
{
    NSString *result = nil;
    id descriptor = [GUJmOceanUtil descriptorForMASTAdView:adView];
    if( [GUJUtil typeIsNotNil:descriptor andRespondsToSelector:@selector(adType)] ) {
        result = [descriptor performSelector:@selector(adType)];   
    }
    return result;
}

+ (NSUInteger)adContentTypeForMASTAdView:(id)adView
{
    NSUInteger result = -1;
    id descriptor = [GUJmOceanUtil descriptorForMASTAdView:adView];
    if( [GUJUtil typeIsNotNil:descriptor andRespondsToSelector:@selector(adContentType)] ) {
        result = (NSUInteger)[descriptor performSelector:@selector(adContentType)];   
    }
    return result;
}

+ (id)adModelForMASTAdView:(id)adView
{
    id result = nil;
    if( [GUJUtil typeIsNotNil:adView andRespondsToSelector:@selector(adModel)] ) {
        result = [adView performSelector:@selector(adModel)]; 
    }
    return result;
}

+ (id)descriptorForMASTAdView:(id)adView
{
    id result = nil;
    id adModel = [GUJmOceanUtil adModelForMASTAdView:adView];
    if( [GUJUtil typeIsNotNil:adModel andRespondsToSelector:@selector(descriptor)] ) {
        result = [adModel performSelector:@selector(descriptor)]; 
    }  
    return result;
}

+ (NSURL*)urlForMASTAdView:(id)adView
{
    NSURL *result = nil;
    if( [GUJUtil typeIsNotNil:adView andRespondsToSelector:@selector(adModel)] ) {         
        id adModel = [adView performSelector:@selector(adModel)];
        if( [adModel respondsToSelector:@selector(url)] ) {
            result = [adModel performSelector:@selector(url)];
        }
    } 
    return result;
}

+ (NSData*)serverResponseForMASTAdView:(id)adView
{
    NSData *result = nil;
    id descriptor = [GUJmOceanUtil descriptorForMASTAdView:adView];
    if( [GUJUtil typeIsNotNil:descriptor andRespondsToSelector:@selector(serverReponse)] ) {
        id response = [descriptor performSelector:@selector(serverReponse)];
        if( [response isKindOfClass:[NSData class]] ) {
            result = [NSData dataWithData:(NSData*)response];
        }
    }
    return result;
}

@end
