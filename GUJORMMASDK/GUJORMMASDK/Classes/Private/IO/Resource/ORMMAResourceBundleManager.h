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
 * ORMMAResourceBundleManager loads required Resources like Javascripts, HTML-Templates and Images.
 */
@interface ORMMAResourceBundleManager : NSObject

@property (nonatomic, strong) NSBundle  *resourceBundle;
@property (nonatomic, strong) NSError   *error;
@property (nonatomic, assign) BOOL      loaded;

/*!
 *
 @result A instance for the given bundle name. nils previous instances
 */
+ (ORMMAResourceBundleManager*)instanceForBundle:(NSString*)bundleName;

/*!
 * frees the current instance and its objects
 */
- (void)freeInstance;

/*!
 *
 @result a string resource loaded by the given resource
 */
- (NSString*)loadStringResource:(NSString*)resourceName ofType:(NSString*)type;

/*!
 *
 @result a string resource loaded by the given resource
 */
- (NSString*)loadStringResource:(NSString*)resourceName;

/*!
 *
 @result a image resource loaded by the given resource
 */
- (UIImage*)loadImageResource:(NSString*)resourceName ofType:(NSString*)type;

/*!
 *
 @result a image resource loaded by the given resource
 */
- (UIImage*)loadImageResource:(NSString*)resourceName;
@end


@interface ORMMAResourceBundleManager(PrivateImplementation)

/*!
 * load an NSResource by the given bundleName
 */
- (void)__loadResourceBundle:(NSString*)bundleName;

/*!
 * load an NSResource with the default bundle name ( defined with kORMMAResourceBundleName)
 */
- (void)__loadResourceBundle;

@end
