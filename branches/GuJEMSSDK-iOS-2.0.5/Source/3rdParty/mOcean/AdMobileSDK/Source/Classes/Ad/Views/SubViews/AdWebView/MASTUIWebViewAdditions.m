//
//  MASTUIWebViewAdditions.m
//

#import "MASTUIWebViewAdditions.h"


void useCatagory1(){
    NSLog(@"do nothing, just for make catagory linked");
}

@implementation UIWebView (MAPWebView)

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
