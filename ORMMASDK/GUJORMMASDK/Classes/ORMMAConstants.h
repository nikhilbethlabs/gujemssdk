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
#ifndef GUJORMMASDK_ORMMAConstants_h
#define GUJORMMASDK_ORMMAConstants_h

#
#pragma mark ormma 
#
#define kORMMAProtocolIdentifier                        @"ormma://"
#define kORMMAServiceCallIdentifier                     @"service?"
#define kORMMAURLLocalhost                              @"http://localhost/?salt=%i"

#define kORMMABridgeParameterName                       @"name"
#define kORMMABridgeParameterEnabled                    @"enabled"


#define kORMMAJavascriptTypeOfOrmmaView                 @"typeof ormmaview"
#define kORMMAJavascriptObejctIdentifier                @"object"

#define kORMMAInterstitialDefaultTimeout                7

#
#pragma globale ormma string formats
#
#define kORMMAStringFormatForSizeParameter              @"{ width: %f, height: %f }"
#define kORMMAStringFormatForPointParameter             @"{ x: %f, y: %f }"
#define kORMMAStringFormatForRectParameter              @"{ x: %f, y: %f, width: %f, height: %f }"
#define kORMMAStringFormatForLocationParameter          @"{lat: %@, lon: %@, acc: %@}"
#define kORMMAStringFormatForShakeParameter             @"{interval: %f, intensity: %f}"
#define kORMMAStringFormatForTiltParameter              @"{x: %f, y: %f, z: %f}"

#define kORMMCalendarJavascriptDateFormat               @"yyyyMMddHHmm"

#
#pragma mark parameter key and values
#
#define kORMMAParameterKeyForSizeWidth                  @"width"
#define kORMMAParameterKeyForSizeHeight                 @"height"
#define kORMMAParameterKeyForOriginX                    @"x"
#define kORMMAParameterKeyForOriginY                    @"y"
#define kORMMAParameterKeyForOriginTop                  @"top"
#define kORMMAParameterKeyForOriginLeft                 @"left"
#define kORMMAParameterKeyForURL                        @"url"


#
#pragma mark audio / video keys
#
#define kORMMAParameterKeyForAudio                      @"audio"
#define kORMMAParameterKeyForAutoPlay                   @"autoplay"
#define kORMMAParameterKeyForControls                   @"controls"
#define kORMMAParameterKeyForLoop                       @"loop"
#define kORMMAParameterKeyForControls                   @"controls"
#define kORMMAParameterKeyForStartStyle                 @"startStyle"
#define kORMMAParameterKeyForStopStyle                  @"stopStyle"

#define kORMMAParameterKeyForReady                      @"ready"
#define kORMMAParameterKeyForLevel1                     @"level-1"
#define kORMMAParameterKeyForLevel2                     @"level-2"
#define kORMMAParameterKeyForLevel3                     @"level-3"
#define kORMMAParameterKeyForSupports                   @"supports"
#define kORMMAParameterKeyForState                      @"state"
#define kORMMAParameterKeyForViewable                   @"viewable"
#define kORMMAParameterKeyForSize                       @"size"
#define kORMMAParameterKeyForDefaultPosition            @"defaultPosition"
#define kORMMAParameterKeyForMaxSize                    @"maxSize"
#define kORMMAParameterKeyForExpandProperties           @"expandProperties"

#define kORMMAParameterKeyForHeading                    @"heading"
#define kORMMAParameterKeyForKeyboardState              @"keyboardState"
#define kORMMAParameterKeyForLocation                   @"location"
#define kORMMAParameterKeyForNetwork                    @"network"
#define kORMMAParameterKeyForOrientation                @"orientation"
#define kORMMAParameterKeyForRotation                   @"rotation"
#define kORMMAParameterKeyForScreenSize                 @"screenSize"
#define kORMMAParameterKeyForShakeProperties            @"shakeProperties"
#define kORMMAParameterKeyForShake                      @"shake"
#define kORMMAParameterKeyForTilt                       @"tilt"
#define kORMMAParameterKeyForTiltChange                 @"tiltChange"
#define kORMMAParameterKeyForCacheRemaining             @"cacheRemaining"

#define kORMMAParameterValueForStateLoading             @"loading"
#define kORMMAParameterValueForStateDefault             @"default"
#define kORMMAParameterValueForStateResized             @"resized"
#define kORMMAParameterValueForStateExpanded            @"expanded"
#define kORMMAParameterValueForStateHidden              @"hidden"

