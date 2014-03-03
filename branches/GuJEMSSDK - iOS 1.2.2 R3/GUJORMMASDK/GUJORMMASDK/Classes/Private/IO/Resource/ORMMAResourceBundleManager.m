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
    loaded_ = NO;
    @autoreleasepool {
        resourceBundle_ = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]];   
        if( resourceBundle_ != nil ) {
            loaded_ = YES;
        }
    }
}

- (void)__loadResourceBundle
{ 
    [self __loadResourceBundle:kORMMAResourceBundleName];
}

@end

@implementation ORMMAResourceBundleManager

static ORMMAResourceBundleManager *sharedInstance_;


+ (ORMMAResourceBundleManager*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[ORMMAResourceBundleManager alloc] init];  
    }
    @synchronized(sharedInstance_) {            
        return sharedInstance_;
    }  
}

+ (ORMMAResourceBundleManager*)instanceForBundle:(NSString*)bundleName
{
    if( sharedInstance_ == nil ) {
        [ORMMAResourceBundleManager sharedInstance];
        [sharedInstance_ __loadResourceBundle:bundleName];
        if( ![sharedInstance_ hasLoadedBundle] ) {
            sharedInstance_ = nil;
        }
    }
    if( sharedInstance_ !=  nil ) {
        @synchronized(sharedInstance_) {
            return sharedInstance_;
        }
    } else {
        return [ORMMAResourceBundleManager sharedInstance];
    }
}

- (void)freeInstance
{
    resourceBundle_ = nil;
    sharedInstance_ = nil;
}

- (NSError*)lastError
{
    return error_;
}

- (BOOL)hasLoadedBundle
{
    return loaded_;
}

- (NSBundle*)bundle
{
    return resourceBundle_;
}

- (NSString*)loadStringResource:(NSString*)resourceName ofType:(NSString*)type
{
    NSString *result = nil;
    if( resourceBundle_ != nil ) {        
        NSURL *contentURL = [NSURL fileURLWithPath:[resourceBundle_ pathForResource:resourceName ofType:type]];              
        if( contentURL ) {
            NSError *error = nil;
            result = [NSString stringWithContentsOfURL:contentURL encoding:NSUTF8StringEncoding error:&error];
            [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAResourceBundleErrorDomain code:error.code userInfo:[error userInfo]]];
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
    if( resourceBundle_ != nil ) {        
        NSString *contentPath = [resourceBundle_ pathForResource:resourceName ofType:type];           
        if( contentPath ) {
            result = [UIImage imageWithContentsOfFile:contentPath];
            if( !result ) {
                [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAResourceBundleErrorDomain code:GUJ_ERROR_CODE_UNABLE_TO_LOAD userInfo:nil]];
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
