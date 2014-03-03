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

/*!
 * ORMMACommandState
 */
enum {
    ORMMACommandStateUndefined,
    ORMMACommandStatePrepared,
    ORMMACommandStateSucceed,
    ORMMACommandStateFailed
}; typedef NSUInteger ORMMACommandState;

/*!
 * ORMMACommand builds an ORMMA command string that will be used by 
 * the ORMMAJavascriptBridge for Javascript communications.
 *
 */
@interface ORMMACommand : NSObject {
  @private
    id                  commandResult_;
    ORMMACommandState   commandState_;
    ORMMAParameter      *commandParameter_;
    NSMutableString     *commandString_;
}

/*!
 *
 @result An ORMMACommand build by a string
 */
+ (ORMMACommand*)commandWithString:(NSString*)command;

/*!
 * window.ormmaview.fireChangeEvent( { state: 'value' } );
 *
 @result An ORMMACommand build by a ORMMAParameter object
 */
+ (ORMMACommand*)fireChangeEventCommand:(ORMMAParameter*)parameter;

/*!
 * window.ormmaview.fireShakeEvent( { 'value' } );
 *
 @result An ORMMACommand build by a sahke property string
 */
+ (ORMMACommand*)fireShakeEventCommand:(NSString*)shakeParameter;

/*!
 * window.ormmaview.fireErrorEvent( 'key', 'message' );
 *
 @result An ORMMACommand build by a message and key string
 */
+ (ORMMACommand*)fireErrorEventCommand:(NSString*)message key:(NSString*)key;

/*!
 * window.ormmaview.nativeCallComplete( true );
 *
 @result An ORMMACommand with a boolean true value
 */
+ (ORMMACommand*)nativeCallSucceededCommand;

/*!
 * window.ormmaview.nativeCallComplete( false );
 *
 @result An ORMMACommand with a boolean false value
 */
+ (ORMMACommand*)nativeCallFailedCommand;

/*!
 * overrides the current ORMMACommandState
 */
- (void)setCommandState:(ORMMACommandState)state;

/*!
 *
 @result the current ORMMACommandState
 */
- (ORMMACommandState)state;

/*!
 * overrides the current ORMMACommand result
 */
- (void)setCommandResult:(id)result;

/*!
 *
 @result the current ORMMACommand result as NSObject
 */
- (id)commandResult;

/*!
 *
 @result A Stringrepresentation of the current ORMMACommand
 */
- (NSString*)stringRepresentation;
@end

@interface ORMMACommand(PrivateImplementation)

/*!
 * Build and prepares the current command for execution.
 */
- (void)__prepareCommand;
@end
