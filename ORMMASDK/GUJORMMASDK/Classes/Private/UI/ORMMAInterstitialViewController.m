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
    progressView_.progress = progressView_.progress+timeIncrement_;
    
    if( progressView_.progress >= 1.0 ) {
        [self dismiss];
    }    
}

- (void)__setup
{
    if( [GUJUtil iosVersion] > __IPHONE_4_3 ) {
        timeIncrement_ = 0.075f/kORMMAInterstitialDefaultTimeout;
    } else {
        timeIncrement_ = 1.0f/kORMMAInterstitialDefaultTimeout;        
    }
    
    progressView_ = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    if( [GUJUtil iosVersion] >= __IPHONE_5_0 ) {
        [progressView_ setTrackTintColor:[UIColor whiteColor]];
        [progressView_ setProgressTintColor:[UIColor blackColor]];  
    }
    progressView_.progress = timeIncrement_;
    
    CGRect frame = progressView_.frame;
    frame.size   = CGSizeMake(([GUJUtil frameOfFirstResponder].size.width-10.0f-closeButton_.frame.size.width), frame.size.height);
    frame.origin = CGPointMake(5.0f, (closeButton_.frame.size.height/2.0f)-(frame.size.height/5.0f));
    [progressView_ setFrame:frame];    
    
    
    [self.view addSubview:progressView_];
}

@end

@implementation ORMMAInterstitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self __setup];
    }
    return self;
}

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    if( !defaultStatusBarState_ ) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }     
    if( [GUJUtil iosVersion] > __IPHONE_4_3 ) {
        @autoreleasepool {
            timer_ = [NSTimer scheduledTimerWithTimeInterval:0.075 target:self selector:@selector(__progress) userInfo:nil repeats:YES];            
        }
    } else {
        @autoreleasepool {
            timer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(__progress) userInfo:nil repeats:YES];   
        }            
    }
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [timer_ invalidate];
    timer_          = nil;
    timeIncrement_  = 0.0;
    [[UIApplication sharedApplication] setStatusBarHidden:defaultStatusBarState_];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
