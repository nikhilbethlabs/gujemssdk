//
//  UIViewAdditions.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/9/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


// do nothing, just for make this catagory linked
void useCatagory8();

@interface UIView (UIView_mOcean)

- (BOOL)isViewVisible;
- (UIImageView*)takeSnapshot;
- (UIViewController*)viewControllerForView;
- (NSData*)ARGBData;
- (BOOL)isPointTransparent:(CGPoint)point rawData:(NSData*)rawData;
- (BOOL)isPointTransparent:(CGPoint)point;
@end
