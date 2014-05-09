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
#import "TestAdViewController.h"

@interface TestAdViewController ()

@end

@implementation TestAdViewController
@synthesize adSettingsView;
@synthesize adViewContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect _frame = self.view.frame;
    _frame.size.height = [[UIScreen mainScreen] bounds].size.height;
    [self.view setFrame:_frame];
	[self setAdSettingsView:[[AdSettingsView alloc] init]];
    [self setAdConsole:[[AdConsole alloc] init]];
    [[self view] addSubview:[self adConsole]];
    [[self view] addSubview:[self adSettingsView]];
    [[self adConsole] showHideConsole:nil];
    [[self adSettingsView] showHideSettings:nil];
    [[self adSettingsView] showSettings];
    [[self adConsole] hideConsole];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if( [[[self adSettingsView] moceanSwitch] isOn] ) {
 //  
    }
}

- (IBAction)requestAd:(id)sender
{
    [[self adSettingsView] removeFromSuperview];
}

- (IBAction)releaseAd:(id)sender
{
   [[self adViewContext] freeInstance]; 
}

#pragma mark delegate methods

- (void)adViewController:(GUJAdViewController *)adViewController didConfigurationFailure:(NSError *)error {
        [[self adConsole] addConsoleText:[NSString stringWithFormat:@"adViewController:didConfigurationFailure: %@",error]];
    [[self adConsole] showConsole];
}

- (BOOL)adViewController:(GUJAdViewController *)adViewController canDisplayAdView:(GUJAdView *)adView
{
    return YES;
}

- (void)bannerViewInitialized:(GUJAdView *)bannerView
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"bannerViewInitialized: %@",[bannerView adSpaceId]]];
}

- (void)bannerView:(GUJAdView *)bannerView didFailLoadingAdWithError:(NSError *)error
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"bannerView:didFailLoadingAdWithErrorr: %@",error]];
    [[self adConsole] showConsole];
}

- (void)bannerViewWillLoadAdData:(GUJAdView *)bannerView
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"bannerViewWillLoadAdData: %@",[bannerView adSpaceId]]];
}

- (void)bannerViewDidLoadAdData:(GUJAdView *)bannerView
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"bannerViewDidLoadAdData: %@",[bannerView adSpaceId]]];
}

- (void)bannerView:(GUJAdView *)bannerView receivedEvent:(GUJAdViewEvent *)event
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"receivedEvent: %@ %@",[bannerView adSpaceId],event]];
}

- (void)bannerViewDidShow:(GUJAdView *)bannerView
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"bannerViewDidShow: %@",[bannerView adSpaceId]]];
}

- (void)bannerViewDidHide:(GUJAdView *)bannerView
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"bannerViewDidHide: %@",[bannerView adSpaceId]]];
}

- (void)interstitialViewInitialized:(GUJAdView *)interstitialView
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewInitialized: %@",[interstitialView adSpaceId]]];
}

-(void)interstitialViewWillLoadAdData:(GUJAdView *)interstitialView
{
     [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewWillLoadAdData: %@",[interstitialView adSpaceId]]];   
}

-(void)interstitialViewDidLoadAdData:(GUJAdView *)interstitialView
{
         [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewDidLoadAdData: %@",[interstitialView adSpaceId]]];   
}

-(void)interstitialView:(GUJAdView *)interstitialView didFailLoadingAdWithError:(NSError *)error
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewDidFailLoadingWithError: %@",error]];
}

-(void)interstitialViewDidFailLoadingWithError:(NSError *)error
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"_OLD_interstitialViewDidFailLoadingWithError: %@",error]];
}

-(void)interstitialViewReceivedEvent:(GUJAdViewEvent *)event
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewReceivedEvent: %@",event]];
}

-(void)interstitialViewWillAppear
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewWillAppear"]];
}

-(void)interstitialViewDidAppear
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewDidAppear"]];
}

-(void)interstitialViewWillDisappear
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewWillDisappear"]];
}

-(void)interstitialViewDidDisappear
{
    [[self adConsole] addConsoleText:[NSString stringWithFormat:@"interstitialViewDidDisappear"]];
}

- (IBAction)showAdSettings
{
    [[self adSettingsView] showHideSettings:nil];
    [[self adConsole] hideConsole];
}

- (IBAction)showAdConsole
{
    [[self adConsole] showHideConsole:nil];
    [[self adSettingsView] hideSettings];
}

@end
