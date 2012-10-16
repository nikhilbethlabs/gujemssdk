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
@implementation GUJUtil

#pragma mark - objc related
+ (NSError*)errorForDomain:(NSString*)domain andCode:(NSInteger)code
{
    return [GUJUtil errorForDomain:domain andCode:code withUserInfo:nil];
}

+ (NSError*)errorForDomain:(NSString*)domain andCode:(NSInteger)code withUserInfo:(NSDictionary *)dict
{
    return [[NSError alloc] initWithDomain:domain code:code userInfo:dict];
}

+ (BOOL)typeIsNotNil:(id)type andRespondsToSelector:(SEL)selector
{
    BOOL result = NO;
    if( type != nil ) {
        if( [type respondsToSelector:selector] ) {
            result = YES;
        }
    }        
    return result;
}

#pragma mark system related
+ (NSString *)iosBuildVersion 
{
    /*
     * StackOverflow: http://bit.ly/NxpcVG
     */
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    u_int namelen = sizeof(mib) / sizeof(mib[0]);
    size_t bufferSize = 0;
    
    NSString *osBuildVersion = nil;
    
    // Get the size for the buffer
    sysctl(mib, namelen, NULL, &bufferSize, NULL, 0);
    
    u_char buildBuffer[bufferSize];
    int result = sysctl(mib, namelen, buildBuffer, &bufferSize, NULL, 0);
    
    if (result >= 0) {
        osBuildVersion = [[NSString alloc] initWithBytes:buildBuffer length:bufferSize encoding:NSUTF8StringEncoding]; 
    }
    
    return osBuildVersion;   
}

+ (NSInteger)iosVersion
{
    NSInteger result = 0;
    NSArray *versionChunks = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    int chunkIndex = 0;    
    for (NSString *numChunk in versionChunks) {
        if (chunkIndex > 2) break;
        result += [numChunk intValue]*(powf(100, (2-chunkIndex)));
        chunkIndex++;
    }
    return result;
}

+ (NSString*)iosPlatform
{
    return [UIDevice currentDevice].model;
}

+ (NSString*)deviceModel 
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);      
    
    return deviceModel;
}

+ (BOOL)iPhoneDevice
{
    return ([[GUJUtil iosPlatform] rangeOfString:kGUJDeviceTypeStringiPhone].location != NSNotFound);
}

+ (BOOL)iPadDevice
{
    return ([[GUJUtil iosPlatform] rangeOfString:kGUJDeviceTypeStringiPad].location != NSNotFound);
}

+ (BOOL)iPodDevice
{
    return ([[GUJUtil iosPlatform] rangeOfString:kGUJDeviceTypeStringiPod].location != NSNotFound);
}

+ (NSString *)formattedHttpUserAgentString
{
    NSString *result = kEmptyString;
    NSArray *versionChunks = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    NSString *deviceModel   = [GUJUtil iosPlatform];
    NSString *deviceArc     = deviceModel;
    NSString *version       = [versionChunks objectAtIndex:0];
    NSString *subVersion    = [versionChunks objectAtIndex:1];
    
    if( [[deviceModel componentsSeparatedByString:kWhiteSpaceString] count] > 0 ) {
        deviceArc   = [[deviceModel componentsSeparatedByString:kWhiteSpaceString] objectAtIndex:0];      
    }
    
    result = [NSString stringWithFormat:kGUJUtilStringFormatForUseragentString,deviceModel,deviceArc,version,subVersion,version,subVersion,[GUJUtil iosBuildVersion]];
    return result;
}

