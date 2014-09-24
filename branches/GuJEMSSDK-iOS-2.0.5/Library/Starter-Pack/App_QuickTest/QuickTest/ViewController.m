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

#import "ViewController.h"
#import "GUJAdViewContext.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[GUJAdViewContext instanceForAdspaceId:@"14833"] adView:^BOOL(GUJAdView *_adView, NSError *_error) {
        if( !_error ) {
            [[self view] addSubview:_adView];
        } else {
            NSLog(@"AdView:didFailLoadingAdWithError %@",_error);
        }
        return YES;
    }];
    
    [[GUJAdViewContext instanceForAdspaceId:@"18779"] adViewWithOrigin:CGPointMake(0.0f, 120.0f) completion:^BOOL(GUJAdView *_adView, NSError *_error) {
        if( !_error ) {
            [[self view] addSubview:_adView];
        } else {
            NSLog(@"AdView:didFailLoadingAdWithError %@",_error);
        }
        return YES;
    }];
    
     [[GUJAdViewContext instanceForAdspaceId:@"14839"] interstitialAdViewWithCompletionHandler:^BOOL(GUJAdView *_adView, NSError *_error) {
         if( !_error ) {
             return YES;
         } else {
             NSLog(@"AdView:didFailLoadingAdWithError %@",_error);
             return NO;
         }
     }];
}

@end
