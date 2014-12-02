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
#import "GUJMASTAdViewRef.h"
#import "GUJAdConfiguration.h"
#import "GUJAdView.h"
#import "GUJAdData.h"
#import "GUJAdViewEvent.h"
#import "ORMMAWebBrowser.h"

/**
 * GUJmOceanBridge
 *
 * Communicates with the mOcean Ad Server.
 *
 * Implements the mOcean MAST AdView delegate protocol and converts all delegate
 * calls to the GUJAdViewControllerDelegate protocol.
 *
 * iPhone Traget: >= __IPHONE_4_0
 */
@interface GUJmOceanBridge : NSObject<NSObject> {
  @private
    id                      mastAdView_;
    UIView                  *mastAdViewInterstitialView_;
    GUJAdView               *gujAdView_;
    GUJMASTAdViewRef        *mastAdViewRef_;
    id<GUJAdViewDelegate>   adViewDelegate_;
}

/**
 *
 @result the current Bridge instance.
 */
+ (GUJmOceanBridge*)sharedInstance;

/**
 * Instanciate and assign to a GUJAdView.
 * 
 @result the current Bridge instance.
 */
+ (GUJmOceanBridge*)instanceWithGUJAdView:(GUJAdView*)adView;

/**
 *
 @result TRUE if the SDK is configured for mOcean MAST requests. No if not.
 */
+ (BOOL)isConfiguredForMASTAdRequest;

/**
 * Releases the current GUJmOceanBridge instance
 */
- (void)freeInstance;

/**
 * performs the MAST AdRequest (mOcean AdServer)
 */
- (void)performMASTAdRequest;

@end
