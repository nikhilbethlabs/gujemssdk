//
//  Utils.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/1/11.
//

#import "MASTUtils.h"
#import "MASTConstants.h"
#import "UIAlertView+Blocks.h"

#import "UIActionSheet+Blocks.h"
#import "MAPNSObject+AssociatedObjects.h"
#import "MAPNSObject+BlockObservation.h"
#import "MAPNSDictionary+BlocksKit.h"

#import "MASTUIViewAdditions.h"
#import "MASTUIWebViewAdditions.h"
#import "MASTUIColorAdditions.m"

#import <SystemConfiguration/SystemConfiguration.h>

#include <sys/types.h>
#include <sys/sysctl.h>


void NSProfile(const char *name, void (^work) (void)) {
    struct timeval start, end;
    gettimeofday (&start, NULL);
    
    work();
    
    gettimeofday (&end, NULL);
    
    double fstart = (start.tv_sec * 1000000.0 + start.tv_usec) / 1000000.0;
    double fend = (end.tv_sec * 1000000.0 + end.tv_usec) / 1000000.0;
    
    printf("%s took %f seconds", name, fend - fstart);
}

// No-ops for non-retaining objects.
static const void* RetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void ReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray* CreateNonRetainingArray() {
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.retain = RetainNoOp;
    callbacks.release = ReleaseNoOp;
    return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

NSMutableDictionary* CreateNonRetainingDictionary() {
    CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
    CFDictionaryValueCallBacks callbacks = kCFTypeDictionaryValueCallBacks;
    callbacks.retain = RetainNoOp;
    callbacks.release = ReleaseNoOp;
    return (NSMutableDictionary*)CFDictionaryCreateMutable(nil, 0, &keyCallbacks, &callbacks);
}

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

@implementation MASTUtils

NSString * NSCacheDirectory() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
    NSString *cacheDirectory = [paths objectAtIndex:0];
    return  cacheDirectory;
    //return [NSHomeDirectory() stringByAppendingPathComponent: @"/Library/Caches/"];
}

+ (NSString*)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString*)platformFormatedString {
    NSString *platform = [MASTUtils platform];
    if ([platform isEqualToString:@"iPhone1,1"])	return PLTFORM_IPHONE_1G;
    if ([platform isEqualToString:@"iPhone1,2"])	return PLTFORM_IPHONE_3G;
    if ([platform isEqualToString:@"iPhone2,1"])	return PLTFORM_IPHONE_3GS;
    if ([platform isEqualToString:@"iPhone3,1"])	return PLTFORM_IPHONE_4;
    if ([platform isEqualToString:@"iPod1,1"])		return PLTFORM_IPOD_1G;
    if ([platform isEqualToString:@"iPod2,1"])		return PLTFORM_IPOD_2G;
    if ([platform isEqualToString:@"iPod3,1"])		return PLTFORM_IPOD_3G;
    if ([platform isEqualToString:@"i386"])			return PLTFORM_IPHONE_SIMULATOR;
    return platform;
}

+ (NSArray*)linksFromText:(NSString*)text {
    NSMutableArray* links = [NSMutableArray array];
    
    // TODO: get src from \' and ' and cache!
	
	NSScanner* strScanner = [NSScanner scannerWithString:text];
	NSString* tempString = [NSString string];
	
	while([strScanner scanUpToString:@"src=\"" intoString:NULL] &&
		  [strScanner scanString:@"src=\"" intoString:NULL] &&
		  [strScanner scanUpToString:@"\"" intoString:&tempString])
	{
		[links addObject:tempString];
	}
	
	return links;
}

+ (NSURL*)appUrl:(NSURLRequest *)request {
	return [NSURL URLWithString:[[[request URL] absoluteString] stringByReplacingOccurrencesOfString:@"http" withString:@"itms-apps"]];
}

+ (BOOL)canGetHexColor:(UIColor*)color {
    return [color canProvideRGBComponents];
}

+ (NSString*)hexColor:(UIColor*)color {
    if ([color canProvideRGBComponents]) {
        return [color hexStringFromColor];
    } else {
        return nil;
    }
}

+ (NSString*)videoUrlFromString:(NSString*)string {
	NSString* result = nil;
	
	NSScanner* strScanner = [NSScanner scannerWithString:string];
	NSString* tempString = [NSString string];
	
	if ([strScanner scanUpToString:@"<video" intoString:NULL] &&
		[strScanner scanUpToString:@"src=\"" intoString:NULL] &&
		[strScanner scanString:@"src=\"" intoString:NULL] &&
		[strScanner scanUpToString:@"\"" intoString:&tempString]) {
		result = tempString;
	}
	
	return result;
}

+ (NSString*)aHrefUrlfromString:(NSString*)string {
	NSString* result = nil;
	
	NSScanner* strScanner = [NSScanner scannerWithString:string];
	NSString* tempString = [NSString string];
	
	if ([strScanner scanUpToString:@"href=\"" intoString:NULL] &&
		[strScanner scanString:@"href=\"" intoString:NULL] &&
		[strScanner scanUpToString:@"\"" intoString:&tempString]) {
		result = tempString;
	}
	
	return result;
}

