#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "AdViewController.h"
#import "AdReachability.h"
#import "VideoAdSDK.h"

@class ADView;

@interface VideoAdSDK (  ) {
@private
    id<VideoAdSDKDelegate>       _delegate;
    NSString                *_publisherID;
    NSMutableDictionary     *_userAttributes;
    
    UIWindow                *_window;
    UIWindow                *_savedWindow;
    ADView                  *_adView;
    AdViewController        *_viewController;
    CLLocationManager       *_locationManager;
    CLLocation              *_currentLocation;
    AdReachability          *_reachability;
    NSMutableArray          *_assetDownloads;
    NSOperationQueue        *_operationQueue;
    int                     _prefetchingID;
    BOOL                    _statusBarWasHidden;
    UIInterfaceOrientation  _savedOrientation;
    BOOL                    _prefetching;
    float                    _volume;
    BOOL                    _locked;
    NSString                *_savedAudioSessionCategory;
    NSString                *_savedAudioSessionMode;
}

@property (copy, nonatomic) NSString *publisherID;
@property (retain, nonatomic) NSMutableDictionary *userAttributes;
@property (retain, nonatomic) AdViewController *viewController;
@property (retain, nonatomic) CLLocation *currentLocation;
@property (retain, nonatomic) NSMutableArray *assetDownloads;
@property (assign, nonatomic) BOOL prefetching;
@property (assign, nonatomic) NSTimeInterval timeout;

- (void)_exitAdvertising;
- (void)_addAssetDownload:(NSURL*)url;
- (void)_showAdWindow:(BOOL)webview;

@end
