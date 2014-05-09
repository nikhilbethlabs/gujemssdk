//
//  Utils.h
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/1/11.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

#define RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }


NSMutableArray* CreateNonRetainingArray();
NSMutableDictionary* CreateNonRetainingDictionary();

void NSProfile(const char *name, void (^work) (void));

@interface MASTUtils : NSObject {}

+ (NSString*)platform;
+ (NSString*)platformFormatedString;

+ (NSArray*)linksFromText:(NSString*)text;

+ (NSURL*)appUrl:(NSURLRequest *)request;

+ (BOOL)canGetHexColor:(UIColor*)color;
+ (NSString*)hexColor:(UIColor*)color;

+ (NSString*)videoUrlFromString:(NSString*)string;
+ (NSString*)aHrefUrlfromString:(NSString*)string;

+ (void)makeLibraryLinked;
+ (BOOL)isInternalURL:(NSURL*)url;
+ (BOOL)isInternalScheme:(NSURL*)url;

+ (NSInteger)randomInteger:(NSInteger)maxInt;

+ (NSString*)md5HashForData:(NSData*)data;
+ (NSString*)sha1HashForData:(NSData*)data;
+ (NSString*)md5HashForString:(NSString*)string;
+ (NSString*)sha1HashForString:(NSString*)string;

+ (NSString*)md5OfString:(NSString*)string;
+ (NSData*)decodeBase64WithString:(NSString*)strBase64;
+ (UIImage*)closeImage;

@end
