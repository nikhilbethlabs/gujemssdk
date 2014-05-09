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
/*!
 * ORMMACall parses an validates incomming ORMMA Javascript requests.
 * A call starts with the ormma protocol ormma://
 * A call can be a system call that inhibts native or sdk related methods.
 *
 */
@interface ORMMACall : NSObject

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSString *callName;
@property (nonatomic, strong) NSString *serviceCallValue;
@property (nonatomic, strong) NSMutableDictionary *callValue;
@property (nonatomic, assign) BOOL serviceCall;
@property (nonatomic, assign) BOOL ormmaCall;

/*!
 * Parses the ormmaCall parameter and cunstructs a ORMMACall which can be handled
 * by the SDK.
 */
+(ORMMACall*)parse:(NSString*)ormmaCall;

/*!
 *
 @result 1 if the current call is valid.
 */
- (BOOL)isValidCall;

/*!
 * A service call is structured like this: ormma://service?[...]
 @result 1 if the current call is a service call
 */
- (BOOL)isServiceCall;

/*!
 *
 @result 1 if the current call matches the given call identifier.
 */
- (BOOL)isCallForIdentifier:(NSString*)identifier;

/*!
 *
 @result the current call name 'nil' if the call is not valid.
 */
- (NSString*)name;

/*!
 *
 @result the current single call value. 'nil' if no value is present.
 */
- (NSString*)serviceCallValue;

/*!
 * if a call has multiple parameters: foo=bar&bar=foo
 @result a NSMutableDictionary for multiple call values
 */
- (NSMutableDictionary*)value;
@end


@interface ORMMACall(PrivateImplementation)

/*!
 *
 @result 1 if the call string is valid
 */
- (BOOL)__isORMMACall:(NSString*)call;

/*!
 *
 @result 1 if the call string is a service call
 */
- (BOOL)__isORMMAServiceCall:(NSString*)call;

/*!
 *
 @result 1 if the call string was scuccessfully parsed
 */
- (BOOL)__parseCallString:(NSString*)callString;

@end

