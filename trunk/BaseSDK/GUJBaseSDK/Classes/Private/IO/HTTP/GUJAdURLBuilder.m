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
#import "GUJAdURLBuilder.h"

// array of parameter keys
NSString *const kGUJURLParameterKeys[]  = { 
    kGUJURLParameterTyp, 
    kGUJURLParameterPartner,
    kGUJURLParameterAdSpace,
    kGUJURLParameterMarkup,
    kGUJURLParameterTimestamp,
    kGUJURLParameterIPAddress,
    kGUJURLParameterKeyword,
    kGUJURLParameterLatitude,
    kGUJURLParameterLongitude,
    kGUJURLParameterUserId
};

@implementation GUJAdURLBuilder

@synthesize bannerType      = _bannerType;
@synthesize bannerFormat    = _bannerFormat;
@synthesize bannerMarkup    = _bannerMarkup;
@synthesize urlParameter    = _urlParameter;

- (id)init
{
    self = [super init];    
    return self;
}

- (GUJBannerType)__bannerMarkupForType:(GUJBannerType)type
{
    if( type == GUJBannerTypeMobile ) {
        return GUJBannerMarkupXML;
    } else if( type == GUJBannerTypeRichMedia || type == GUJBannerTypeInterstitial ) {
        return GUJBannerMarkupXHTML;
    } else {
        return GUJBannerTypeUndefined;
    }
}

- (NSString*)__bannerMarkupAsString
{ 
#ifdef __GUJ_SDK_FORCE_XHTML_OUTPUT__
    return kGUJBannerMarkupXHTML;
#else    
    NSString *result = nil;
    if( _bannerMarkup ) {
        if( _bannerMarkup == GUJBannerMarkupXML ) {
            result = kGUJBannerMarkupXML;
        } else if( _bannerMarkup == GUJBannerMarkupXHTML ) {
            result = kGUJBannerMarkupXHTML;
        } else {
            // other types
        }
    } else {
        _bannerMarkup = [self __bannerMarkupForType:_bannerType];
        if( _bannerMarkup != GUJBannerMarkupUndefined ) {
            return [self __bannerMarkupAsString];        
        }
    }
    return result;
#endif
}

- (NSNumber*)__bannerTypeAsNumber
{
#ifdef __GUJ_SDK_FORCE_MOBILE_BANNER_FORMAT__    
    return [NSNumber numberWithInt:GUJBannerTypeMobile];
#else    
    /* correct implementation: __bannerTypeAsNumber */
    NSNumber *result = nil;
    if( _bannerType ) {
        result = [NSNumber numberWithInt:_bannerType];
    }
    return result;
#endif
}

- (void)__adParameter:(NSString*)key withValue:(id)value toURLString:(NSMutableString*)urlString
{
    _logd_tm(self, @"__adParameter:",key,@"=",value,nil);
    if( [urlString rangeOfString:@"?"].location == NSNotFound ) {
        [urlString appendFormat:kGUJURLParameterFormatStart,key,value];
    } else {
        [urlString appendFormat:kGUJURLParameterFormat,key,value];
    }
}

- (NSString*)buildURLString
{       
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@%@",[[GUJAdConfiguration sharedInstance] adServerURL],kGUIJURLPathForBanner];
    
    if( !_urlParameter || [self.urlParameter count] == 0 ) { // if no parameters are predefined
        _urlParameter = [[NSMutableDictionary alloc] initWithCapacity:kGUJSizeOfUrlParameterKeys];
        
        [self setValue:[self __bannerTypeAsNumber]                      forURLParameter:GUJURLParameterType];      
        [self setValue:[self __bannerMarkupAsString]                    forURLParameter:GUJURLParameterMarkup];            
        [self setValue:kGUJURLParameterPartnerDefault                   forURLParameter:GUJURLParameterPartner];     
        [self setValue:[GUJUtil javaCalendarTimeStampAsNSNumber]        forURLParameter:GUJURLParameterTimeStamp]; 
        [self setValue:[[GUJAdConfiguration sharedInstance] adSpaceId]  forURLParameter:GUJURLParameterAdSpace];
        [self setValue:[GUJUtil md5HashedApplicationAdSpaceUUID]        forURLParameter:GUJURLParameterUserId];  
        
#ifdef __GUJ_SDK_ADD_IP_ADDRESS_TO_REQUEST_HEADER__
        [self setValue:[GUJUtil internetAddressStringRepresentation]    forURLParameter:GUJURLParameterIPAddress];  
#endif
        
        if( // optional: if location manager is active and has location lat & long
           [[GUJNativeLocationManager sharedInstance] locationLatitudeStringRepresentation] != nil &&
           [[GUJNativeLocationManager sharedInstance] locationLongitudeStringRepresentation] != nil 
           ) {
            NSString *latitude  = [[GUJNativeLocationManager sharedInstance] locationLatitudeStringRepresentation];
            NSString *longitude = [[GUJNativeLocationManager sharedInstance] locationLongitudeStringRepresentation];
            if( [latitude hasPrefix:@"+"] ) {
                latitude = [latitude stringByReplacingOccurrencesOfString:@"+" withString:kEmptyString];
            }
            if( [longitude hasPrefix:@"+"] ) {
                longitude = [longitude stringByReplacingOccurrencesOfString:@"+" withString:kEmptyString];
            }            
            [self setValue:latitude  forURLParameter:GUJURLParameterLatitude];
            [self setValue:longitude forURLParameter:GUJURLParameterLongitude];            
        } // if
        
        if( // optinal: if keyowrds defined GUJUtil will return a well formatted keyword string 
           ![[[GUJAdConfiguration sharedInstance] keywordsFormatted] isEqualToString:kEmptyString] 
           ) {
            @autoreleasepool {                
                [self setValue:[[GUJAdConfiguration sharedInstance] keywordsFormattedWithURLEncoding]
               forURLParameter:GUJURLParameterKeyword]; 
            }
        }
        
    } else {
        // discuss: check if all required parameters are present or leave it on developer side?
        // in the current architecture the developer isn't able to pass parameters. so this case will never happen.
        // there is no excpetion: _urlParameter is allways nil - @sven
    }
    for (NSString *key in [_urlParameter allKeys] ) {
        [self __adParameter:key withValue:[_urlParameter objectForKey:key] toURLString:result]; 
    }
    return result;
}

- (NSURL*)buildURL
{
    return [NSURL URLWithString:[self buildURLString]];
}

- (void)setValue:(id)value forURLParameter:(GUJURLParameter)parameter
{
    @autoreleasepool {
        [_urlParameter setValue:[value copy] forKey:kGUJURLParameterKeys[parameter]];        
    }
}

- (id)valueForURLParameter:(GUJURLParameter)parameter
{
    return [_urlParameter objectForKey:kGUJURLParameterKeys[parameter]];
}


@end