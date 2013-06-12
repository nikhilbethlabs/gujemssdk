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
#import "GUJAdConfiguration.h"
#import "GUJAdView.h"
#import "GUJAdData.h"  

// Native frameworks
#import "GUJNativeFrameWorkBridge.h"

/*! 
 * Private implementaion of GUJAdViewController
 * See inline comments for details.
 */
@interface GUJAdViewController (PrivateImplementation)<GUJAdViewDelegate>

- (GUJAdView*)populateAdView:(GUJAdView*)adView;

- (GUJAdView*)adViewForType:(GUJBannerType)type frame:(CGRect)frame;

/**!
 * Classes that extends GUJAdViewController can set the current AdView Object
 * via [... performSelector:@selector(__setAdView:) withObject:myAdView];
 */
- (void)__setAdView:(GUJAdView*)adView;

/**!
 * Classes that extends GUJAdViewController can access the current AdView Object
 * via [... performSelector:@selector(__adView)];
 */
- (GUJAdView*)__adView;

/**!
 * Only override __initializeAdService if you perform custom configuration.
 */
- (void) __initializeAdService;

/**!
 * Will be called when the AdView is loaded and ready.
 */
- (void)__loadAdBannerData;

/**!
 * Instanciates the AdViewController.
 * Extending classes must call __initializeAdService when overriding.
 * @optional initializeNativeInterfaces 
 */
- (void) instanciate;

/**! 
 * Initialize native interfaces, custom implementations, etc. which needs access to a native framework.
 *
 * Call this method when sub classing GUJAdViewController before the adView loads.
 * Be sure to call [super initializeNativeInterfaces] strongly BEFORE you implement your own code
 * 
 */
- (void) initializeNativeInterfaces;

@end


@implementation GUJAdViewController (PrivateImplementation)

#pragma mark GUJAdview
// The AdView Object
static GUJAdView *adView_;

- (GUJAdView*)__adView
{
    return adView_;
}

- (void)__setAdView:(GUJAdView*)adView
{
    adView_ = adView;
}

#pragma mark private methods
// Only override __initializeAdService if you perform custom configuration.
- (void) __initializeAdService
{
    @autoreleasepool { // autorelease cause GUJAdConfiguration/error is not safe
        [GUJUtil applicationAdSpaceUUID]; // load or create AdSpace UUID
        if( ![[GUJAdConfiguration sharedInstance] isValid] ) {
            
            if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(didConfigurationFailure:)]) {
                [delegate_ didConfigurationFailure:[[GUJAdConfiguration sharedInstance] error]];// DEPRECATED
            }
            
            if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(adViewController:didConfigurationFailure:)]) {
                [delegate_ adViewController:self didConfigurationFailure:[[GUJAdConfiguration sharedInstance] error]];
            }            
        } else {                 
            [self performSelectorOnMainThread:@selector(initializeNativeInterfaces) withObject:nil waitUntilDone:NO];
        }
    }        
    // Custom code or method calls
}


- (void)__loadAdBannerData
{
    /*
     * we need some time to initialize some native frame works and / or fetch data.
     * for example the CoreLocationFW needs a while to fire its first delegate with the 
     * current user location.
     *
     * so we register a notification for LocationChanges that will handled by the BannerView
     * we have to ensure that the BannerView(adView_) stays __strong and available.
     *
     */
    @autoreleasepool {    
        [[GUJNotificationObserver sharedInstance] registerForNotification:adView_ name:GUJDeviceLocationChangedNotification selector:@selector(__loadAdNotifcation:)]; 
        // if loosing the locationObserver we load the ad after a delay of X
        [adView_ performSelector:@selector(__loadAd) withObject:nil afterDelay:kGUJTimeoutForLoadNotification];
    }    
}

- (void)instanciate
{
    /*
     * Notice that the AdViewController is not part of the MainThread-Pool.
     * Ensure safe methods calls. performSelectorOnMainThread:withObject:waitUntilDone should be best practice.
     */    
    if( [GUJUtil iosVersion] < __IPHONE_4_0 ) {  
        [self initializeNativeInterfaces];
    } else {    
        [self performSelectorOnMainThread:@selector(__initializeAdService) withObject:nil waitUntilDone:NO];
    }
    // Custom Initialization code or method calls    
}

