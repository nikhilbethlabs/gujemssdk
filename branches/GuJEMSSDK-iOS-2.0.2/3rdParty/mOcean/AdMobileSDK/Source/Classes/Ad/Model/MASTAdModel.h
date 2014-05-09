//
//  AdModel.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/1/11.
//

#import <Foundation/Foundation.h>

#import "MASTAdView.h"
#import "MASTAdDelegate.h"
#import "MASTSharedModel.h"
#import "MASTAdDescriptor.h"


@interface MASTAdModel : NSObject {

}

@property (assign) id <MASTAdViewDelegate>	delegate;

@property (readonly) BOOL				readyForDisplay;

@property BOOL							testMode;
@property AdLogMode                     logMode;
@property BOOL							isAdChangeAnimated;
@property BOOL							internalOpenMode;
@property NSInteger						track;
@property NSTimeInterval				updateTimeInterval;
@property (retain) UIImage*				defaultImage;

@property (assign) NSInteger			site;
@property (assign) NSInteger			adZone;
@property AdPremium                     premiumFilter;
@property AdType                        type;
@property (retain) NSString*			keywords;
@property CGSize						minSize;
@property CGSize						maxSize;
@property (retain) UIColor*             paramBG;
@property (retain) UIColor*             paramLINK;
@property (retain) NSDictionary*        additionalParameters;
@property (retain) NSString*			adServerUrl;
@property (assign) NSInteger            adCallTimeout;

@property (assign) NSInteger			advertiserId;
@property (retain) NSString*			groupCode;

@property (retain) NSString*            country;
@property (retain) NSString*            region;
@property (retain) NSString*            city;
@property (retain) NSString*            area;
@property (retain) NSString*            dma;
@property (retain) NSString*            zip;
@property (retain) NSString*            carrier;

@property NSTimeInterval                showCloseButtonTime;
@property NSTimeInterval                autocloseInterstitialTime;
@property (retain) NSDate*              startDisplayDate;
@property BOOL                          isDisplayed;

@property (retain) NSString*            injectionHeaderCode;

@property CGRect						frame;
@property BOOL                          visibleState;

@property (retain) NSData*              snapshotRAWData;
@property (retain) NSDate*              snapshotRAWDataTime;
@property (retain) UIView*              currentAdView;
@property (assign) MASTAdView*              adView;

@property (retain) NSMutableArray*      excampaigns;
@property (retain) MASTAdDescriptor*        descriptor;

@property (assign) BOOL                 loading;

@property (retain) NSString*            latitude;
@property (retain) NSString*            longitude;
@property (assign) BOOL                 autoCollapse;
@property (assign) BOOL                 showPreviousAdOnError;

@property (retain) NSString*            udid;

- (NSString*)url;
- (NSString*)urlIgnoreValifation;

- (void)cancelAllNetworkConnection;
- (void)closeInternalBrowser;
- (BOOL)isFirstDisplay;

@end
