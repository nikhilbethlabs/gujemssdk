//
//  UIWebViewAdditions.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/3/11.
//

#import "MASTUIWebViewAdditions.h"


void useCatagory9(){
    NSLog(@"do nothing, just for make catagory linked");
}

@implementation UIWebView (UIView_mOcean)

- (void)disableBouncesForWebView {
	for (id subview in self.subviews)
	{
		if ([[subview class] isSubclassOfClass: [UIScrollView class]])
		{
			((UIScrollView *)subview).bounces = NO;
			((UIScrollView *)subview).scrollEnabled = NO;
		}
	}
}

@end
