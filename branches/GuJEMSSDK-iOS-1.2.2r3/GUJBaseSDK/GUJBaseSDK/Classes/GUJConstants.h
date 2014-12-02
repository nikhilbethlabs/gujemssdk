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
#import "GUJBaseSDKVersion.h"

#ifndef GEAdBaseSDK_GUJConstants_h
#define GEAdBaseSDK_GUJConstants_h

#ifdef DEBUG
    #define kGUJEMS_Debug
#endif

#pragma mark global configuration constants
#define __GUJ_SDK_FORCE_XHTML_OUTPUT__
#define __GUJ_SDK_FORCE_MOBILE_BANNER_FORMAT__

//#define __GUJ_SDK_ADD_IP_ADDRESS_TO_REQUEST_HEADER__
//#define __GUJ_SDK_ENABLE_INTERSTITIAL_FORMAT_CHECK__

#define kGUJDefaultStatusBarHeight                  20.0

#pragma mark time-out and interval
#define kGUJTimeoutForNativeInstanciation           3.0
#define kGUJTimeoutForLoadNotification              2.0
#define kGUJServerConnectionTimeout                 30.0
#define kGUJDefaultAdReloadInterval                 0.0 // no reload
#define kGUJDefaultAdViewResizeAndDisplayDelay      0.25

#
#pragma mark foundation
#
#define kEmptyString                                @""
#define kWhiteSpaceString                           @" "
#define kGUIJStringFormatForLocationDegrees         @"%+.6f"
#define kGUIJStringFormatForHeadingDegrees          @"%+.1f"

#
#pragma mark AdView dimensions
#
#define kGUJAdViewDimensionDefault                  CGRectMake(0.0,0.0,1.0,1.0)
#define kGUJAdViewDimensionPlaceHolder_iPhone       CGRectMake(0.0,0.0,320.0,50.0)
#define kGUJAdViewDimensionPlaceHolder_iPad         CGRectMake(0.0,0.0,728.0,90.0)

#
#pragma mark URL-Builder
#
#define kGUJHTTPProtocolIdentifier                  @"http://"
#define kGUJURLParameterFormatStart                 @"?%@=%@"

#define kGUJURLParameterKeyValueFormat              @"%@=%@"
#define kGUJURLParameterFormat                      @"&%@=%@"

#define kGUJURLAdSpaceTest                          @"http://guj.somo.de"
#define kGUJURLAdSpace                              @"http://vfdeprod.amobee.com"

#define kGUIJURLPathForBanner                       @"/upsteed/wap/adrequest"
#define kGUIJURLPathForRichMedia                    @"/upsteed/wap/adrequest"
#define kGUIJURLPathForInterstitial                 @"/upsteed/wap/adrequest"

#define kGUJBannerMarkupXML                         @"bannerxml"
#define kGUJBannerMarkupXHTML                       @"xhtml"

#define kGUJURLParameterTyp                         @"tp"
#define kGUJURLParameterPartner                     @"prt"
#define kGUJURLParameterAdSpace                     @"as"
#define kGUJURLParameterMarkup                      @"mu"
#define kGUJURLParameterTimestamp                   @"t"
#define kGUJURLParameterIPAddress                   @"i"
#define kGUJURLParameterKeyword                     @"kw"
#define kGUJURLParameterLatitude                    @"lat"
#define kGUJURLParameterLongitude                   @"long"
#define kGUJURLParameterUserId                      @"userId"

#define kGUJURLParameterPartnerDefault              @"G+J"

#define kGUJSizeOfUrlParameterKeys                  10

#define kGUJWebViewAboutBlankIdentifier             @"about:blank"

#
#pragma mark error domains
#
#define kRedefinedWebKitErrorDomain                 @"WebKitErrorDomain"
#define kGUJConfigurationErrorDomain                @"GUJConfigurationErrorDomain"
#define kGUJServerConnectionErrorDomain             @"GUJServerConnectionErrorDomain"
#define kGUJLocationManagerErrorDomain              @"GUJLocationManagerErrorDomain"
#define kGUJBannerXMLParserErrorDomain              @"GUJBannerXMLParserErrorDomain"
#define kGUJNativeCalendarManagerErrorDomain        @"GUJNativeCalendarManagerErrorDomain"
#define kGUJNativeAudioPlayerErrorDomain            @"GUJNativeAudioPlayerErrorDomain"
#define kGUJNativeEmailComposerErrorDomain          @"GUJNativeEmailComposerErrorDomain"
#define kGUJNativeSMSComposerErrorDomain            @"kGUJNativeSMSComposerErrorDomain"

