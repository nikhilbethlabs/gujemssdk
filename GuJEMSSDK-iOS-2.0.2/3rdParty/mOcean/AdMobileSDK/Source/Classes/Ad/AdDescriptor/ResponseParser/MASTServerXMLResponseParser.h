//
//  ServerResponseParser.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 10/8/10.
//

#import <Foundation/Foundation.h>

#import "MASTAdDescriptor.h"


// Delegate support not implemented yet

@protocol ServerXMLResponseParserDelegate <NSObject>
@required
- (void)xmlParsingFinished:(id)sender;
- (void)xmlReadError:(id)sender;
@end

@interface MASTServerXMLResponseParser : NSObject <NSXMLParserDelegate> {
	//id <ServerXMLResponseParserDelegate>	_delegate;
	NSXMLParser*							_parser;
	
	BOOL									_startSynchronous;
	
	NSString*								_propertyName;
	NSMutableString*						_propertyContent;
	
	NSString*								_campaignId;
	AdContentType							_adContentType;
	NSString*								_trackUrl;
	NSString*								_appId;
	NSString*								_adId;
	NSString*								_adType;
}

//@property (nonatomic, assign) id <ServerXMLResponseParserDelegate> delegate;

@property (retain) NSXMLParser*	parser;

@property (retain) NSString* propertyName;
@property (retain) NSMutableString* propertyContent;
@property (retain) NSMutableDictionary* content;

@property (readonly) AdContentType adContentType;
@property (retain) NSString* campaignId;
@property (retain) NSString* trackUrl;
@property (retain) NSString* appId;
@property (retain) NSString* adId;
@property (retain) NSString* adType;
@property (retain) NSString* latitude;
@property (retain) NSString* longitude;
@property (retain) NSString* zip;


- (void) startParseSynchronous:(NSString*)content;

@end
