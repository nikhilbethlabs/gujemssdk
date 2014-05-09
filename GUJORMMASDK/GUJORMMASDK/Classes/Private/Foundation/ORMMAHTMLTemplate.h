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
#import "ORMMAResourceBundleManager.h"
#import "GUJAdData.h"

/*!
 * ORMMAHTMLTemplate builds an HTML page for displaying in the ad container.
 * Required data will load from the ORMMAResourceBundleManager
 */
@interface ORMMAHTMLTemplate : NSObject

@property (nonatomic, strong) ORMMAResourceBundleManager *ormmaResourceBundle;
@property (nonatomic, strong) NSString *ormmaTemplate;
/*!
 * Renders the template. Adds Javascript and data that is passed by the adData parameter
 @result a string representaion of the actual HTML page
 */
+ (NSString*)htmlTemplateWithAdData:(GUJAdData*)adData;

/*!
 * Releases the current instance and all of its objects. nils sharedInstance at the end.
 */
- (void)freeInstance;

@end
