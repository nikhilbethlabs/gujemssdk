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
#import "RootAdVC.h"

@interface RootAdVC ()

@end

@implementation RootAdVC
@synthesize adView              = adViewPlaceholder;
@synthesize tfAdViewId          = txfAdSpaceId;
@synthesize tfAdViewKeywords    = txfKeywords;
@synthesize tfMoceanSiteId;
@synthesize tfMoceanZoneId;
@synthesize sRefreshInterval    = refreshSlider;
@synthesize tfReloadInterval;
@synthesize btnLoadAd;
@synthesize swMoceanBackFill;
@synthesize debugVC;
@synthesize isInterstitial;
@synthesize hiddenVC;

- (void)_showHiddenVC
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        hiddenVC = [[HiddenViewController alloc] initWithNibName:@"HiddenVC_iPhone" bundle:nil];
        [self.view addSubview:hiddenVC.view];
    } else {
        hiddenVC = [[HiddenViewController alloc] initWithNibName:@"HiddenVC_iPad" bundle:nil];
        [self.view addSubview:hiddenVC.view];
    }
}

- (void)_lockScreen
{
    self.view.userInteractionEnabled = NO;    
    
    [txfKeywords resignFirstResponder];
    [txfAdSpaceId resignFirstResponder];   
    [tfMoceanSiteId resignFirstResponder];
    [tfMoceanZoneId resignFirstResponder];       
}

- (void)_unlockScreen
{
    self.view.userInteractionEnabled = YES;   
}

- (NSInteger)iosVersion
{
    NSInteger result = 0;
    NSArray *versionChunks = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    int chunkIndex = 0;    
    for (NSString *numChunk in versionChunks) {
        if (chunkIndex > 2) break;
        result += [numChunk intValue]*(powf(100, (2-chunkIndex)));
        chunkIndex++;
    }
    return result;
}

- (void)_showAlert:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GUJ AdView Context Test" 
                                                    message:message 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];    
    [debugVC.loadingSpinner stopAnimating];
    debugVC.loadingSpinner.hidden = YES;
    [alert show];
}

- (NSString*)_adSpaceId
{
    NSString *result = txfAdSpaceId.text;
    if( result == nil || [result isEqualToString:@""] ) {
        result = nil;
        [debugVC enableSpinner:NO];        
        [self _showAlert:@"Please enter a valid Ad-Space-ID"];
    }
    return result;
}

- (NSArray*)_keywords
{
    NSArray *result = nil;
    NSString *keywords_ = txfKeywords.text;
    if( keywords_ != nil && ![keywords_ isEqualToString:@""] ) {
        result = [NSArray arrayWithObject:keywords_];
        if( [keywords_ rangeOfString:@" "].location != NSNotFound ) {
            result = [keywords_ componentsSeparatedByString:@" "];
        } else if( [keywords_ rangeOfString:@","].location != NSNotFound ) {
            result = [keywords_ componentsSeparatedByString:@","];
        }
    }    
    return result; 
}

- (NSUInteger)_mSiteId
{
    NSString *result = tfMoceanSiteId.text;
    if( result == nil || [result isEqualToString:@""] ) {
        result = @"-1";
    }
    return [result intValue];
}

- (NSUInteger)_mZoneId
{
    NSString *result = tfMoceanZoneId.text;
    if( result == nil || [result isEqualToString:@""] ) {
        result = @"-1";
    }
    return [result intValue];
}

