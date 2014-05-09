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
#import "ORMMACommand.h"
#import "GUJDeviceCapabilities.h"
#import "ORMMACall.h"
#import "ORMMACallHandler.h"
#import "ORMMAWebBrowser.h"
#import "GUJNativeLocationManager.h"

@class ORMMAView;

@interface ORMMAJavaScriptBridge : NSObject

@property (nonatomic, strong) ORMMAWebBrowser   *internalWebBrowser;
@property (nonatomic, strong) ORMMAView         *ormmaView;
@property (nonatomic, strong) NSString          *ormmaSupportString;
@property (nonatomic, assign) BOOL              ormmaInit;
@property (nonatomic, assign) BOOL              ormmaSetup;
@property (nonatomic, assign) BOOL              shouldReportErrors;

- (id)initWithAdView:(id)adView;
- (void)attachToAdView:(id)adView;
- (BOOL)isAttachedToAdView;
- (BOOL)isAttachedToAdView:(id)adView;
- (ORMMACommandState)executeCommand:(ORMMACommand*)command;
- (void)unload;
- (BOOL)handleRequest:(NSURLRequest *)request;
- (void)initializeORMMAAndDisplayAdView;
@end

@interface ORMMAJavaScriptBridge(PrivateInitialSequence)
- (void)__performInitialORMMASequence;
@end

@interface ORMMAJavaScriptBridge(PrivateNotificationHandling)
- (void)__nativeNotification:(NSNotification*)notification;
@end

@interface ORMMAJavaScriptBridge(PrivateORMMACallHandling)
- (void)__distributeError:(NSError*)error;
- (BOOL)__handleServiceCall:(ORMMACall*)serviceCall;
- (void)__handleCall:(ORMMACall*)call;
@end