#
#pragma mark error codes
#
// general and undefined error id
#define GUJ_ERROR_CODE_GENERAL_UNDEFINED            -1000
#define GUJ_ERROR_CODE_UNABLE_TO_LOAD               -1001
#define GUJ_ERROR_CODE_UNABLE_TO_SAVE               -1002
#define GUJ_ERROR_CODE_UNABLE_TO_ACCESS             -1003
#define GUJ_ERROR_CODE_UNABLE_TO_COMPLETE           -1004
#define GUJ_ERROR_CODE_COMMAND_FAILED_OR_UNKNOWN    -1005
#define GUJ_ERROR_CODE_UNAVAILABLE                  -1006
#define GUJ_ERROR_CODE_FAILED_TO_ASSIGN_OBJ         -1007

// If the AdSpace Id is not defined
#define GUJ_ERROR_CODE_ADSPACE_ID                   1

// A general error code for incorrect NSURLConnection<?> calls. See UserInfo for Details
#define GUJ_ERROR_CODE_SERVER_ERROR                 1005
#define GUJ_ERROR_CODE_INCORRECT_AD_FORMAT          1006
#define GUJ_ERROR_CODE_NOT_REQUESTED_AD_FORMAT      1007
#define GUJ_ERROR_CODE_INVALID_AD_FORMAT_HEADER     1008

// A general error code for incorrect Core Location calls. See UserInfo for Details
#define GUJ_ERROR_CODE_CORE_LOCATION                400

#define GUJ_ERROR_CALENDAR_UNAVAILABLE              2003

#
#pragma mark networking
#
#define kNetworkInterfaceIdentifierForTypeLo0       @"lo0"
#define kNetworkInterfaceIdentifierForTypeEn0       @"en0"
#define kNetworkInterfaceIdentifierForTypePdp_ip0   @"pdp_ip0"
#define kNetworkUndefinedInterfaceAddress           @"0.0.0.0"

#
#pragma mark sdk configuration
#
#define kGUJApplicationAdSpaceUUIDKey               @"_GUJ_ADSPACE_UUID"

#
#pragma mark sdk identification and types
#
#define kGUJDeviceTypeStringiPhone                  @"iPhone"
#define kGUJDeviceTypeStringiPad                    @"iPad"
#define kGUJDeviceTypeStringiPod                    @"iPod"

#
#pragma mark native device notifications
#
#define GUJDeviceUnkownNotification                 @"GUJDeviceUnkownNotification"
#define GUJDeviceErrorNotification                  @"GUJDeviceErrorNotification" 
#define GUJDeviceNetworkChangedNotification         @"GUJDeviceNetworkChangedNotification" 
#define GUJDeviceOrientationChangedNotification     @"GUJDeviceOrientationChangedNotification"
#define GUJDeviceKeyboardStateChangedNotification   @"GUJDeviceKeyboardStateChangedNotification" //UU
#define GUJDeviceLocationChangedNotification        @"GUJDeviceLocationChangedNotification"
#define GUJDeviceScreenSizeChangedNotification      @"GUJDeviceScreenSizeChangedNotification"
#define GUJDeviceSuperviewSizeChangedNotification   @"GUJDeviceSuperviewSizeChangedNotification"
#define GUJDeviceHeadingChangedNotification         @"GUJDeviceHeadingChangedNotification"
#define GUJDeviceTiltNotification                   @"GUJDeviceTiltNotification"
#define GUJDeviceShakeNotification                  @"GUJDeviceShakeNotification"
#define GUJDeviceCameraEventNotification            @"GUJDeviceCameraEventNotification"
#define GUJNativeAudioPlayerNotification            @"GUJNativeAudioPlayerNotification"
#define GUJNativeVideoPlayerNotification            @"GUJNativeVideoPlayerNotification"

#
#pragma mark banner notifications
#
#define GUJBannerUnkownNotification                 @"GUJBannerUnkownNotification"
#define GUJBannerReadyNotification                  @"GUJBannerReadyNotification"
#define GUJBannerResponseNotification               @"GUJBannerResponseNotification"
#define GUJBannerSizeChangeNotification             @"GUJBannerSizeChangeNotification"
#define GUJBannerStateChangedNotification           @"GUJBannerStateChangedNotification"
#define GUJBannerViewableChangedNotification        @"GUJBannerViewableChangedNotification"

#
#
#pragma mark Class dependend constants
#
#

#
#pragma mark GUJServerConnection constants
#
#define kGUJServerConnectionHTTPHeaderFieldKeyForUserId                     @"userId"
#define kGUJServerConnectionHTTPHeaderFieldKeyForUserAgent                  @"User-Agent"
#define KGUJServerConnectionAdditionalHTTPHeaderFlightsFormat               @"Flights-Format"
#define KGUJServerConnectionAdditionalHTTPHeaderEmptyFlightsFormatBody      @"[]"

