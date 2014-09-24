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

#define kHTMLElementSearchRange 40

@implementation ORMMAHTMLTemplate

- (BOOL)__isFullHTMLAd:(GUJAdData*)adData
{
    BOOL result = NO;
    if( adData != nil && [[adData asNSUTF8StringRepresentation] length] >= kHTMLElementSearchRange ) {
        if( [[[[adData asNSUTF8StringRepresentation] substringToIndex:kHTMLElementSearchRange] lowercaseString] rangeOfString:@"<html>"].location != NSNotFound ) {
            result = YES;
        }
    }
    return result;
}

- (NSString*)__loadNSStringResource:(NSString*)resourceName
{
    NSString *result = nil;
    if( [self ormmaResourceBundle] == nil ) {
        [self setOrmmaResourceBundle:[ORMMAResourceBundleManager instanceForBundle:kORMMAResourceBundleName]];
    }
    if( [[self ormmaResourceBundle] loaded] ) {
        result =  [[self ormmaResourceBundle] loadStringResource:resourceName];
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
    @autoreleasepool {
        [self setOrmmaTemplate:[[NSString alloc] init]];
        NSString *htmlTemplate      = [self __loadHTMLTemplateResource];
        NSString *ormmaJavascript   = [self __loadORMMAJavascriptResource];
        NSString *bridgeJavascript  = [self __loadORMMAiOSBridgeJavascriptResource];
        if( htmlTemplate && ormmaJavascript && bridgeJavascript ) {
            [self setOrmmaTemplate:[htmlTemplate stringByReplacingOccurrencesOfString:kORMMAHTMLTemplateJavascriptToken withString:ormmaJavascript]];
            [self setOrmmaTemplate:[[self ormmaTemplate] stringByReplacingOccurrencesOfString:kORMMAHTMLTemplateJavascriptBridgeToken withString:bridgeJavascript]];
            
            [self setOrmmaTemplate:[[NSString stringWithFormat:@"%@",[self ormmaTemplate]] copy]];
            
        } else {
            result = NO;
        }
    }
    return result;
}

- (NSString*)__createORRMAHTMLTemplateWithAdData:(GUJAdData*)adData
{
    NSString *result = nil;
    if( adData != nil && [self __createORMMAHTMLTemplate] && [self ormmaTemplate] ) {
        result = [[self ormmaTemplate] stringByReplacingOccurrencesOfString:kORMMAHTMLTemplateAdContentToken withString:[adData asNSUTF8StringRepresentation]];
    }
    return result;
}

- (NSString*)__injectORMMAWithAdData:(GUJAdData*)adData
{
    NSString *result = nil;
    if( adData != nil ) {
        result = [adData asNSUTF8StringRepresentation];
        NSString *ormmaJavascript   = [NSString stringWithFormat:kORMMAHTMLTemplateJavaScriptTemplate,[self __loadORMMAJavascriptResource]];
        NSString *bridgeJavascript  = [NSString stringWithFormat:kORMMAHTMLTemplateJavaScriptTemplate,[self __loadORMMAiOSBridgeJavascriptResource]];
        NSString *headTag = nil;
        if( [result rangeOfString:kORMMAHTMLTemplateLowercaseHeadTag].location != NSNotFound ) {
            headTag = kORMMAHTMLTemplateLowercaseHeadTag;
        } else if( [result rangeOfString:kORMMAHTMLTemplateUppercaseHeadTag].location != NSNotFound ) {
            headTag = kORMMAHTMLTemplateUppercaseHeadTag;
        }
        if( headTag != nil ) {
            result = [result stringByReplacingOccurrencesOfString:headTag withString:[NSString stringWithFormat:@"%@%@%@",kORMMAHTMLTemplateLowercaseHeadTag,bridgeJavascript,ormmaJavascript]];
        }
    }
    return result;
}

- (void)freeInstance
{
    [self setOrmmaTemplate:nil];
    [[self ormmaResourceBundle] freeInstance];
}

+ (NSString*)htmlTemplateWithAdData:(GUJAdData*)adData
{
    ORMMAHTMLTemplate *template = [[ORMMAHTMLTemplate alloc] init];
    if( [template __isFullHTMLAd:adData] ) {
        return [template __injectORMMAWithAdData:adData];
    } else {
        return [template __createORRMAHTMLTemplateWithAdData:adData];
    }
}

@end
