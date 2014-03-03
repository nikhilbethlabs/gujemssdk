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
#import "GUJNativeLocationManager.h"
#import "GUJAdConfiguration.h"

/*!
 The GUJAdURLBuilder creates an URL object needed by the ad server connection.
 Mostly GUJConstants will used for building the URL, except:
 - The User-Agent is build in GUJUtil
 - The ad server URL is provided by GUJAdConfiguration
 */
@interface GUJAdURLBuilder : NSObject

@property (nonatomic, assign) GUJBannerType         bannerType;
@property (nonatomic, assign) GUJBannerFormat       bannerFormat;
@property (nonatomic, assign) GUJBannerMarkup       bannerMarkup;
@property (nonatomic, assign) GUJAdConfiguration    *adConfiguration;
@property (nonatomic, strong) NSMutableDictionary   *urlParameter;

-(id)initWithAdConfiguration:(GUJAdConfiguration*)configuration;
/*!
 * Builds the URL and returns it as NSString representation.
 @discussion  check if all required parameters are present or leave it on developer side?
 in the current architecture the developer isn't able to pass parameters. so this will never happen.
 No excpetion will thrown: _urlParameter is allways nil.
 
 @optional If keyowrds are defined, GUJUtil will return a well formatted keyword string.
 If location manager is active and has location lat & long pass them thru the request.
 
 @result A NSString representation of the URL object
 */
- (NSString*)buildURLString;

/*!
 * Builds the URL object.
 @result The URL as NSURL
 */
- (NSURL*)buildURL;

/*!
 * Call this method to add additional URL parameters
 */
- (void)setValue:(id)value forURLParameter:(GUJURLParameter)parameter;

/*!
 * Returns the value for the requested GUJURLParameter
 @result the value of the requested parameter or nil if not exists.
 */
- (id)valueForURLParameter:(GUJURLParameter)parameter;

@end

@interface GUJAdURLBuilder (Private)
/*!
 * private method
 *
 * As discussed, the standard format should be XHTML
 * Uncomment for real validation
 */
- (NSString*)__bannerMarkupAsString;

/*!
 * private method
 *
 * (Ad_Integration_-_Mobile_AdServer_v3_2_DE_-_G+J_EMS_Mobile_20120529.doc)
 * instead of the current Documentation (Page 10), the GUJ-EMS server only
 * accepts the type 4 for a proper banner serving.
 *
 * internaly the RichMedia and Interstitial is tagged with type 3.
 * the sdk still uses this type to identify the correct markup type. [self __bannerMarkupAsString]
 *
 @discuss
 * if the type 3 is deprecated and type 4 will become a default constant,
 * the type parameter should becom optional for reqeusts.
 * on the other hand we should modify this method and [self __bannerMarkupAsString]
 * to return constants.
 *
 */
- (NSNumber*)__bannerTypeAsNumber;

/*! private method to ad parameters to the url string */
- (void)__adParameter:(NSString*)key withValue:(id)value toURLString:(NSMutableString*)urlString;
@end
