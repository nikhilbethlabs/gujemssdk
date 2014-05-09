//
//  AdDescriptor.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 2/22/11.
//

#import "MASTAdDescriptor.h"
#import "MASTServerXMLResponseParser.h"
#import "MASTAdDescriptorHelper.h"

@implementation MASTAdDescriptor

@synthesize adContentType, externalCampaign, externalContent, appId, adId, adType, latitude,longitude, zip, campaignId, trackUrl, serverReponse, serverReponseString;

+ (MASTAdDescriptor*)descriptorFromContent:(NSData*)data frameSize:(CGSize)frameSize {
	MASTAdDescriptor* adDescriptor = [MASTAdDescriptor  new];
	
	if (data) {
        if ([data length] == 0) {
            adDescriptor.adContentType = AdContentTypeEmpty;
        } else {
            adDescriptor.serverReponse = data;
            adDescriptor.externalCampaign = NO;
            
            NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            adDescriptor.serverReponseString = dataString;
            [dataString release];
            
            adDescriptor.adContentType = AdContentTypeUndefined;
            
            if ([adDescriptor.serverReponseString.lowercaseString rangeOfString:@"<!-- invalid params -->"].location != NSNotFound) {
                adDescriptor.adContentType = AdContentTypeInvalidParams;
            } else if ([adDescriptor.serverReponseString.lowercaseString rangeOfString:@"<!-- error: -1 -->"].location != NSNotFound) {
                adDescriptor.adContentType = AdContentTypeInvalidParams;
            } else if ([MASTAdDescriptorHelper isExternalCampaign:adDescriptor.serverReponseString]) {
                adDescriptor.externalCampaign = YES;
                
                MASTServerXMLResponseParser* _xmlResponseParser = [[MASTServerXMLResponseParser alloc] init];
                [_xmlResponseParser startParseSynchronous:adDescriptor.serverReponseString];
                
                adDescriptor.externalContent = _xmlResponseParser.content;
                
                adDescriptor.adContentType = AdContentTypeUndefined;
                
                [_xmlResponseParser release];
            } else {
                NSString* clearHtml = [MASTAdDescriptorHelper stringByStrippingHTMLcomments:adDescriptor.serverReponseString];
                if ([clearHtml length] > 0) {
                    adDescriptor.adContentType = AdContentTypeDefaultHtml;
                    adDescriptor.serverReponse = [adDescriptor.serverReponseString dataUsingEncoding:NSUTF8StringEncoding];
                } else {
                    adDescriptor.adContentType = AdContentTypeUndefined;
                }
                
            }
        }
	} else {
		adDescriptor.adContentType = AdContentTypeUndefined;
	}
	
	return [adDescriptor autorelease];
}

- (void)dealloc {
    self.externalContent = nil;
	[appId release];
	[adId release];
	[adType release];
	[latitude release];
	[longitude release];
	[zip release];
	[campaignId release];
	[trackUrl release];
	[serverReponse release];
	[serverReponseString release];
	
	[super dealloc];
}

@end
