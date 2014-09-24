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
#import "ExpandableViewController.h"

@implementation ExpandableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[self adSettingsView] removeFromSuperview];
    [[self adConsole] showConsole];
    [self requestAd:nil];
    [[self adConsole] showHideConsole:nil];
    [[self adViewPlaceHolder_Top] removeFromSuperview];
}

- (IBAction)requestAd:(id)sender
{
    if( [self staticAdSpaceId] != nil && ![[self staticAdSpaceId] isEqualToString:@""] ) {
        
        [[self adConsole] clearConsole];
        [[self adConsole] addConsoleText:@"New Ad-Request"];
        [[self adConsole] showConsole];
        
        self.adViewContext = [GUJAdViewContext instanceForAdspaceId:[self staticAdSpaceId] delegate:self];
        
        CGRect _frame = [self adViewPlaceHolder_Top].frame;
        [[self adViewPlaceHolder_Top] removeFromSuperview];
        
        [[self adViewContext] adViewWithOrigin:_frame.origin completion:^BOOL(GUJAdView *_adView, NSError *_error) {
            if( _error != nil ) {
                NSLog(@"Error: %@",_error);
                return NO;
            } else {                
                [self.view addSubview:_adView];
                return YES;
            }
        }];
        
    }
}

- (BOOL)adViewController:(GUJAdViewController *)adViewController canDisplayAdView:(GUJAdView *)adView
{
    [self.view addSubview:adView];
    return YES;
}

@end
