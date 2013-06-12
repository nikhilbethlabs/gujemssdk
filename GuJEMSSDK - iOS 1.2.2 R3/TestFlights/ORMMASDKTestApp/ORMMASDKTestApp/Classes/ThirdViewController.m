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
#import "ThirdViewController.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController
@synthesize statusLabel;
@synthesize txfAdSpaceId;
@synthesize txfKeywords;
@synthesize loadAdView;
@synthesize activityIndicator;
@synthesize statusEventOrMessage;

- (void)_showAlert:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"XAXIS Test" 
                                                    message:message 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];    
    [alert show];
}

- (NSString*)_adSpaceId
{
    NSString *result = txfAdSpaceId.text;
    if( result == nil || [result isEqualToString:@""] ) {
        [self _showAlert:@"Please enter a valid Ad-Space-ID"];
    }
    return result;
}

- (NSArray*)_keywords
{
    NSArray *result = nil;
    NSString *keywords_ = txfKeywords.text;
    if( keywords_ && [keywords_ isEqualToString:@""] ) {
        result = [NSArray arrayWithObject:keywords_];
        if( [keywords_ rangeOfString:@" "].location != NSNotFound ) {
            result = [keywords_ componentsSeparatedByString:@" "];
        } else if( [keywords_ rangeOfString:@","].location != NSNotFound ) {
            result = [keywords_ componentsSeparatedByString:@","];
        }
    }    
    return result; 
}

- (void)_lockScreen
{
    self.view.userInteractionEnabled = NO;    
    loadAdView.hidden = YES;
    [activityIndicator startAnimating];    
    
    [txfKeywords resignFirstResponder];
    [txfAdSpaceId resignFirstResponder];    
}

- (void)_unlockScreen
{
    self.view.userInteractionEnabled = YES;    
    loadAdView.hidden = NO;
    [activityIndicator stopAnimating];    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"XAXIS VideoAd";
        self.tabBarItem.image = [UIImage imageNamed:@"third"];
    }
    return self;
}

- (void)viewDidUnload
{
    [self setTxfAdSpaceId:nil];
    [self setTxfKeywords:nil];
    [self setLoadAdView:nil];
    [self setLoadAdView:nil];
    [self setActivityIndicator:nil];
    [self setStatusLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    statusLabel.text = @"";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loadAdView:(id)sender
{
    statusLabel.text = @"";
    [ormmaViewController_ freeInstance];
    [self _lockScreen];
    [self performSelector:@selector(_unlockScreen) withObject:nil afterDelay:15];
    [ORMMAViewController setReloadInterval:0.0];
    if( [self _adSpaceId] ) {
        ormmaViewController_ = [GUJXAXISViewController instanceForAdspaceId:[self _adSpaceId] delegate:self];
        if( [self _keywords] != nil ) {
            [ormmaViewController_ interstitialAdViewForKeywords:[self _keywords]];
        } else {
            [ormmaViewController_ interstitialAdView];
        }                
    }
}


#pragma mark adview delegate
- (void)adViewController:(GUJAdViewController *)adViewController didConfigurationFailure:(NSError *)error
{
    [self _unlockScreen];
    statusLabel.text = @"didConfigurationFailure";   
    statusEventOrMessage.text = error.localizedDescription;     
}

- (void) bannerViewDidLoad:(GUJAdView*)bannerView 
{   
    statusLabel.text = @"bannerViewDidLoad";    
}

- (void)bannerView:(GUJAdView*)bannerView didFialLoadingAdWithError:(NSError*)error
{
    statusLabel.text = @"bannerView:didFialLoadingAdWithError";      
    statusEventOrMessage.text = error.localizedDescription;    
    [self _unlockScreen];    
}

- (void)bannerViewWillLoadAdData:(GUJAdView*)bannerView
{
    [self _unlockScreen];    
    statusLabel.text = @"bannerViewWillLoadAdData";     
}

- (void)bannerViewDidLoadAdData:(GUJAdView *)bannerView
{
    statusLabel.text = @"bannerViewDidLoadAdData";     
}

- (void)bannerView:(GUJAdView *)bannerView receivedEvent:(GUJAdViewEvent *)event
{
    statusEventOrMessage.text = event.message;     
}

- (void)bannerViewDidShow:(GUJAdView*)bannerView
{
    statusLabel.text = @"bannerViewDidShow";
}

- (void)bannerViewDidHide:(GUJAdView*)bannerView
{
    statusLabel.text = @"bannerViewDidHide";
}

- (void)interstitialViewDidFailLoadingWithError:(NSError*)error
{
    statusLabel.text = @"interstitialViewDidFailLoadingWithError";   
    statusEventOrMessage.text = error.localizedDescription;
    [self _unlockScreen];    
}

- (void)interstitialViewWillAppear
{
    statusLabel.text = @"interstitialViewWillAppear";      
}

- (void)interstitialViewDidAppear
{
    statusLabel.text = @"interstitialViewDidAppear"; 
}

- (void)interstitialViewWillDisappear
{
    statusLabel.text = @"interstitialViewWillDisappear";   
}

- (void)interstitialViewDidDisappear
{
    statusLabel.text = @"interstitialViewDidDisappear";  
}

- (void)interstitialViewReceivedEvent:(GUJAdViewEvent *)event
{
    NSLog(@"interstitialViewReceivedEvent");
    statusEventOrMessage.text = event.message;    
}


@end
