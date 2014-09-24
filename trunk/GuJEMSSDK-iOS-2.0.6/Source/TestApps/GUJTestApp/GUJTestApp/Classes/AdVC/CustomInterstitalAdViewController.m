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

#import "CustomInterstitalAdViewController.h"

@interface CustomInterstitalAdViewController ()

@end

@implementation CustomInterstitalAdViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self adViewPlaceHolder_Top] removeFromSuperview];
}

- (IBAction)requestAd:(id)sender
{
    NSString *_adSpaceId = [[self adSettingsView] adSpaceId].text;
    NSString *_zoneId = [[self adSettingsView] zoneId].text;
    NSString *_siteId = [[self adSettingsView] siteId].text;
    BOOL _moceanEnabled = [[[self adSettingsView] moceanSwitch] isOn];
    if( ![_adSpaceId isEqualToString:@""] ) {
        
        [[self adConsole] clearConsole];
        [[self adConsole] addConsoleText:@"New Ad-Request"];
        [[self adConsole] showConsole];
        if( _moceanEnabled && ![_zoneId isEqualToString:@""] && ![_siteId isEqualToString:@""]) {
            self.adViewContext = [GUJAdViewContext instanceForAdspaceId:_adSpaceId site:[_siteId intValue] zone:[_zoneId intValue] delegate:self];
            [self.adViewContext setMOceanBackFill:YES];
        } else {
            self.adViewContext = [GUJAdViewContext instanceForAdspaceId:_adSpaceId delegate:self];
        }
        [self.adViewContext shouldAutoShowIntestitialView:NO];
      /*  [self.adViewContext interstitialAdViewWithCompletionHandler:^BOOL(GUJAdView *_adView, NSError *_error) {
            if( _error ) {
                NSLog(@"BlockError: %@",_error);
                return NO;
            } else {
                return YES;
            }
        }];
       */
        [[self adViewContext] interstitialAdView];
    }
}

- (BOOL)adViewController:(GUJAdViewController *)adViewController canDisplayAdView:(GUJAdView *)adView
{
    [adView showInterstitialView];
    return NO;
}
@end
