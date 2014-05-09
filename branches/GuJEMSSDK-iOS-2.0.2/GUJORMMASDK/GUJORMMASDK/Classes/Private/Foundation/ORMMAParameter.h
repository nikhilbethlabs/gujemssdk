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
 * The ORMMAParameter holds parameter objects that will be transformed by the
 * ORMMACommand into a Javascript Stringrepresentation.
 */
@interface ORMMAParameter : NSObject {
@private
    NSMutableDictionary *parameters_;
    NSMutableString     *parameterString_;
}

/*!
 * { key: object }
 @result An ORMMAParameter with a string key and AnyObject as value
 */
+(ORMMAParameter*)parameter:(id)parameter forKey:(NSString*)key;

/*!
 * { key: 'value' }
 @result An ORMMAParameter with a string key and string value
 */
+(ORMMAParameter*)stringParameter:(NSString*)parameter forKey:(NSString*)key;

/*!
 * { width: %f, height: %f }
 @result An ORMMAParameter with a string key and stringrepresentation of the size parameter
 */
+(ORMMAParameter*)sizeParameter:(CGSize)size forKey:(NSString*)key;

/*!
 * { x: %f, y: %f }
 @result An ORMMAParameter with a string key and stringrepresentation of the point parameter
 */
+(ORMMAParameter*)pointParameter:(CGPoint)point forKey:(NSString*)key;

/*!
 * { x: %f, y: %f, width: %f, height: %f }
 @result An ORMMAParameter with a string key and stringrepresentation of the rect parameter
 */
+(ORMMAParameter*)rectParameter:(CGRect)rect forKey:(NSString*)key;

/*!
 * { key: true/false }
 @result An ORMMAParameter with a string key and stringrepresentation of the boolean parameter
 */
+(ORMMAParameter*)boolParameter:(BOOL)boolean forKey:(NSString*)key;

/*!
 * compiles the given parameters into a string object.
 */
- (void)compile;

/*!
 * returns the actual parameter as StringRrepresentation. Calls compile.
 @result The ORMMAParameter as String
 */
- (NSString*)parameterString;

@end

@interface ORMMAParameter(PrivateImplementation)

/*!
 * Add an object to the current parameter set
 */
- (void)__addParameter:(id)parameter forKey:(NSString*)key;

/*!
 * Add a CGSize to the current parameter set
 */
- (void)__addSizeParameter:(CGSize)size forKey:(NSString*)key;

/*!
 * Add a CGPoint to the current parameter set
 */
- (void)__addPointParameter:(CGPoint)point forKey:(NSString*)key;

/*!
 * Add a CGRect to the current parameter set
 */
- (void)__addRectParameter:(CGRect)rect forKey:(NSString*)key;

/*!
 * Add a BOOL to the current parameter set
 */
- (void)__addBoolParameter:(BOOL)boolean forKey:(NSString*)key;

@end