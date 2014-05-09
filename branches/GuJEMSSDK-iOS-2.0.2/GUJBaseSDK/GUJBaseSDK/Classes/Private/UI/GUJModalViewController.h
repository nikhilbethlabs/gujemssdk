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
#import <UIKit/UIKit.h>
#import "GUJBase64Util.h"

@class GUJModalViewController;

@protocol GUJModalViewControllerDelegate<NSObject>

- (void)modalViewControllerWillAppear;
- (void)modalViewControllerDidAppear:(GUJModalViewController*)modalViewController;

- (void)modalViewControllerWillDisappear:(GUJModalViewController*)modalViewController;
- (void)modalViewControllerDidDisappear;

@end

@interface GUJModalViewController : UIViewController

@property (nonatomic,strong) UIImage *closeButtonImage;
@property (nonatomic,strong) id<GUJModalViewControllerDelegate> delegate;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,assign) BOOL defaultStatusBarState;

- (void)addSubviewInset:(UIView*)subview;
- (void)hideCloseButton:(BOOL)hide;
- (void)dismiss;
- (void)dismiss:(void(^)(void))completion;
@end


// the close button image as Bas64ImageDataRepresentation
#define kGUJModalViewControllerCloseBoxImage @"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"
