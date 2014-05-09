#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol VideoAdSDKDelegate <NSObject>

@optional
- (void)advertisingIsPreparingToPlay;
- (void)advertisingWillShow;
- (void)advertisingDidHide;
- (void)advertisingClicked;
- (void)advertisingPrefetchingDidComplete;
- (void)advertisingPrefetchingDidCompleteWithAd:(BOOL)adAvailable;
- (void)advertisingNotAvailable;
- (void)advertisingFailedToLoad:(NSError*)error;
- (void)advertisingEventTracked:(NSString*)event;
@end

@interface VideoAdSDK : NSObject<CLLocationManagerDelegate> {
}

@property (retain, nonatomic) id<VideoAdSDKDelegate> delegate;
@property (assign, atomic) BOOL compatibleEnvironment;
@property (assign, atomic) BOOL allowCellularPrefetching;

+ (VideoAdSDK*)sharedInstance;
+ (VideoAdSDK*)_sharedInstance;

+ (BOOL)registerWithPublisherID:(NSString*)publisherID delegate:(id<VideoAdSDKDelegate>)delegate;
+ (BOOL)playAdvertising;
+ (BOOL)prefetchAdvertising;
+ (void)setUserAttribute:(NSString*)attribute forKey:(NSString*)key;
+ (void)setDelegate:(id<VideoAdSDKDelegate>)delegate;


@end


@interface SSMoviePlayerController : MPMoviePlayerController<VideoAdSDKDelegate>

@property (assign, nonatomic) BOOL canPlayMovie;


@end
