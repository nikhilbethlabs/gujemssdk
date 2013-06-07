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
#import "ORMMACall.h"

@implementation ORMMACall(PrivateImplementation)

- (BOOL)__isORMMACall:(NSString*)call
{
    return ( [call rangeOfString:kORMMAProtocolIdentifier].location != NSNotFound );
}

- (BOOL)__isORMMAServiceCall:(NSString*)call
{
    return ( [call rangeOfString:kORMMAServiceCallIdentifier].location != NSNotFound );
}

- (BOOL)__parseCallString:(NSString*)callString
{
    BOOL result  = NO;
    callName_    = nil;
    ormmaCall_   = [self __isORMMACall:callString]; 
    serviceCall_ = [self __isORMMAServiceCall:callString];
    if( ormmaCall_ ) {
        // parse the service call
        if( [callString rangeOfString:@"?"].location != NSNotFound  ) {
            if( !serviceCall_ ) {
                callName_ = (NSString*)[[callString componentsSeparatedByString:@"?"] objectAtIndex:0];
                callName_ = [callName_ stringByReplacingOccurrencesOfString:kORMMAProtocolIdentifier withString:kEmptyString];
            }
            callString = (NSString*)[[callString componentsSeparatedByString:@"?"] objectAtIndex:1];
            result = YES;
        }        
        if( [callString rangeOfString:@"&"].location != NSNotFound ) {
            NSArray *parameters = [callString componentsSeparatedByString:@"&"];
            for (NSString *parameter in parameters) {
                if( [callString rangeOfString:@"="].location != NSNotFound ) {
                    if( serviceCall_ ) {
                        NSArray *pair = [parameter componentsSeparatedByString:@"="];
                        NSString *key = [pair objectAtIndex:0]; 
                        NSString *value = [[pair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        if( [key isEqualToString:kORMMABridgeParameterName] ) {
                            callName_ = value;
                        }
                        if( [key isEqualToString:kORMMABridgeParameterEnabled] ) {
                            serviceCallValue_ = value;                        
                        }
                    } else { // not serviceCall_
                        if( [parameter rangeOfString:@"="].location != NSNotFound ) {
                            NSArray *pair = [parameter componentsSeparatedByString:@"="];
                            // process ONLY if pair has key + value
                            if( [pair count] == 2 ) {
                                if( callValue_ == nil ) {
                                    callValue_ = [[NSMutableDictionary alloc] init];
                                }
                                [callValue_ setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
                            }
                        }
                    }
                }
            }
        } else { // parse other calls
            if( [callString rangeOfString:@"="].location != NSNotFound ) {
                result = YES;
                NSArray *pair = [callString componentsSeparatedByString:@"="];
                // process ONLY if pair has key + value
                if( [pair count] == 2 ) {
                    if( callValue_ == nil ) {
                        callValue_ = [[NSMutableDictionary alloc] init];
                    }
                    [callValue_ setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
                }
            } else if( [callString rangeOfString:kORMMAProtocolIdentifier].location != NSNotFound ) {
                callName_ = [callString stringByReplacingOccurrencesOfString:kORMMAProtocolIdentifier 
                                                                  withString:kEmptyString];
                result = YES;
            } else {                                
                [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMACallErrorDomain code:GUJ_ERROR_CODE_GENERAL_UNDEFINED userInfo:nil]];
            }
        }
        
    }
    return result;
}
@end

@implementation ORMMACall
+(ORMMACall*)parse:(NSString*)ormmaCall
{
    ORMMACall *result = [[ORMMACall alloc] init];
    [result __parseCallString:ormmaCall];
    return result;
}

- (BOOL)isValidCall
{
    return ormmaCall_;
}

- (BOOL)isServiceCall
{
    return serviceCall_;
}

- (BOOL)isCallForIdentifier:(NSString*)identifier
{
    BOOL result = NO;
    if( callName_ ) {
        if( [callName_ isEqualToString:identifier] ) {
            result = YES;
        }
    }
    return result;
}

- (NSString*)name
{
    return callName_;
}

- (NSString*)serviceCallValue
{
    return serviceCallValue_;
}

- (NSMutableDictionary*)value
{
    return callValue_;
}

@end