#define kORMMAParameterValueForCommandOpen              @"open"
#define kORMMAParameterValueForCommandClose             @"close"
#define kORMMAParameterValueForCommandHide              @"hide"
#define kORMMAParameterValueForCommandShow              @"show"
#define kORMMAParameterValueForCommandResize            @"resize"
#define kORMMAParameterValueForCommandExpand            @"expand"

#define kORMMAParameterValueForCommandAudio             @"audio"
#define kORMMAParameterValueForCommandVideo             @"video"
#define kORMMAParameterValueForCommandEmail             @"email"
#define kORMMAParameterValueForCommandSMS               @"sms"
#define kORMMAParameterValueForCommandPhone             @"phone"
#define kORMMAParameterValueForCommandCalendar          @"calendar"
#define kORMMAParameterValueForCommandMap               @"openMap"
#define kORMMAParameterValueForCommandCamera            @"camera"

#define kORMMAParameterValueForBooleanTrue              @"true"
#define kORMMAParameterValueForBooleanFalse             @"false"


#
#pragma mark network ident
#
#define kORMMANetworkIdentifierForWifi                  @"wifi"
#define kORMMANetworkIdentifierForCellular              @"cell"
#define kORMMANetworkIdentifierForOffline               @"none"


#
#pragma mark javascript command strings
#
#define kORMMACommandStringForSignalReady               @"ormma.signalReady();"
#define kORMMAStringFormatForFireChangeEventCommand     @"window.ormmaview.fireChangeEvent( %@ );"
#define kORMMAStringFormatForFireShakeEventCommand      @"window.ormmaview.fireShakeEvent( %@ );"
#define kORMMAStringFormatForFireErrorEventCommand      @"window.ormmaview.fireErrorEvent( '%@', '%@' );"
#define kORMMAStringFormatForNativeCallCompleteComand   @"window.ormmaview.nativeCallComplete( %@ );"


#
#pragma makr html teplate token
#
#define kORMMAHTMLTemplateJavascriptToken               @"<!--ORMMA-JAVASCRIPT-->"
#define kORMMAHTMLTemplateJavascriptBridgeToken         @"<!--ORMMA-IOS-BRIDGE-JAVASCRIPT-->"
#define kORMMAHTMLTemplateInjectedJavascriptToken       @"<!--INJECTED-JAVASCRIPT-CONTENT-->"
#define kORMMAHTMLTemplateAdContentToken                @"<!--AD-CONTENT-->"


#
#pragma mark resources
#
#define kORMMAResourceBundleName                        @"ORMMAResourceBundle"
#define kORMMAResourceNameForHTMLStub                   @"ORMMA_HTML_Stub.html"
#define kORMMAResourceNameForORMMAJavascript            @"ormma.js"
#define kORMMAResourceNameForORMMAJavascriptBridge      @"ormma_ios_bridge.js"

#define kORMMAResourceNameForBackImage                  @"back.png"
#define kORMMAResourceNameForForwardImage               @"forward.png"
#define kORMMAResourceNameForRefreshImage               @"refresh.png"
#define kORMMAResourceNameForOpenBrowserImage           @"openbrowser.png"
#define kORMMAResourceNameForCloseImage                 @"close.png"
#define kORMMAResourceNameForCloseBoxImage              @"closebox.png"


#
#pragma mark error domains
#
#define kORMMACallErrorDomain                           @"ORMMACallErrorDomain"
#define kORMMAResourceBundleErrorDomain                 @"ORMMAResourceBundleErrorDomain"
#define kORMMAJavaScriptBridgeErrorDomain               @"ORMMAJavaScriptBridgeErrorDomain"
#define kORMMAViewErrorDomain                           @"ORMMAViewErrorDomain"
#define kORMMAWebBrowserErrorDomain                     @"ORMMAWebBrowserErrorDomain"

#
#pragma mark ormma error codes
#
#define ORMMA_ERROR_CODE_UNKNOWN_BANNER_FORMAT          9000
#define ORMMA_ERROR_CODE_UNABLE_TO_CREATE_AD            9001
#define ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE           9002
#define ORMMA_ERROR_CODE_ILLEGAL_BANNER_STATE           9003
#endif