#define KGUJServerConnectionHTTPHeaderFieldValueForMobileBanner             @"[mobilebanner]"
#define KGUJServerConnectionHTTPHeaderFieldValueForMobileBannerImageOnly    @"[mobilebannerimageonly]"
#define KGUJServerConnectionHTTPHeaderFieldValueForMobileBannerExpandable   @"[mobileexpandabalebanner]"
#define KGUJServerConnectionHTTPHeaderFieldValueForInterstitial             @"[interstitial]"

#
#pragma mark GUJDeviceCapabilities constants
#
#define kGUJSystemClassForNetworkDeviceCapability                       @"UIDevice"
#define kGUJSystemClassForPhoneDeviceCapability                         @"UIDevice"
#define kGUJSystemClassForSMSDeviceCapability                           @"MFMessageComposeViewController"
#define kGUJSystemClassForEmailDeviceCapability                         @"MFMailComposeViewController"
#define kGUJSystemClassForTiltDeviceCapability                          @"UIAccelerometer"
#define kGUJSystemClassForScreenSizeDeviceCapability                    @"UIDevice"
#define kGUJSystemClassForShakeDeviceCapability                         @"UIAccelerometer"
#define kGUJSystemClassForOrientationDeviceCapability                   @"UIDevice"
#define kGUJSystemClassForHeadingDeviceCapability                       @"CLLocationManager"
#define kGUJSystemClassForLocationDeviceCapability                      @"CLLocationManager"
#define kGUJSystemClassForMapKitDeviceCapability                        @"MKMapView"
#define kGUJSystemClassForCalendarDeviceCapability                      @"EKEvent"
#define kGUJSystemClassForCameraDeviceCapability                        @"UIImagePickerController"
#define kGUJSystemClassForNativeAudioDeviceCapability                   @"AVAudioPlayer"
#define kGUJSystemClassForNativeVideoDeviceCapability                   @"MPMoviePlayerController"

#define kGUJNativeFrameworkBridgeClassForNetworkDeviceCapability        @"GUJNativeNetworkObserver"
#define kGUJNativeFrameworkBridgeClassForPhoneDeviceCapability          @"GUJNativePhoneCall"
#define kGUJNativeFrameworkBridgeClassForSMSDeviceCapability            @"GUJNativeSMSComposer"
#define kGUJNativeFrameworkBridgeClassForEmailDeviceCapability          @"GUJNativeEmailComposer"
#define kGUJNativeFrameworkBridgeClassForTiltDeviceCapability           @"GUJNativeTiltObserver"
#define kGUJNativeFrameworkBridgeClassForScreenSizeDeviceCapability     @"GUJNativeSizeObserver"
#define kGUJNativeFrameworkBridgeClassForShakeDeviceCapability          @"GUJNativeShakeObserver"
#define kGUJNativeFrameworkBridgeClassForOrientationDeviceCapability    @"GUJNativeOrientationManager"
#define kGUJNativeFrameworkBridgeClassForHeadingDeviceCapability        @"GUJNativeLocationManager"
#define kGUJNativeFrameworkBridgeClassForLocationDeviceCapability       @"GUJNativeLocationManager"
#define kGUJNativeFrameworkBridgeClassForMapKitDeviceCapability         @"GUJNativeMapView"
#define kGUJNativeFrameworkBridgeClassForCalendarDeviceCapability       @"GUJNativeCalendarManager"
#define kGUJNativeFrameworkBridgeClassForCameraDeviceCapability         @"GUJNativeCamera"
#define kGUJNativeFrameworkBridgeClassForNativeAudioDeviceCapability    @"GUJNativeAudioPlayer"
#define kGUJNativeFrameworkBridgeClassForNativeVideoDeviceCapability    @"GUJNativeVideoPlayer"

#
#pragma mark Heading defaults
#
#define GUJNativeLocationManagerHeadingAccuracy   90 // 90 Degrees

#
#pragma mark PhoneCall formatter
#
#define kGUJNativePhoneCallStringFormatForCall      @"tel:%@"
#define kGUJNativePhoneCallStringFormatForPrompt    @"telprompt:%@" 

#
#pragma mark Accelerometer defaults
#
#define kGUJNativeAccelerometerManagerFreeThreshold     0.25
#define kGUJNativeAccelerometerManagerShakeThreshold    0.75
#define kGUJNativeAccelerometerIntensityFilter          1.8
#define kGUJNativeAccelerometerManagerTiltThreshold     0.2

#endif