- (void)_performInterstitialAdRequest
{
    [self releaseAdViewCtx];
    
    [GUJAdViewContext setReloadInterval:0.0];
    if( [self _adSpaceId] != nil ) {
        if( [self _mSiteId] != -1 && [self _mZoneId] != -1 && [swMoceanBackFill isOn]) {
            gujAdViewContext_ = [GUJAdViewContext instanceForAdspaceId:[self _adSpaceId] site:[self _mSiteId] zone:[self _mZoneId] delegate:self];            
        } else {        
            gujAdViewContext_ = [GUJAdViewContext instanceForAdspaceId:[self _adSpaceId] delegate:self];
        }
        /*
         * Additionaly you can add HTTP-Request Header Parameters thru the HTTP-Request handler before loading the ad.
         */
        //[gujAdViewContext_ addAdServerRequestHeaderField:@"iPhoneAd" value:@"false"];
        
        /*
         * Additionaly you can add HTTP-Request Parameters thru the HTTP-Request handler before loading the ad.
         */
        //[gujAdViewContext_ addAdServerRequestParameter:@"foo" value:@"bar"];
        
        if( [self _keywords] != nil ) {
            [gujAdViewContext_ interstitialAdViewForKeywords:[self _keywords]];
        } else {
            [gujAdViewContext_ interstitialAdView];
        }                
    } else {
        [debugVC enableSpinner:NO];        
    }
}

- (void)_performEmbeddedAdRequest
{
    [self releaseAdViewCtx];
    
    if( [self _adSpaceId] != nil ) {
        if( ([self _mSiteId] != -1 && [self _mZoneId] != -1) && [swMoceanBackFill isOn]) {
            gujAdViewContext_ = [GUJAdViewContext instanceForAdspaceId:[self _adSpaceId] site:[self _mSiteId] zone:[self _mZoneId] delegate:self];            
        } else {
            gujAdViewContext_ = [GUJAdViewContext instanceForAdspaceId:[self _adSpaceId] delegate:self];
        }
        [GUJAdViewContext disableLocationService];
        /*
         * Additionaly you can add HTTP-Request Header Parameters thru the HTTP-Request handler before loading the ad.
         */
        //[gujAdViewContext_ addAdServerRequestHeaderField:@"iPhoneAd" value:@"false"];
        
        /*
         * Additionaly you can add HTTP-Request Parameters thru the HTTP-Request handler before loading the ad.
         */
        //[gujAdViewContext_ addAdServerRequestParameter:@"foo" value:@"bar"];
        
        
        [adViewPlaceholder removeFromSuperview];
        if( refreshSlider.value > 0.9 ) {
            [GUJAdViewContext setReloadInterval:refreshSlider.value];
        }
        if( adViewOrigin_.y == 0.0 ) {
            adViewOrigin_ = CGPointMake(0.0, adViewPlaceholder.frame.origin.y);
        }
        if( [self _keywords] != nil ) {
            adViewPlaceholder = [gujAdViewContext_ adViewForKeywords:[self _keywords] origin:adViewOrigin_];
        } else {
            adViewPlaceholder = [gujAdViewContext_ adViewWithOrigin:adViewOrigin_];
        }        
        
        [self.view addSubview:adViewPlaceholder];  
    } else {
        [debugVC enableSpinner:NO];        
    }
}

