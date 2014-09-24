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
#import "GUJModalViewController.h"

@implementation GUJModalViewController

- (void)__dismissSelf
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)__createUI
{
    CGRect frame = [GUJUtil frameOfKeyWindow];
    if(( [GUJUtil isLandscapeLayout] && ( frame.size.width < frame.size.height ) ) ||
       ( [GUJUtil isPortraitLayout]  && ( frame.size.width > frame.size.height ) )
       ) {
        frame = CGRectMake(frame.origin.x,frame.origin.y,frame.size.height,frame.size.width);
    }
    
    self.view = [[UIView alloc] initWithFrame:frame];
    [self.view setBackgroundColor:[UIColor blackColor]];
    // create close button
    if( ![self closeButton].hidden ) {
        NSData *imageData       = [GUJBase64Util base64DataFromString:kGUJModalViewControllerCloseBoxImage];
        if( imageData && [imageData length] > 0 ) {
            [self setCloseButtonImage:[UIImage imageWithData:imageData]];
        }
        [self setCloseButton:[UIButton buttonWithType:UIButtonTypeCustom]];
        if( [self closeButtonImage] ) {
            [[self closeButton] setFrame:CGRectMake(self.view.frame.size.width-[self closeButtonImage].size.width,
                                                    5.0f,
                                                    [self closeButtonImage].size.width,
                                                    [self closeButtonImage].size.height)
             ];
            [[self closeButton] setImage:[self closeButtonImage] forState:UIControlStateNormal];
        } else { // if we can not load the image data fall back to an simple text 'x'
            [[self closeButton] setFrame:CGRectMake(self.view.frame.size.width-15, 5, 15, 15)];
            [[self closeButton] setTitle:@"x" forState:UIControlStateNormal];
        }
        
        [[self closeButton] addTarget:self action:@selector(__dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:[self closeButton]];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self __createUI];
    }
    return self;
}

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dismiss:(void(^)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (BOOL)prefersStatusBarHidden {
    return [UIApplication sharedApplication].statusBarHidden;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
#pragma unused(animated)
    [self setDefaultStatusBarState:[UIApplication sharedApplication].statusBarHidden];
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(modalViewControllerWillAppear)] ) {
        [[self delegate] modalViewControllerWillAppear];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
#pragma unused(animated)
    // use defaultStatusBarState_ in extended classes here
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(modalViewControllerDidAppear:)] ) {
        [[self delegate] modalViewControllerDidAppear:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
#pragma unused(animated)
    // use defaultStatusBarState_ in extended classes here
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(modalViewControllerWillDisappear:)] ) {
        [[self delegate] modalViewControllerWillDisappear:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
#pragma unused(animated)
    if( [GUJUtil typeIsNotNil:[self delegate] andRespondsToSelector:@selector(modalViewControllerDidDisappear)] ) {
        [[self delegate] modalViewControllerDidDisappear];
    }
}

#pragma mark public methods
- (void)addSubviewInset:(UIView*)subview
{
    float heightOffset  = 0.0f;
    if( [self closeButtonImage] ) {
        heightOffset = [self closeButtonImage].size.height;
    } else {
        heightOffset = 15.0f;
    }
    
    float subViewHeight = (subview.frame.size.height+heightOffset/4.0f);
    float windowHeight  = (self.view.frame.size.height-heightOffset/4.0f);
    
    float insetWidth    = 0.0f;
    float insetHeight   = 0.0f;
    
    if( subViewHeight > windowHeight ) {
        insetHeight = heightOffset;
        CGAffineTransform transform = subview.transform;
        float transformBase = windowHeight/subViewHeight;
        subview.transform = CGAffineTransformScale(transform, transformBase, transformBase);
    }
    
    CGRect frame = CGRectInset(subview.frame, insetWidth, insetHeight);
    [subview setFrame:frame];
    _logd_frame(subview, subview.frame);
    _logd_frame(self, self.view.frame);
    
    subview.center = self.view.center;
    [self.view addSubview:subview];
}

- (void)hideCloseButton:(BOOL)hide
{
    if( [self closeButton] ) {
        [self closeButton].hidden = hide;
    }
}
@end