- (void) initializeNativeInterfaces
{    
#pragma GCC diagnostic ignored "-Wundeclared-selector"    
    /*
     * Interfaces that depends on external Frameworks must load safely
     */
    // core location framework    
    if( ![[GUJAdConfiguration sharedInstance] locationServiceDisabled] ) {        
        id locationManager = [[GUJNativeFrameWorkBridge sharedInstance] nativeFrameWorkBridgeForDeviceCapability:GUJDeviceCapabilityLocation];                
        if( locationManager != nil && 
           [locationManager respondsToSelector:@selector(startUpdatingLocationOnce)]
           ) {       
             if( [GUJUtil iosVersion] < __IPHONE_4_2 ) {
                 [locationManager performSelectorOnMainThread:@selector(startUpdatingLocationOnce) withObject:nil waitUntilDone:YES];
             } else {
                 [locationManager performSelector:@selector(startUpdatingLocationOnce)];
             }
        } else {
            // The location service is disabled
            [[GUJAdConfiguration sharedInstance] setDisableLocationService:YES];
        }
              
    }    
    // Custom Initialization code or method calls
}

- (GUJAdView*)populateAdView:(GUJAdView*)adView 
{
    adView_ = adView;
    
    if( [GUJUtil iosVersion] < __IPHONE_4_0 ) {          
        [self performSelectorOnMainThread:@selector(__loadAdBannerData) withObject:nil waitUntilDone:YES];
    } else {        
        [self performSelectorOnMainThread:@selector(__loadAdBannerData) withObject:nil waitUntilDone:NO];
    }
    
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(bannerViewDidLoad:)] ) {
        [delegate_ bannerViewDidLoad:adView_];
    }      
    return adView_; 
}

- (GUJAdView*)adViewForType:(GUJBannerType)type frame:(CGRect)frame
{    
    // making the type global
    [[GUJAdConfiguration sharedInstance] setBannerType:type];    
    
    if( adView_ == nil ) {
        return [self populateAdView:[[GUJAdView alloc] initWithFrame:frame andDelegate:self]];
    } else {        
        // Discuss: sense of re-setting the frame of a loaded adView ?
        [adView_ setFrame:frame];
        return adView_;
    }
}

@end

/**!
 *
 * Public GUJAdViewController implementation
 *
 */
#import "GUJAdViewController.h"
@implementation GUJAdViewController

static GUJAdViewController  *instance_;

#pragma mark public methods
+ (GUJAdViewController*)instanceForAdspaceId:(NSString*)adSpaceId
{
    return [GUJAdViewController instanceForAdspaceId:adSpaceId delegate:nil];
}

+ (GUJAdViewController*)instanceForAdspaceId:(NSString*)adSpaceId delegate:(id<GUJAdViewControllerDelegate>)delegate
{  
    if( instance_ != nil ) {
        [instance_ performSelectorOnMainThread:@selector(freeInstance) withObject:nil waitUntilDone:YES];
    }    
    if( instance_ == nil ) {
        instance_ = [[super alloc] init];
        if( delegate != nil ) {
            instance_->delegate_ = delegate;
            [[GUJAdConfiguration sharedInstance] setAdSpaceId:adSpaceId];
        }
    }
    return instance_;  
}

+ (void)setReloadInterval:(NSTimeInterval)reloadInterval
{
    [[GUJAdConfiguration sharedInstance] setReloadInterval:reloadInterval];
}

+ (BOOL)disableLocationService
{
    [[GUJAdConfiguration sharedInstance] setDisableLocationService:YES];
    return [[GUJAdConfiguration sharedInstance] locationServiceDisabled];
}

