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
#import "ORMMAInterstitialViewController.h"

@implementation ORMMAInterstitialViewController(PrivateImplementation)

// overriden super method
- (void)__dismissSelf
{
    [self dismiss];
}

- (void)__progress
{
    [[self progressView] setProgress:[[self progressView] progress]+[self timeIncrement]];
    
    if( [[self progressView] progress] >= 1.0 ) {
        if( ![self disableAutoCloseFeature] ) {
            [self dismiss];
        }
    }
}

- (void)__setup
{
    [self setTimeIncrement:(0.075f/kORMMAInterstitialDefaultTimeout)];
    
    if( ![self disableAutoCloseFeature] ) {
        [self setProgressView:[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar]];
        [[self progressView] setTrackTintColor:[UIColor whiteColor]];
        [[self progressView] setProgressTintColor:[UIColor blackColor]];
        [[self progressView] setProgress:[self timeIncrement]];
        
        CGRect frame = [self progressView].frame;
        frame.size   = CGSizeMake(([GUJUtil frameOfFirstResponder].size.width-10.0f-[super closeButton].frame.size.width), frame.size.height);
        frame.origin = CGPointMake(5.0f, ([super closeButton].frame.size.height/2.0f)-(frame.size.height/5.0f));
        [[self progressView] setFrame:frame];
        
        [self.view addSubview:[self progressView]];
    }
}

@end

@implementation ORMMAInterstitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setDisableAutoCloseFeature:NO];
        [self __setup];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if( ![super defaultStatusBarState] ) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    if( [self disableAutoCloseFeature] ) {
        [[self progressView] removeFromSuperview];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if( ![self disableAutoCloseFeature] ) {
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:0.075 target:self selector:@selector(__progress) userInfo:nil repeats:YES]];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self timer] invalidate];
    [self setTimer:nil];
    [self setTimeIncrement:0.0f];
    [[UIApplication sharedApplication] setStatusBarHidden:[super defaultStatusBarState]];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
