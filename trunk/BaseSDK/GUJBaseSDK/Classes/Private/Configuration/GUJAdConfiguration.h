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
    GUJBannerType   bannerType_; 
    NSError         *error_;
    NSString        *adSpaceId_;
    NSString        *adServerURL_;
    NSArray         *keywords_;
    NSTimeInterval  reloadInterval_;    
    BOOL            locationServiceDisabled_;
    BOOL            willShowAdModal_;
    BOOL            debug_;
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
 */
- (void)setBannerType:(GUJBannerType)bannerType;

/*!
 @result the actual banner type
 */
- (GUJBannerType)bannerType;

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
 @result 1 if the current configuration is valid
 */
- (BOOL)isValid;

/*!
 * You should call this method directly after isValid.
 @result returns the last error of the sharedInstance.
 */
- (NSError*)error;

@end
