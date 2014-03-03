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
 * The GUJAdViewController is configured at startup and provides common
 * configuration values.
 */
@interface GUJAdConfiguration : NSObject {
 @private
    GUJBannerType       bannerType_; 
    GUJBannerType       requestedBannerType_;     
    NSError             *error_;
    NSString            *adSpaceId_;
    NSString            *adServerURL_;
    NSArray             *keywords_;
    NSMutableDictionary *customConfiguration_;    
    NSMutableDictionary *customAdServerHeaderFields_;
    NSMutableDictionary *customAdServerRequestParameters_;    
    NSTimeInterval      reloadInterval_;    
    BOOL                locationServiceDisabled_;
    BOOL                willShowAdModal_;
    BOOL                debug_;
}
/*!
 * Will result a synchronized configuration instance.
 @result A shared Singleton instance of GUJAdConfiguration
 */
+ (GUJAdConfiguration*)sharedInstance;

/*!
 * Frees and deallocates the sharedInstance object.
 * unloads all recent properties.
 */
- (void)freeInstance;

/*!
 * Sets debugging mode. Allmost needed for URL debugging.
 */
- (void)setDebug:(BOOL)debug;

/*!
 @result the current debugging state
 */
- (BOOL)debug;

/*!
 * Sets the URL of the ad server.
 * If not set, the default URL kGUJURLAdSpace will used 
 */
- (void)setAdServerURL:(NSString*)adServerURL;

/*!
 @result The actual ad server URL as Stringrepresentation
 */
- (NSString*)adServerURL;

/*!
 * This forces the SDK to show the advertisment modal
 * Also if its not an inter. ad
 */
- (void)setAdShouldShowModal:(BOOL)should;

/*!
 @result The current modal state
 */
- (BOOL)willShowAdModal;

/*!
 * Sets the system wide adspace id.
 */
- (void)setAdSpaceId:(NSString*)adSpaceId;

/*!
 @result Returns the actual adspace id.
 */
- (NSString*)adSpaceId;

/*!
 * Sets the banner type.
 * if __GUJ_SDK_FORCE_MOBILE_BANNER_FORMAT__ is defined this function will
 * be ignored.
 *
 * the banner type can change while processing the  ad server response. 
 *
 * see @requestedBannerType
 */
- (void)setBannerType:(GUJBannerType)bannerType;

/*!
 @result the actual banner type
 */
- (GUJBannerType)bannerType;


/*!
 * sets the initial requested banner type.
 * this type will be available until the intsance is released
 */
- (void)setRequestedBannerType:(GUJBannerType)bannerType;

/*!
 @result the inital requested banner type
 */
- (GUJBannerType)requestedBannerType;


/*!
 * Sets the ad reload interval.
 * If the interval is 0.0 no reload will performed. 
 * 0.0 is default and defined with kGUJDefaultAdReloadInterval 
 */
- (void)setReloadInterval:(NSTimeInterval)interval;

/*!
 @result The actual reload interval
 */
- (NSTimeInterval)reloadInterval;

/*!
 * Disables the location service at startup.
 * Other native interfaces will flout over this setting at runtime.
 * 
 */
- (void)setDisableLocationService:(BOOL)disable;

/*!
 @result Returns 0 if the location service is initial disabled.
 */
- (BOOL)locationServiceDisabled;

/*!
 * Set user defined keywords for this instance.
 * If set once, every request will use these keywords until the user nils or 
 * reinstanciates.
 */
- (void)setKeywords:(NSArray*)keywords;

/*!
 @result The actual keywords as Array
 */
- (NSArray*)keywords;

/*!
 @result The actual keywords formated with pipe (|)
 */
- (NSString*)keywordsFormatted;

/*!
 @result The actual keywords URLEncoded and formated with pipe (|) 
 */
- (NSString*)keywordsFormattedWithURLEncoding;

/*!
 @result Returns true if at least one custom header field is present
 */
- (BOOL)hasCustomAdServerHeaderFields;

/*!
 * Adds a custom HTTP-Header (key,value) to the Ad-Server-Request.
 * This headers must injected before the Server-Request is executed.
 */
- (void)addCustomAdServerHeaderField:(NSString*)name value:(NSString*)value;

/*!
 * Returns the value of an custom header field if present. otherwise nil
 @result nil if no header found
 */
- (NSString*)getCustomAdServerHeaderField:(NSString*)name;

/*!
 * Sets a bounch of header fields defined in the headerFields dictionary.
 */
- (void)setCustomAdServerHeaderField:(NSDictionary*)headerFields;

/*!
 * Removes the header by the given name.
 */
- (void)removeCustomAdServerHeaderField:(NSString*)name;

/*!
 *
 @result returns nil if no headers specified
 */
- (NSMutableDictionary*)customAdServerHeaderFields;

/*!
 @result Returns true if at least one custom parameter is present
 */
- (BOOL)hasCustomAdServerRequestParameters;

/*!
 * Adds a custom HTTP-Request parameter (key,value) to the Ad-Server-Request.
 * This headers must injected before the Server-Request is executed.
 */
- (void)addCustomAdServerRequestParameter:(NSString*)name value:(NSString*)value;

/*!
 * Returns the value of an custom request parameter if present. otherwise nil
 @result nil if no parameter where found
 */
- (NSString*)getCustomAdServerRequestParameter:(NSString*)name;

/*!
 * Sets a bounch of request parameters that are defined in the requestParameters dictionary.
 */
- (void)setCustomAdServerRequestParameters:(NSDictionary*)requestParameters;

/*!
 * Removes the request parameter by the given name.
 */
- (void)removeCustomAdServerRequestParameter:(NSString*)name;

/*!
 *
 @result returns nil if no parameters specified
 */
- (NSMutableDictionary*)customAdServerRequestParameters;

/*!
 * add an custom configuration parameter
 */
- (void)addCustomConfiguration:(id)value forKey:(NSString*)key;

/*!
 @result the value of the parameters key. nil if not present
 */
- (id)getCustomConfigurationForKey:(NSString*)key;

/*!
 @result the old value of the parameters key. nil if not present
 */
- (id)setCustomConfiguration:(id)value forKey:(NSString*)key;

/*!
 * Sets a configuration set. 
 * The internal configurations store will be replaced by this configuration set.
 */
- (void)setCustomConfiguration:(NSDictionary*)costumConfiguration;

/*!
 *
 @result the removed value. nil if not found.
 */
- (id)removeCustomConfigurationForKey:(NSString*)key;

/*!
 * a custom configuration will allow you to pass non specific parameters
 * to the adConfiguration instance.
 *
 * for example configuration parameters for 3rd party frameworks can be stored
 * here. 
 * the parameters will be available until the instance has released.
 *
 @result the current customer configuration dictionary. nil if no parameter is set.
 */
- (NSMutableDictionary*)customConfiguration;

/*!
 @result 1 if the current configuration is valid
 */
- (BOOL)isValid;

/*!
 * You should call this method directly after isValid.
 @result returns the last error of the sharedInstance.
 */
- (NSError*)error;

@end