+ (NSDictionary*)availableNetworkInterfacesWithAddresses 
{    
    NSMutableDictionary *result             = [[NSMutableDictionary alloc] init];
    
    struct ifaddrs      *interfaces         = nil;
    struct ifaddrs      *interface_address  = nil;
    struct sockaddr_in  *socket_address     = nil;    
    char         *inet_address       = nil;
    sa_family_t  address_family      = 0;
    
    if( getifaddrs(&interfaces) == 0 ) {
        interface_address = interfaces;
        
        while(interface_address != nil) {
            address_family = interface_address->ifa_addr->sa_family;
            if(address_family == AF_INET || // ipv4
               address_family == AF_INET6   // ipv6
               ) {
                NSString *interfaceName = [NSString stringWithUTF8String:interface_address->ifa_name];                
                socket_address          = ((struct sockaddr_in *)interface_address->ifa_addr);
                inet_address            = inet_ntoa(socket_address->sin_addr);       
                [result setObject:[NSString stringWithUTF8String:inet_address] forKey:interfaceName];
            }                    
            interface_address = interface_address->ifa_next;
        }//while       
        
    }
    inet_address     = nil;
    socket_address   = nil;
    interface_address= nil;
    freeifaddrs(interfaces);
    return result;    
} 


+ (NSString*)internetAddressStringRepresentationForNetworkInterface:(NSString*)interfaceName
{
    return [[GUJUtil availableNetworkInterfacesWithAddresses] objectForKey:interfaceName];
}

+ (NSString*)internetAddressStringRepresentationForWiFiNetwork
{
    return ([[GUJUtil availableNetworkInterfacesWithAddresses] objectForKey:kNetworkInterfaceIdentifierForTypeEn0] ? : kNetworkUndefinedInterfaceAddress);
}

+ (NSString*)internetAddressStringRepresentationForCellularNetwork
{
    return ([[GUJUtil availableNetworkInterfacesWithAddresses] objectForKey:kNetworkInterfaceIdentifierForTypePdp_ip0] ? : kNetworkUndefinedInterfaceAddress);
}

+ (NSString*)internetAddressStringRepresentation
{
    // WiFi network comes first
    NSString *result = [GUJUtil internetAddressStringRepresentationForWiFiNetwork];
    if( [result isEqualToString:kNetworkUndefinedInterfaceAddress] ) {
        // if not found try Cell Netfork
        result = [GUJUtil internetAddressStringRepresentationForCellularNetwork];
    }    
    return result;
}

+ (NSString*)networkInterfaceName
{
    NSString *result = nil;
    // WiFi network comes first
    if([[GUJUtil availableNetworkInterfacesWithAddresses] objectForKey:kNetworkInterfaceIdentifierForTypeEn0] != nil
       && ![[[GUJUtil availableNetworkInterfacesWithAddresses] objectForKey:kNetworkInterfaceIdentifierForTypeEn0] isEqualToString:kNetworkUndefinedInterfaceAddress] ) {
        result = kNetworkInterfaceIdentifierForTypeEn0;
    } else if([[GUJUtil availableNetworkInterfacesWithAddresses] objectForKey:kNetworkInterfaceIdentifierForTypePdp_ip0] != nil 
              && ![[[GUJUtil availableNetworkInterfacesWithAddresses] objectForKey:kNetworkInterfaceIdentifierForTypePdp_ip0] isEqualToString:kNetworkUndefinedInterfaceAddress] ) {
        result = kNetworkInterfaceIdentifierForTypePdp_ip0;
    } else {
        result = kNetworkInterfaceIdentifierForTypeLo0;
    }
    return result;
}

#pragma mark SDK related
+ (NSString *)UUIDNSStringRepresentation
{
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);    
    NSString *uuidStr = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidObject) ;      
    CFRelease(uuidObject);    
    return uuidStr;
}

+ (NSString*)applicationAdSpaceUUID
{
    NSString *result = nil;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    result = [userDefaults stringForKey:kGUJApplicationAdSpaceUUIDKey];
    if( result == nil) {
        result = [GUJUtil UUIDNSStringRepresentation];
        [userDefaults setObject:result forKey:kGUJApplicationAdSpaceUUIDKey];
        [userDefaults synchronize];
    }
    return result;
}

