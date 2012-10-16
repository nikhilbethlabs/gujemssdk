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
#import "ORMMAHTMLTemplate.h"

@implementation ORMMAHTMLTemplate

static ORMMAHTMLTemplate *sharedInstance_;

- (NSString*)__loadNSStringResource:(NSString*)resourceName
{
    NSString *result = nil;    
    if( resourceManager_ == nil ) {
        resourceManager_ = [ORMMAResourceBundleManager instanceForBundle:kORMMAResourceBundleName];
    }
    if( [resourceManager_ hasLoadedBundle] ) {
        result =  [resourceManager_ loadStringResource:resourceName];
    }
    return result;
}

- (NSString*)__loadHTMLTemplateResource
{
    return [self __loadNSStringResource:kORMMAResourceNameForHTMLStub];
}

- (NSString*)__loadORMMAJavascriptResource
{
    return [self __loadNSStringResource:kORMMAResourceNameForORMMAJavascript];
}

- (NSString*)__loadORMMAiOSBridgeJavascriptResource
{
    return [self __loadNSStringResource:kORMMAResourceNameForORMMAJavascriptBridge];
}

- (BOOL)__createORMMAHTMLTemplate
{
    BOOL result = YES;
    ormmaTeplate_ = nil;
    if( ormmaTeplate_ == nil ) {
        ormmaTeplate_ = [[NSString alloc] init];
        NSString *htmlTemplate      = [self __loadHTMLTemplateResource];
        NSString *ormmaJavascript   = [self __loadORMMAJavascriptResource];
        NSString *bridgeJavascript  = [self __loadORMMAiOSBridgeJavascriptResource];
        if( htmlTemplate && ormmaJavascript && bridgeJavascript ) {
            ormmaTeplate_ = [htmlTemplate stringByReplacingOccurrencesOfString:kORMMAHTMLTemplateJavascriptToken withString:ormmaJavascript];
            ormmaTeplate_ = [ormmaTeplate_ stringByReplacingOccurrencesOfString:kORMMAHTMLTemplateJavascriptBridgeToken withString:bridgeJavascript];  
            @autoreleasepool {
                ormmaTeplate_ = [[NSString stringWithFormat:@"%@",ormmaTeplate_] copy];   
            }
        } else {
            result = NO;
        }
    }        
    return result;
}

- (NSString*)__createORRMAHTMLTemplateWithAdData:(GUJAdData*)adData
{
    NSString *result = nil;
    if( adData != nil && [self __createORMMAHTMLTemplate] && ormmaTeplate_ ) {
        result = [ormmaTeplate_ stringByReplacingOccurrencesOfString:kORMMAHTMLTemplateAdContentToken withString:[adData asNSUTF8StringRepresentation]];
    }
    return result;
}


+ (ORMMAHTMLTemplate*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[ORMMAHTMLTemplate alloc] init];
    }          
    return sharedInstance_;
}

- (void)freeInstance
{
    if( sharedInstance_ != nil ) {
        ormmaTeplate_ = nil;
        [[ORMMAResourceBundleManager sharedInstance] freeInstance];
    }
    sharedInstance_ = nil;
}

+ (NSString*)htmlTemplateWithAdData:(GUJAdData*)adData
{
    return [[ORMMAHTMLTemplate sharedInstance] __createORRMAHTMLTemplateWithAdData:adData];
}

@end
