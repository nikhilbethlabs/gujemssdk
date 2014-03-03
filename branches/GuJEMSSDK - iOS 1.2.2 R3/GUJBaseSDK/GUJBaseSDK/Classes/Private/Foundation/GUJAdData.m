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
#import "GUJAdData.h"

@implementation GUJAdData

// private 
const void *_bytes;
NSInteger _length;

#pragma mark override NSData methods
+ (id)dataWithData:(NSData *)data
{  
    GUJAdData *instance = nil;    
    if( data ) {
        instance = [[GUJAdData alloc] init];
        [instance setData:data];
    }
    return instance;
}

- (NSUInteger)length
{
    return _length;
}

- (void *)mutableBytes
{
    return(void*)_bytes;
}

- (const void *)bytes
{
    return _bytes;
}

- (void)setData:(NSData *)data
{ 
    @autoreleasepool {        
        if( data && data.bytes ) {
            NSUInteger dataLength = (NSUInteger)[data length];
            _bytes = (Byte*)malloc(dataLength);
            memcpy((void*)_bytes, [data bytes], dataLength);
            [self setLength:dataLength];
            // this may leak
           // free((void*)_bytes);
        }
    }        
}

- (void)setLength:(NSUInteger)length
{
    _length = length;
}

#pragma mark public methods
- (NSString*)asNSUTF8StringRepresentation
{
    NSString *result = nil;
    if( self ) {
        result = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];   
    }
    return result;
}

@end
