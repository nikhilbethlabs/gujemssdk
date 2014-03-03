/*
 * BSD LICENSE
 * Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, 
 * this list of conditions and the following disclaimer .
 * Redistributions in binary form must reproduce the above copyright notice, 
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The source code is just allowed for private use, not for commercial use.
 * 
 */
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <net/if_dl.h>
#import <net/if.h>
#import <sys/sysctl.h>

#define kGUJUtilStringFormatForUseragentString @"Mozilla/5.0 (%@; CPU %@ OS %@_%@ like Mac OS X) AppleWebKit/420+ (KHTML, like Gecko) Version/%@.%@ Mobile/%@ Safari/419.3"

@interface GUJUtil : NSObject


+ (NSDictionary*)availableNetworkInterfacesWithAddresses;
+ (NSString*)internetAddressStringRepresentationForNetworkInterface:(NSString*)interfaceName;
+ (NSString*)internetAddressStringRepresentationForWiFiNetwork;
+ (NSString*)internetAddressStringRepresentationForCellularNetwork;
+ (NSString*)internetAddressStringRepresentation;
+ (NSString*)networkInterfaceName;

// system related
/*!
 get an nserror for the given domain and code. userInfo will be nil
 */
+ (NSError*)errorForDomain:(NSString*)domain andCode:(NSInteger)code;

/*!
 returns an NSError eq to [[NSError alloc] initWithDomain: code: userInfo:]
 */
+ (NSError*)errorForDomain:(NSString*)domain andCode:(NSInteger)code withUserInfo:(NSDictionary *)dict;


// type related
/*!
 checks if the type is not nil and responds to the given selector. protocoll independent.
 */
+ (BOOL)typeIsNotNil:(id)type andRespondsToSelector:(SEL)selector;

+ (NSString *)iosBuildVersion;
+ (NSInteger)iosVersion;
+ (NSString*)iosPlatform;
+ (NSString*)deviceModel;

+ (BOOL)iPhoneDevice;
+ (BOOL)iPadDevice;
+ (BOOL)iPodDevice;

+ (time_t)timeStamp;
+ (NSNumber*)timeStampAsNSNumber;
+ (NSNumber*)javaCalendarTimeStampAsNSNumber;

+ (NSString *)UUIDNSStringRepresentation;
+ (NSString*)applicationAdSpaceUUID;
+ (NSString*)md5HashedApplicationAdSpaceUUID;

+ (NSString*)formattedHttpUserAgentString;

+ (NSUInteger)statusBarOffset;

+ (id)firstResponder;
+ (CGSize)sizeOfKeyWindow;
+ (CGRect)frameOfKeyWindow;

+ (CGSize)sizeOfFirstResponder;
+ (CGRect)frameOfFirstResponder;

+ (UIViewController*)parentViewController;
+ (BOOL)showPresentModalViewController:(UIViewController*)viewController;

+ (BOOL)isSubView:(UIView*)view of:(UIView*)potentialOwner;
+ (BOOL)isLandscapeLayout;
+ (BOOL)isPortraitLayout;

+ (BOOL)openNativeURL:(NSURL*)url;

+ (void)changeInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
