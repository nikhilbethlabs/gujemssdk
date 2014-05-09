//
//  MASTInternalAVPlayer.h
//


#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MASTInternalAVPlayer : NSObject

+ (MASTInternalAVPlayer*)sharedInstance;
- (void)playAudio:(NSDictionary*)info;
- (void)playVideo:(NSDictionary*)info;
@end
