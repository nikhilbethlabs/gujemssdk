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
#import "ORMMAParameter.h"
@implementation ORMMAParameter(PrivateImplementation)

- (void)__addParameter:(id)parameter forKey:(NSString*)key
{
    if( parameters_ != nil ) {
        [parameters_ setObject:parameter forKey:key];
    }
}

- (void)__addStringParameter:(NSString*)parameter forKey:(NSString*)key
{
    if( ![parameter hasPrefix:@"'"] && ![parameter hasSuffix:@"'"] ) {
        parameter = [NSString stringWithFormat:@"'%@'",parameter];
    }
    [self __addParameter:parameter forKey:key];
}

- (void)__addSizeParameter:(CGSize)size forKey:(NSString*)key
{
    NSString *parameter = [NSString stringWithFormat:kORMMAStringFormatForSizeParameter,
                           size.width,
                           size.height
                           ];
    [self __addParameter:parameter forKey:key];   
}

- (void)__addPointParameter:(CGPoint)point forKey:(NSString*)key
{
    NSString *parameter = [NSString stringWithFormat:kORMMAStringFormatForPointParameter,
                           point.x,
                           point.y
                           ];
    [self __addParameter:parameter forKey:key];  
}

- (void)__addRectParameter:(CGRect)rect forKey:(NSString*)key
{
    NSString *parameter = [NSString stringWithFormat:kORMMAStringFormatForRectParameter,
                           rect.origin.x,
                           rect.origin.y,
                           rect.size.width,
                           rect.size.height
                           ];
    [self __addParameter:parameter forKey:key];
}

- (void)__addBoolParameter:(BOOL)boolean forKey:(NSString*)key
{
    if( boolean ) {
        [self __addParameter:kORMMAParameterValueForBooleanTrue forKey:key];
    } else {
        [self __addParameter:kORMMAParameterValueForBooleanFalse forKey:key];
    }
}
@end;

@implementation ORMMAParameter

+(ORMMAParameter*)parameter:(id)parameter forKey:(NSString*)key
{
    ORMMAParameter *result = [[ORMMAParameter alloc] init];
    [result __addParameter:parameter forKey:key];
    return result;
}
+(ORMMAParameter*)stringParameter:(NSString*)parameter forKey:(NSString*)key
{
    ORMMAParameter *result = [[ORMMAParameter alloc] init];
    [result __addStringParameter:parameter forKey:key];
    return result;
}

+(ORMMAParameter*)sizeParameter:(CGSize)size forKey:(NSString*)key
{
    ORMMAParameter *result = [[ORMMAParameter alloc] init];
    [result __addSizeParameter:size forKey:key];
    return result;
}

+(ORMMAParameter*)pointParameter:(CGPoint)point forKey:(NSString*)key
{
    ORMMAParameter *result = [[ORMMAParameter alloc] init];
    [result __addPointParameter:point forKey:key];
    return result;
}

+(ORMMAParameter*)rectParameter:(CGRect)rect forKey:(NSString*)key
{
    ORMMAParameter *result = [[ORMMAParameter alloc] init];
    [result __addRectParameter:rect forKey:key];
    return result;
}

+(ORMMAParameter*)boolParameter:(BOOL)boolean forKey:(NSString*)key
{
    ORMMAParameter *result = [[ORMMAParameter alloc] init];
    [result __addBoolParameter:boolean forKey:key];
    return result;
}

- (id)init
{
    self = [super init];
    if( self ) {
        parameters_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)compile
{
    if( parameters_ != nil ) {
        parameterString_ = [[NSMutableString alloc] init];
        NSArray *keys = [parameters_ allKeys];
        for (NSString *key in keys) {
            id parameter = [parameters_ objectForKey:key]; 
            if( ![parameterString_ isEqualToString:kEmptyString] ) {
                [parameterString_ appendString:@", "];
            }
            [parameterString_ appendFormat:@"%@: %@",key,parameter];
        }
        parameters_ = nil;
    }
}

- (NSString*)parameterString
{
    return parameterString_;
}

@end
