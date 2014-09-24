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
#import "ORMMAResourceBundleManager.h"

@implementation ORMMAResourceBundleManager(PrivateImplementation)

- (void)__loadResourceBundle:(NSString*)bundleName
{
    [self setLoaded:NO];
    [self setError:nil];
    @autoreleasepool {
        [self setResourceBundle:[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]]];
        if( [self resourceBundle] != nil ) {
            [self setLoaded:YES];
        } else {
            [self setError:[NSError errorWithDomain:kORMMAResourceBundleErrorDomain code:ORMMA_ERROR_CODE_FAILED_LOADING_RESOURCE_BUNDLE userInfo:nil]];
        }
    }
}

- (void)__loadResourceBundle
{
    [self __loadResourceBundle:kORMMAResourceBundleName];
}

@end

@implementation ORMMAResourceBundleManager

+ (ORMMAResourceBundleManager*)instanceForBundle:(NSString*)bundleName
{
    ORMMAResourceBundleManager *result = [[ORMMAResourceBundleManager alloc] init];
    [result __loadResourceBundle:bundleName];
    return result;
}

- (void)freeInstance
{
    [self setResourceBundle:nil];
}

- (NSString*)loadStringResource:(NSString*)resourceName ofType:(NSString*)type
{
    NSString *result = nil;
    [self setError:nil];
    if( [self resourceBundle] != nil ) {
        NSURL *contentURL = [NSURL fileURLWithPath:[[self resourceBundle] pathForResource:resourceName ofType:type]];
        if( contentURL ) {
            NSError *error = nil;
            result = [NSString stringWithContentsOfURL:contentURL encoding:NSUTF8StringEncoding error:&error];
            if( error ) {
                _log_t(self, [NSString stringWithFormat:@"[%@] UnableToLoadStringResource: %@",kORMMAResourceBundleErrorDomain,error]);
                [self setError:[NSError errorWithDomain:kORMMAResourceBundleErrorDomain code:ORMMA_ERROR_CODE_FAILED_LOADING_RESOURCE userInfo:[error userInfo]]];
            }
        }
    }
    return result;
}

- (NSString*)loadStringResource:(NSString*)resourceName
{
    return [self loadStringResource:resourceName ofType:nil];
}

- (UIImage*)loadImageResource:(NSString*)resourceName ofType:(NSString*)type
{
    UIImage *result = nil;
    [self setError:nil];
    if( [self resourceBundle] != nil ) {
        NSString *contentPath = [[self resourceBundle] pathForResource:resourceName ofType:type];
        if( contentPath ) {
            result = [UIImage imageWithContentsOfFile:contentPath];
            if( !result ) {
                _log_t(self, [NSString stringWithFormat:@"[%@] UnableToLoadImageResource: %@ OfType: %@",kORMMAResourceBundleErrorDomain,resourceName,type]);
                [self setError:[NSError errorWithDomain:kORMMAResourceBundleErrorDomain code:ORMMA_ERROR_CODE_FAILED_LOADING_RESOURCE userInfo:nil]];
            }
        }
    }
    return result;
}

- (UIImage*)loadImageResource:(NSString*)resourceName
{
    return [self loadImageResource:resourceName ofType:nil];
}

@end
