//
//  MASTMessages.h
//  AdMobileSDK
//
//  Created by artem samalov on 2/13/12.
//  Copyright (c) 2012 AdMobile Mobile. A subsidiary of Mojiva, Inc. All rights reserved.
//

#define kErrorNoAdsMessage                  @"There are no ads for this time. Try again later..."
#define kErrorFailDisplayMessage            @"fail to display"
#define kErrorInvalidParamsMessage          @"invalid site or zone parameters"

#pragma mark MASTAdModel messages

#define kErrorInvalidSiteMessage            @"Invalid site property. value"
#define kErrorInvalidZoneMessage            @"Invalid zone property. value"
#define kErrorInvalidPremiumMessage         @"Invalid premium property. value"
#define kErrorInvalidMinSizeMessage         @"Invalid minSize property. value"
#define kErrorInvalidMaxSizeMessage         @"Invalid maxSize property. value"
#define kErrorInvalidAdvertiserIdMessage    @"Invalid advertiserId property. value"
#define kErrorInvalidTypeMessage            @"Invalid type property. value"

#pragma mark Connection messages

#define kErrorNoContentMessage              @"All up to Date"
#define kErrorServerResponseMessage         @"Server responds with code"

#pragma mark ORMMA messages

#define kErrorExpandInvalidStateMessage     @"Can only expand from the default state."
#define kErrorExpandLargerSizeMessage       @"Cannot expand an ad larger than allowed."

#define kErrorResizeInvalidStateMessage     @"Cannot resize an ad that is not in the default state."
#define kErrorResizeLargerSizeMessage       @"Cannot resize an ad larger than allowed."

#define kErrorDeviceCannotSendEmailMessage  @"Cannot send email: device mailbox is not configured."
#define kErrorEmailFieldsNotRequiredMessage @"Cannot send email: body, subject and to fields are required."

#define kAlertEventStatutsTitle             @"Event Status"
#define kAlertEventAddedMessage             @"Event was added successfully."
#define kAlertEventNotAddedMessage          @"Event is not added."
#define kAlertEventSaveMessage              @"Do you wish to save calendar event?"

#pragma mark Logger Messages

#define kLoggerWarningMessage               @"NOTE: this message displays only in the simulator"

#pragma mark Internal Browser message

#define kLoadingTitle                       @"Loading..."
#define kOpenLinkInSafariTitle              @"Open in Safari"