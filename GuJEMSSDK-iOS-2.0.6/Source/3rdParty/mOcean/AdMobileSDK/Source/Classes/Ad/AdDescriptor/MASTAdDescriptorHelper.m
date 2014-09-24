//
//  AdDescriptorHelper.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/3/11.
//

#import "MASTAdDescriptorHelper.h"
#import "MASTOrmmaConstants.h"

@interface MASTAdDescriptorHelper()

+ (BOOL)isLandscapeMode;
+ (BOOL)isStatusBarHidden;

@end

@implementation MASTAdDescriptorHelper

+ (BOOL)isMedialetsContent:(NSString *)data
{
	NSRange textRange = [data rangeOfString:@"medialets:launchAd?"];
	
	return textRange.location != NSNotFound;
}

+ (BOOL)isVideoContent:(NSString *)data
{
	NSRange textRange = [data rangeOfString:@"<video"];
	
	return textRange.location != NSNotFound;
}


+ (BOOL)isExternalCampaign:(NSString *)data
{
	NSRange textRange = [data rangeOfString:@"<!-- client_side_external_campaign"];
	
	return textRange.location != NSNotFound;
}

+ (NSString*)stringByStrippingHTMLcomments:(NSString *)html {
    NSScanner *thescanner;
    NSString *text = nil;
    
    if ([html rangeOfString:@"<!--//"].location == NSNotFound) {
        thescanner = [NSScanner scannerWithString:html];
        
        while ([thescanner isAtEnd] == NO) {
            
            // find start of tag
            [thescanner scanUpToString:@"<!--" intoString:nil] ; 
            
            // find end of tag
            [thescanner scanUpToString:@"-->" intoString:&text] ;
            
            // replace the found tag with a space
            //(you can filter multi-spaces out later if you wish)
            html = [html stringByReplacingOccurrencesOfString:
                    [NSString stringWithFormat:@"%@-->", text] withString:@""];
            
        } // while //
    }
    
    return html;	
}

+ (BOOL)isLandscapeMode {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isLandscapeMode = UIDeviceOrientationIsLandscape(orientation);
    return isLandscapeMode;
}

+ (BOOL)isStatusBarHidden {
    return [[UIApplication sharedApplication] isStatusBarHidden];
}

@end