- (void)_performAdRequest
{
    [self _lockScreen];
    if( self.isInterstitial ) {
        [self _performInterstitialAdRequest];
    } else {
        [self _performEmbeddedAdRequest];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    debugVC = [[DebugCVC alloc] initWithNibName:@"Console" bundle:nil];
    if( [[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {    
            float height = self.view.frame.size.height/3.5;
            float y = self.view.frame.size.height-44;
            [debugVC setFrame:CGRectMake(0, y, self.view.frame.size.width, height)];
        } else {
            float height = self.view.frame.size.height/2.5;
            float y = self.view.frame.size.height-250;
            [debugVC setFrame:CGRectMake(0, y, self.view.frame.size.width, height)];        
        }
    } else {
        float height = self.view.frame.size.height/3.5;
        float y = self.view.frame.size.height-44;
        [debugVC setFrame:CGRectMake(0, y, self.view.frame.size.width, height)];
    }
    [debugVC.view setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];    
    [debugVC setOwner:self];
    [self.view addSubview:debugVC.view];
    self.tabBarController.delegate = self;
}

- (void)viewDidUnload
{
    [self setAdView:nil];
    [self setTfAdViewId:nil];
    [self setTfAdViewKeywords:nil];
    [self setSRefreshInterval:nil];
    [self setBtnLoadAd:nil];
    [self setSwMoceanBackFill:nil];
    [self setTfMoceanSiteId:nil];
    [self setTfMoceanZoneId:nil];
    [self setTfReloadInterval:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self _unlockScreen];
    // [self releaseAdViewCtx];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if( [[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (IBAction)refreshCahnged:(id)sender 
{
    int refreshValue = roundf(refreshSlider.value);
    tfReloadInterval.text = [NSString stringWithFormat:@"%is",refreshValue];
}

- (void)releaseAdViewCtx
{
    if( gujAdViewContext_ != nil ) {
        [gujAdViewContext_ freeInstance];
    }
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [((RootAdVC*)tabBarController.delegate) performSelectorOnMainThread:@selector(releaseAdViewCtx) withObject:nil waitUntilDone:NO];
}

#pragma mark adview delegate
- (void)adViewController:(GUJAdViewController *)adViewController didConfigurationFailure:(NSError *)error
{
    [self _unlockScreen];
    [debugVC enableSpinner:NO];
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:[NSString stringWithFormat:@"didConfigurationFailure: %@",error] waitUntilDone:NO];
}

- (void) bannerViewDidLoad:(GUJAdView*)bannerView 
{
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"bannerViewDidLoad" waitUntilDone:NO];    
}

- (void)bannerView:(GUJAdView*)bannerView didFialLoadingAdWithError:(NSError*)error
{
    [self _unlockScreen];    
    [debugVC enableSpinner:NO];
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:[NSString stringWithFormat:@"bannerView:didFialLoadingAdWithError: %@",error] waitUntilDone:NO];              
}

- (void)bannerViewWillLoadAdData:(GUJAdView*)bannerView
{
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"bannerViewWillLoadAdData" waitUntilDone:NO];   
}

- (void)bannerViewDidLoadAdData:(GUJAdView *)bannerView
{    
    [self _unlockScreen];    
    [debugVC enableSpinner:NO];      
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"bannerViewDidLoadAdData" waitUntilDone:NO];       
}

- (void)bannerViewDidShow:(GUJAdView*)bannerView
{
    [self _unlockScreen];    
    [debugVC enableSpinner:NO];   
    [debugVC enableUnloadAd:YES];
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"bannerViewDidShow" waitUntilDone:NO];      
    [[debugVC.view superview] bringSubviewToFront:debugVC.view];
}

- (void)bannerViewDidHide:(GUJAdView*)bannerView
{  
    [self _unlockScreen];    
    [debugVC enableSpinner:NO];    
    [debugVC enableUnloadAd:NO];    
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"bannerViewDidHide" waitUntilDone:NO];       
}

- (void)bannerView:(GUJAdView *)bannerView receivedEvent:(GUJAdViewEvent *)event
{     
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:[NSString stringWithFormat:@"bannerView:receivedEvent: %@",event.message] waitUntilDone:NO];       
}

- (void)interstitialViewDidFailLoadingWithError:(NSError*)error
{
    [self _unlockScreen];    
    [debugVC enableSpinner:NO];    
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:[NSString stringWithFormat:@"interstitialViewDidFailLoadingWithError: %@",error] waitUntilDone:NO]; 
}

- (void)interstitialViewWillAppear
{
    [self _unlockScreen];
    [debugVC enableSpinner:NO];          
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"interstitialViewWillAppear" waitUntilDone:NO];      
}

- (void)interstitialViewDidAppear
{
    [self _unlockScreen];    
    [debugVC enableSpinner:NO];          
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"interstitialViewDidAppear" waitUntilDone:NO];      
}

- (void)interstitialViewWillDisappear
{
    [self _unlockScreen];    
    [debugVC enableSpinner:NO];          
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"interstitialViewWillDisappear" waitUntilDone:NO];
}

- (void)interstitialViewDidDisappear
{
    [debugVC enableSpinner:NO];          
    [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:@"interstitialViewDidDisappear" waitUntilDone:NO];
    [self _showHiddenVC];    
}

- (void)interstitialViewReceivedEvent:(GUJAdViewEvent *)event
{
  [debugVC performSelectorOnMainThread:@selector(adTextToConsole:) withObject:[NSString stringWithFormat:@"interstitialViewReceivedEvent: %@",event.message] waitUntilDone:NO];     
}

@end