- (GUJAdView*)adView // static mobile banner view
{  
    [[GUJAdConfiguration sharedInstance] setRequestedBannerType:GUJBannerTypeDefault];    
    return [self adViewForType:GUJBannerTypeDefault frame:kGUJAdViewDimensionDefault];
}

- (GUJAdView*)adViewWithOrigin:(CGPoint)origin
{
    if( origin.x > 0.0 ) {
        origin.x = 0.0;
    }
    return [self adViewForType:GUJBannerTypeDefault frame:CGRectOffset(kGUJAdViewDimensionDefault, origin.x, origin.y)];
}

- (GUJAdView*)adViewForKeywords:(NSArray*)keywords
{
    [[GUJAdConfiguration sharedInstance] setKeywords:keywords];
    return [self adView];
}

- (GUJAdView*)adViewForKeywords:(NSArray*)keywords origin:(CGPoint)origin
{
    [[GUJAdConfiguration sharedInstance] setKeywords:keywords];
    return [self adViewWithOrigin:origin];
}

- (void)interstitialAdView // interstitial banner
{
    [[GUJAdConfiguration sharedInstance] setRequestedBannerType:GUJBannerTypeInterstitial];
    // we pass a CGRectZero cause the banner automaticly resiszes to full screen.
    [[GUJAdConfiguration sharedInstance] setReloadInterval:0.0];
    [self adViewForType:GUJBannerTypeInterstitial frame:kGUJAdViewDimensionDefault]; 
}

- (void)interstitialAdViewForKeywords:(NSArray*)keywords
{
    [[GUJAdConfiguration sharedInstance] setKeywords:keywords];
    [self interstitialAdView];  
}

- (void)addAdServerRequestHeaderField:(NSString*)name value:(NSString*)value
{
    [[GUJAdConfiguration sharedInstance] addCustomAdServerHeaderField:name value:value];
}

- (void)addAdServerRequestHeaderFields:(NSDictionary*)headerFields
{
    [[GUJAdConfiguration sharedInstance] setCustomAdServerHeaderField:headerFields];
}

- (void)addAdServerRequestParameter:(NSString*)name value:(NSString*)value 
{
    [[GUJAdConfiguration sharedInstance] addCustomAdServerRequestParameter:name value:value];
}

- (void)addAdServerRequestParameters:(NSDictionary*)requestParameters
{
    [[GUJAdConfiguration sharedInstance] setCustomAdServerRequestParameters:requestParameters];
}

-(void)freeInstance // free all native interfaces and sharedInstances
{
    [[GUJAdConfiguration sharedInstance] freeInstance];
    [[GUJNotificationObserver sharedInstance] freeInstance];    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:adView_];    
    [NSObject cancelPreviousPerformRequestsWithTarget:instance_];
    [adView_ performSelector:@selector(__free)];
    adView_ = nil;
    instance_ = nil;
    _logd_tm(self, @"freeInstance",nil);
}

#pragma mark AdView delegate (+GUJAdViewControllerDelegate)
- (void)viewWillLoadAd:(GUJAdView *)adView
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(bannerViewWillLoadAdData:)] ) {
        [delegate_ bannerViewWillLoadAdData:adView];
    }    
    _logd_tm(self,@"viewWillLoadAd:",adView ,nil);  
}

- (void)view:(GUJAdView*)adView didLoadAd:(GUJAdData*)adData
{
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(bannerViewDidLoadAdData:)] ) {
        [delegate_ bannerViewDidLoadAdData:adView];
    }    
    _logd_tm(self,@"view:didLoadAd:",[adData asNSUTF8StringRepresentation] ,nil);
}

- (void)view:(GUJAdView*)adView didFailToLoadAdWithUrl:(NSURL*)adUrl andError:(NSError*)error
{    
    if( [GUJUtil typeIsNotNil:delegate_ andRespondsToSelector:@selector(bannerView:didFialLoadingAdWithError:)] ) {
        [delegate_ bannerView:adView didFialLoadingAdWithError:error];
    }    
    _logd_tm(self,@"view:didFailToLoadAdWithUrl:andError:",error,[adUrl debugDescription],nil);
}

@end
