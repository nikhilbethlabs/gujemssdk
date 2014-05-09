//
//  OrmmaProtocols.h
//

#import <UIKit/UIKit.h>

#define kOrmmaLocationUpdated       @"Location Updated"
#define kOrmmaHeadingUpdated        @"Heading Updated"
#define kOrmmaTiltUpdated           @"Tilt Updated"
#define kOrmmaShake                 @"Shake Event"
#define kOrmmaKeySender				@"ormma_sender"
#define kOrmmaKeyObject				@"ormma_object"

typedef enum ORMMAStateEnum {
	ORMMAStateHidden = -1,
	ORMMAStateDefault = 0,
	ORMMAStateResized,
	ORMMAStateExpanded
} ORMMAState;

@protocol OrmmaDelegate <NSObject>
@optional

- (BOOL)supportAudioForAd:(id)sender;
- (BOOL)supportVideoForAd:(id)sender;
- (BOOL)supportMapForAd:(id)sender;
- (BOOL)supportCalendarForAd:(id)sender;
- (BOOL)supportEmailForAd:(id)sender;
- (BOOL)supportSmsForAd:(id)sender;
- (BOOL)supportPhoneForAd:(id)sender;

- (CGSize)maxSizeForAd:(id)sender;

- (void)showAd:(id)sender;
- (void)hideAd:(id)sender;
- (void)closeFromState:(ORMMAState)state ad:(id)sender;
- (void)resize:(CGSize)size ad:(id)sender;
- (void)expandURL:(NSString*)url parameters:(NSDictionary*)parameters ad:(id)sender;

- (void)phone:(NSString*)number ad:(id)sender;
- (void)sms:(NSString*)to body:(NSString*)body ad:(id)sender;
- (void)email:(NSString*)to subject:(NSString*)subject body:(NSString*)body useHtml:(BOOL)useHtml ad:(id)sender;
- (void)calendar:(NSString*)title body:(NSString*)body date:(NSDate*)date ad:(id)sender;
- (void)openMapWithPOI:(NSString*)poi ad:(id)sender;
- (void)playAudio:(NSString*)url parameters:(NSDictionary*)parameters ad:(id)sender;
- (void)playVideo:(NSString*)url parameters:(NSDictionary*)parameters ad:(id)sender;
- (void)sendRequest:(NSString*)url display:(NSString*)display response:(void (^)(NSString* response))response ad:(id)sender;

- (void)debug:(NSString*)query ad:(id)sender;
- (void)service:(NSString*)name enabled:(BOOL)enabled ad:(id)sender;

@end

@protocol OrmmaDataSource <NSObject>
@optional

- (BOOL)supportLocationForAd:(id)sender;
- (BOOL)supportHeadingForAd:(id)sender;
- (BOOL)supportTiltForAd:(id)sender;

@end