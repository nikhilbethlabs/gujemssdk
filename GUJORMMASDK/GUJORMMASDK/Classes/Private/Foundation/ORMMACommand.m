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
#import "ORMMACommand.h"
@implementation ORMMACommand(PrivateImplementation)
- (void)__prepareCommand
{
    commandString_ = [[NSMutableString alloc] init];
    if( commandParameter_ != nil ) {
        [commandParameter_ compile];
        [commandString_ appendFormat:@"{ %@ }",[commandParameter_ parameterString]];
    }
    commandState_ = ORMMACommandStatePrepared;
}
@end

@implementation ORMMACommand

+ (ORMMACommand*)commandWithString:(NSString*)command
{
    ORMMACommand *result = [[ORMMACommand alloc] init];
    result->commandString_ = [[NSMutableString alloc] initWithString:command];
    result->commandState_  = ORMMACommandStatePrepared;    
    return result;
}

+ (ORMMACommand*)fireChangeEventCommand:(ORMMAParameter*)parameter
{     
    ORMMACommand *result = [[ORMMACommand alloc] init];
    result->commandParameter_   = parameter;
    result->commandState_       = ORMMACommandStateUndefined;
    
    [result __prepareCommand];
    
    if( result->commandState_ == ORMMACommandStatePrepared ) {
        result->commandString_ = [NSString stringWithFormat:kORMMAStringFormatForFireChangeEventCommand,result->commandString_];
    }
    
    return result;   
}

+ (ORMMACommand*)fireShakeEventCommand:(NSString*)shakeParameter
{     
    ORMMACommand *result = [[ORMMACommand alloc] init];
    result->commandString_ = [NSString stringWithFormat:kORMMAStringFormatForFireShakeEventCommand,shakeParameter];
    result->commandState_  = ORMMACommandStatePrepared;        
    return result;   
}


+ (ORMMACommand*)fireErrorEventCommand:(NSString*)message key:(NSString*)key
{
    ORMMACommand *result = [[ORMMACommand alloc] init];
    result->commandString_ = [NSString stringWithFormat:kORMMAStringFormatForFireErrorEventCommand,message,key];
    result->commandState_  = ORMMACommandStatePrepared;
    return result;   
}

+ (ORMMACommand*)nativeCallSucceededCommand
{
    ORMMACommand *result = [[ORMMACommand alloc] init];
    result->commandString_ = [NSString stringWithFormat:kORMMAStringFormatForNativeCallCompleteComand,kORMMAParameterValueForBooleanTrue];
    result->commandState_  = ORMMACommandStatePrepared;
    return result;    
}

+ (ORMMACommand*)nativeCallFailedCommand
{
    ORMMACommand *result = [[ORMMACommand alloc] init];
    result->commandString_ = [NSString stringWithFormat:kORMMAStringFormatForNativeCallCompleteComand,kORMMAParameterValueForBooleanFalse];
    result->commandState_  = ORMMACommandStatePrepared;
    return result;  
}

- (void)setCommandState:(ORMMACommandState)state
{
    commandState_ = state;
}

- (ORMMACommandState)state
{
    return commandState_;
}

- (void)setCommandResult:(id)result
{
    commandResult_ = result;
}

- (id)commandResult
{
    return commandResult_;
}

- (NSString*)stringRepresentation
{
    return commandString_;
}

@end
