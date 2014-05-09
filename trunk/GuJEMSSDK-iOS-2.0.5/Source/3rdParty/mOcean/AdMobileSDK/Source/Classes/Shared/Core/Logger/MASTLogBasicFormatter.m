//
//  LogBasicFormatter.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 8/19/10.
//

#import "MASTLogBasicFormatter.h"


@implementation MASTLogBasicFormatter

+ (NSString *)stringWithFormat:(NSString *)fmt valist:(va_list)args
{
	CFStringRef cfmsg = NULL;
	cfmsg = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault,
												 NULL,  // format options
												 (CFStringRef)fmt,
												 args);
	
	return [((id)NSMakeCollectable(cfmsg)) autorelease];
}

@end