+ (BOOL)isInternalURL:(NSURL*)url {
    NSString* strURL = [url absoluteString];
    if (url && strURL) {        
        BOOL internalURL = YES;
        
        if ([strURL rangeOfString:@"http://"].location == NSNotFound) {
            internalURL = NO;
        } else {
            if ([strURL rangeOfString:@".apple.com/WebObjects"].location != NSNotFound) {
                internalURL = NO;
            } else if ([strURL rangeOfString:@"itunes.apple.com/"].location != NSNotFound) {
                internalURL = NO;
            } else if ([strURL rangeOfString:@"mailto:"].location != NSNotFound) {
                internalURL = NO;
            } else if ([strURL rangeOfString:@"tel:"].location != NSNotFound) {
                internalURL = NO;
            } else if ([strURL rangeOfString:@"sms:"].location != NSNotFound) {
                internalURL = NO;
            } else if ([strURL rangeOfString:@"www.youtube.com"].location != NSNotFound) {
                internalURL = NO;
            } else if ([strURL rangeOfString:@"maps.google.com/maps?"].location != NSNotFound) {
                internalURL = NO;
            }
        }
        
        return internalURL;
    } else {
        return  NO;
    }
    
    return YES;
}

+ (BOOL)isInternalScheme:(NSURL*)url {
    return [url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"] ? YES : NO;
}

+ (NSInteger)randomInteger:(NSInteger)maxInt {
    return arc4random() % maxInt;
}

#pragma mark -
#pragma mark NSData


+ (NSString*)md5HashForData:(NSData*)data  {
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([data bytes], [data length], result);
	
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

+ (NSString*)sha1HashForData:(NSData*)data {
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1([data bytes], [data length], result);
	
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
			result[16], result[17], result[18], result[19]
			];
}


#pragma mark -
#pragma mark NSString


+ (NSString*)md5HashForString:(NSString*)string {
	return [MASTUtils md5HashForData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString*)sha1HashForString:(NSString*)string {
	return [MASTUtils sha1HashForData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)makeLibraryLinked {
    useCatagory3();
    useCatagory4();
    useCatagory5();
    useCatagory6();
	useCatagory7();
    useCatagory8();
    useCatagory9();
}

+ (NSString*)md5OfString:(NSString*)string {
    // Create pointer to the string as UTF8
    const char *ptr = [string UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (NSData*)decodeBase64WithString:(NSString*)strBase64 {
	const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
	int intLength = strlen(objPointer);
	int intCurrent;
	int i = 0, j = 0, k;
    
	unsigned char * objResult;
	objResult = calloc(intLength, sizeof(char));
    
	// Run through the whole string, converting as we go
	while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
		if (intCurrent == '=') {
			if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
				// the padding character is invalid at this point -- so this entire string is invalid
				free(objResult);
				return nil;
			}
			continue;
		}
        
		intCurrent = _base64DecodingTable[intCurrent];
		if (intCurrent == -1) {
			// we're at a whitespace -- simply skip over
			continue;
		} else if (intCurrent == -2) {
			// we're at an invalid character
			free(objResult);
			return nil;
		}
        
		switch (i % 4) {
			case 0:
				objResult[j] = intCurrent << 2;
				break;
                
			case 1:
				objResult[j++] |= intCurrent >> 4;
				objResult[j] = (intCurrent & 0x0f) << 4;
				break;
                
			case 2:
				objResult[j++] |= intCurrent >>2;
				objResult[j] = (intCurrent & 0x03) << 6;
				break;
                
			case 3:
				objResult[j++] |= intCurrent;
				break;
		}
		i++;
	}
    
	// mop things up if we ended on a boundary
	k = j;
	if (intCurrent == '=') {
		switch (i % 4) {
			case 1:
				// Invalid state
				free(objResult);
				return nil;
                
			case 2:
				k++;
				// flow through
			case 3:
				objResult[k] = 0;
		}
	}
    
	// Cleanup and setup the return NSData
	NSData * objData = [[[NSData alloc] initWithBytes:objResult length:j] autorelease];
	free(objResult);
	return objData;
}

+ (BOOL)saveData:(NSData*)data dirPath:(NSString*)dirPath fileName:(NSString*)fileName {
    BOOL result = NO;
    NSString* path = [dirPath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if ([data writeToFile:path atomically:YES]) {
            result = YES;
        }
    }
    else {
        result = YES;
    }
    
    return result;
}


+ (UIImage*)closeImage {
    NSString* dirPath = [NSCacheDirectory() stringByAppendingPathComponent:@"/MAPCache"];
    NSString* fileName = @"closeIcon.png";
    
    NSString* path = [dirPath stringByAppendingPathComponent:fileName];
    UIImage* closeIcon = nil;
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        NSData* imageData = [self decodeBase64WithString:kCloseIconB64];
        NSData* imageData2x = [self decodeBase64WithString:kCloseIcon2xB64];
        [self saveData:imageData dirPath:dirPath fileName:@"closeIcon.png"];
        [self saveData:imageData2x dirPath:dirPath fileName:@"closeIcon@2x.png"];
    }
    
    closeIcon = [UIImage imageWithContentsOfFile:path];
    
    return closeIcon;
}

@end
