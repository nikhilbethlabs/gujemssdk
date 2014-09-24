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
#import "GUJBannerXMLParser.h"

@implementation GUJBannerXMLParser

- (BOOL)__parse:(NSData*)data
{
    parser_ = [[NSXMLParser alloc] initWithData:data];
    parser_.delegate = self;
    return [parser_ parse];
}

+(GUJBannerXMLParser*)parse:(GUJAdData*)adData
{
    GUJBannerXMLParser *result = [[GUJBannerXMLParser alloc] init];
    [result __parse:adData];
    return result;
}

#pragma mark public methods
- (NSError*)error
{
    return error_;
}

- (BOOL)isValid
{
    return isBannerXML_;
}

- (NSUInteger)adId
{
    return adId_;
}

- (NSUInteger)campaignId
{
    return campaignId_;
}

- (NSString*)xmlns
{
    return xmlns_;
}

- (NSURL*)imageLink
{
    NSURL *result = nil;
    if( imageLink_ ) {
        if( [[imageLink_ lowercaseString] hasPrefix:@"http://"] ) {
            result = [NSURL URLWithString:imageLink_];
        } else if( [[imageLink_ lowercaseString] hasPrefix:@"file:/"] ) {
            result = [NSURL fileURLWithPath:imageLink_];
        } else {
            // failed
        }
    }
    return result;
}

- (NSURL*)imageURL
{
    NSURL *result = nil;
    if( imageSourceAddress_ ) {
        if( [[imageSourceAddress_ lowercaseString] hasPrefix:@"http://"] ) {
            result = [NSURL URLWithString:imageSourceAddress_];
        } else if( [[imageSourceAddress_ lowercaseString] hasPrefix:@"file:/"] ) {
            result = [NSURL fileURLWithPath:imageSourceAddress_];
        } else {
            // failed
        }
    }
    return result;
}

- (NSString*)imageAlign
{
    return imageAlign_;
}

- (NSString*)imageMimeType
{
    return imageMimeType_;
}

- (BOOL)shouldScaleImage
{
    return imageScale_;
}

#pragma mark NSXMLParser delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
#pragma unused(parser)
#pragma unused(namespaceURI)
#pragma unused(qName)
    
    if( [elementName isEqualToString:kGUJBannerXMLTagForBannerXML] ) {
        isBannerXML_ = YES;
    }
    if( [elementName isEqualToString:kGUJBannerXMLTagForAd] ) {
        if( attributeDict ) {
            NSString *xmlAdId = ((NSString*)[attributeDict objectForKey:kGUJBannerXMLAttributeForAdId]);
            if( xmlAdId ) {
                adId_ = [[NSNumber numberWithLongLong:[xmlAdId longLongValue]] unsignedIntValue];
            }
            NSString *xmlCpgId = ((NSString*)[attributeDict objectForKey:kGUJBannerXMLAttributeForCampaignId]);
            if( xmlCpgId ) {
                campaignId_ = [[NSNumber numberWithLongLong:[xmlCpgId longLongValue]] unsignedIntValue];
            }
        }
    }
    
    if( [elementName isEqualToString:kGUJBannerXMLTagForImageLink] ) {
        if( attributeDict ) {
            imageLink_ = ((NSString*)[attributeDict objectForKey:kGUJBannerXMLAttributeForHref]);
        }
    }
    
    if( [elementName isEqualToString:kGUJBannerXMLTagForImage] ) {
        if( attributeDict ) {
            imageAlign_ = ((NSString*)[attributeDict objectForKey:kGUJBannerXMLAttributeForAlign]);
            imageMimeType_ =  ((NSString*)[attributeDict objectForKey:kGUJBannerXMLAttributeForMimeType]);
            NSString *xmlScale = ((NSString*)[attributeDict objectForKey:kGUJBannerXMLAttributeForScale]);
            imageScale_ = [[xmlScale lowercaseString] isEqualToString:@"true"];
            imageSourceAddress_ =((NSString*)[attributeDict objectForKey:kGUJBannerXMLAttributeForSrc]);
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
#pragma unused(parser)
    error_ = [GUJUtil errorForDomain:kGUJBannerXMLParserErrorDomain andCode:parseError.code withUserInfo:[parseError userInfo]];
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
#pragma unused(parser)
    error_ = [GUJUtil errorForDomain:kGUJBannerXMLParserErrorDomain andCode:validationError.code withUserInfo:[validationError userInfo]];
}

@end