+ (NSString*)md5HashedApplicationAdSpaceUUID
{
    @autoreleasepool {        
        NSMutableString *result   = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
        const    char   *uuidStr  = [[GUJUtil applicationAdSpaceUUID] UTF8String];
        unsigned char   md5String[CC_MD5_DIGEST_LENGTH];
        
        CC_MD5(uuidStr, strlen(uuidStr), md5String);    
        for(int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
            [result appendFormat:@"%02x",md5String[i]];
        }
        return [result copy]; 
    }
}

#pragma mark UIKit related
/*!
 * does return CGSizeZero while initalization 
 */
+ (CGSize)sizeOfKeyWindow
{
    return [GUJUtil frameOfKeyWindow].size;
}

+ (id)firstResponder
{
    id result = nil;
    if( [[UIApplication sharedApplication] keyWindow] && [[[UIApplication sharedApplication] keyWindow] subviews]) {
        if( [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] != nil ) {
            result = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
        }
    }
    return result;
}
/*!
 * does return CGRectZero while initalization 
 */
+ (CGRect)frameOfKeyWindow
{
    CGRect result = CGRectZero;
    UIView *firstView = nil;
    if( [[UIApplication sharedApplication] keyWindow] && [[[UIApplication sharedApplication] keyWindow] subviews]) {
        if( [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] != nil ) {
            firstView = ((UIView*)[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0]);
        }
    }
    if( firstView ) {
        result = firstView.frame;
    } 
    return result;
}

+ (CGSize)sizeOfFirstResponder
{
    return [GUJUtil frameOfFirstResponder].size;
}

+ (CGRect)frameOfFirstResponder
{
    CGRect result = CGRectZero;
    if( [[UIApplication sharedApplication] keyWindow] && [[[UIApplication sharedApplication] keyWindow] subviews]) {
        if( [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] != nil ) {
            id root = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
            if( [root isKindOfClass:[UIViewController class]] ) {
                if( ((UIViewController*)root).view != nil ) {
                    result = ((UIViewController*)root).view.bounds;
                }
            } else if( [root isKindOfClass:[UIView class]] ) {
                result = ((UIView*)root).bounds;
            }
        }
    }
    if( result.size.width == CGRectZero.size.width &&  result.size.height == CGRectZero.size.height ) {
        result = [GUJUtil frameOfKeyWindow];
    }
    return result;
}

+ (UIViewController*)parentViewController
{
    UIViewController *result = nil;
    id firstResponder = [GUJUtil firstResponder];
    if( [firstResponder isKindOfClass:[UIViewController class]] ) {
        result = firstResponder;
    }
    return result;
}

+ (BOOL)showPresentModalViewController:(UIViewController*)viewController
{
    BOOL result = NO;
    UIViewController *parentViewController = [GUJUtil parentViewController];
    if( parentViewController ) {
        [parentViewController presentModalViewController:viewController animated:YES];
        result = YES;
    }
    return result;
}

+ (BOOL)isSubView:(UIView*)view of:(UIView*)potentialOwner
{
    BOOL result = NO;
    if( potentialOwner ) {
        for (UIView* subview in [potentialOwner subviews]) {
            if( [subview isEqual:view] ) {
                result = YES;
                break;
            }
        }
    }
    return result;
}

+ (BOOL)openNativeURL:(NSURL*)url
{
    BOOL result = NO;
    if( [[UIApplication sharedApplication] canOpenURL:url] ) {
        result = YES;
        [[UIApplication sharedApplication] openURL:url];
    }    
    return result;
}

+ (void)changeInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:NO];  
}

#pragma mark conversion
+ (time_t)timeStamp
{
    return (time_t)[[NSDate date] timeIntervalSince1970];
}

+ (NSNumber*)timeStampAsNSNumber
{
    return [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
}

+ (NSNumber*)javaCalendarTimeStampAsNSNumber
{
    return [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000];
}


@end
