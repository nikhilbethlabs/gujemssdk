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
#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize loadAdView;
@synthesize txfKeywords;
@synthesize txfAdSpaceId;
@synthesize adViewPlaceholder;
@synthesize activityIndicator;
@synthesize txfRefreshValue;
@synthesize refreshSlider;
@synthesize statusLabel;

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ORMMA Test" 
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
        self.title = @"Embedded";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    txfRefreshValue.text = @"off";
}

- (void)viewDidUnload
{
    [self setTxfRefreshValue:nil];
    [self setRefreshSlider:nil];
    [self setLoadAdView:nil];
    [self setTxfKeywords:nil];
    [self setTxfAdSpaceId:nil];
    [self setAdViewPlaceholder:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    statusLabel.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    if( [self iosVersion] >= __IPHONE_5_0 ) {
        [progressView setTrackTintColor:[UIColor blackColor]];
        [progressView setProgressTintColor:[UIColor grayColor]];
    }
    CGRect frame = progressView.frame;
    frame.size = CGSizeMake(320.0, frame.size.height);
    frame.origin = CGPointMake(0, 5);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)refreshCahnged:(id)sender 
{
    int refreshValue = roundf(refreshSlider.value);
    txfRefreshValue.text = [NSString stringWithFormat:@"%is",refreshValue];
}

- (IBAction)loadAdView:(id)sender 
{
    statusLabel.text = @"";
    [ormmaViewController_ freeInstance];
    [self _lockScreen];
    [self performSelector:@selector(_unlockScreen) withObject:nil afterDelay:15];
    if( [self _adSpaceId] ) {
        ormmaViewController_ = [ORMMAViewController instanceForAdspaceId:[self _adSpaceId] delegate:self];
        
        /*
         * Additionaly you can add HTTP-Request Header Parameters thru the HTTP-Request handler before loading the ad.
         */
        //[ormmaViewController_ addAdServerRequestHeaderField:@"iPhoneAd" value:@"false"];
                
        /*
         * Additionaly you can add HTTP-Request Parameters thru the HTTP-Request handler before loading the ad.
         */
        //[ormmaViewController_ addAdServerRequestParameter:@"foo" value:@"bar"];
        
        
        [adViewPlaceholder removeFromSuperview];
        if( refreshSlider.value > 0.9 ) {
            [ORMMAViewController setReloadInterval:refreshSlider.value];
        }
        CGPoint origin = CGPointMake(0.0, adViewPlaceholder.frame.origin.y);
        if( [self _keywords] != nil ) {
            adViewPlaceholder = [ormmaViewController_ adViewForKeywords:[self _keywords] origin:origin];
        } else {
            adViewPlaceholder = [ormmaViewController_ adViewWithOrigin:origin];
        }        
        [self.view addSubview:adViewPlaceholder];          
    }
}

#pragma mark adview delegate
- (void)adViewController:(GUJAdViewController *)adViewController didConfigurationFailure:(NSError *)error
{
    [self _unlockScreen];
    statusLabel.text = @"didConfigurationFailure";   
}

- (void) bannerViewDidLoad:(GUJAdView*)bannerView 
{
    statusLabel.text = @"bannerViewDidLoad";  
}

- (void)bannerView:(GUJAdView*)bannerView didFialLoadingAdWithError:(NSError*)error
{
    statusLabel.text = @"bannerView:didFialLoadingAdWithError";
    [self _unlockScreen];        
}

- (void)bannerViewWillLoadAdData:(GUJAdView*)bannerView
{
    statusLabel.text = @"bannerViewWillLoadAdData";
    [self _unlockScreen];    
}

- (void)bannerViewDidLoadAdData:(GUJAdView *)bannerView
{
    statusLabel.text = @"bannerViewDidLoadAdData";
    [self _unlockScreen];  
}

- (void)bannerViewDidShow:(GUJAdView*)bannerView
{
    statusLabel.text = @"bannerViewDidShow";
}

- (void)bannerViewDidHide:(GUJAdView*)bannerView
{
    statusLabel.text = @"bannerViewDidHide";
}

@end
