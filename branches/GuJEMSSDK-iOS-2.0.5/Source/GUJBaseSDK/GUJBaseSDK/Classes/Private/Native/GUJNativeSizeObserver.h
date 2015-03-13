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
#import "GUJNativeAPIInterface.h"
#import "_GUJAdView.h"

@interface GUJNativeSizeObserver : GUJNativeAPIInterface

@property (nonatomic, assign) CGSize        lastSuperviewSize;
@property (nonatomic, assign) CGSize        lastWindowSize;
@property (nonatomic, assign) CGSize        lastAdViewSize;
@property (nonatomic, strong) UIView        *superview;
@property (nonatomic, strong) UIWindow      *window;
@property (nonatomic, strong) _GUJAdView    *adView;
@property (nonatomic, strong) NSRunLoop     *runLoop;
@property (nonatomic, strong) NSTimer       *timer;

+(GUJNativeSizeObserver*)sharedInstance;

- (void)listenForResizingAdView:(_GUJAdView*)adView;
- (void)stopListeningForResizingAdView;

- (void)listenForResizingSuperview:(UIView*)view;
- (void)stopListeningForResizingSuperview;

- (void)listenForScreenResizing;
- (void)stopListeningForScreenResizing;

@end