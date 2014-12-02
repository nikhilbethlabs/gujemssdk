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
#import "GUJXAXISSDKVersion.h"

#ifndef GUJXAXISSDK_GUJXAXISConstants_h
#define GUJXAXISSDK_GUJXAXISConstants_h


/*!
 * Uncomment if you want to prefetch the video ad content.
 */
//#define kXAXSIS_SHOULD_PREFETCH_CONTENT

#
#pragma mark XAXIS Video Ad SDK
#
#define kXAXISVideoAdSDKClass                               @"VideoAdSDK"

#define kXAXISSmartStreamTagOpen                            @"<smartstream>"
#define kXAXISSmartStreamTagClose                           @"</smartstream>"

#
#pragma mark error domains
#
#define kORMMAXAXISVideoAdErrorDomain                       @"ORMMAXAXISVideoAdErrorDomain"

#
#pragma mark XAXIS error codes
#
#define kXAXIS_ERROR_CODE_AD_UNAVAILABLE                    73100
#define kXAXIS_ERROR_CODE_AD_FAILED_LOADING                 73200
#define kXAXIS_ERROR_CODE_DEVICE_NOT_SUPPORTED              73900
 
#
#pragma mark XAXIS events
#
#define kXAXIS_EVENT_IDENTIFIER                             @"XAXIS_EVENT(%@)"
#define kXAXIS_EVENT_PREFETCHING_DID_COMPLETE               @"advertisingPrefetchingDidComplete"
#define kXAXIS_EVENT_FIRST_QUARTILE                         @"firstQuartile"
#define kXAXIS_EVENT_MIDPOINT                               @"midpoint"
#define kXAXIS_EVENT_THIRD_QUARTILE                         @"thirdQuartile"
#define kXAXIS_EVENT_COMPLETE                               @"complete"
#define kXAXIS_EVENT_IMPRESSION                             @"impression"
#define kXAXIS_EVENT_CLICKED                                @"clicked"
#define kXAXIS_EVENT_START                                  @"start"
#define kXAXIS_EVENT_PAUSE                                  @"pause"
#define kXAXIS_EVENT_PREFETCH                               @"prefetch"

// we need this delay caus it seems that the XAXIS SDK blocks a/the server connection
#define kXAXIS_REPORTING_DELAY                              0.175
#define kXAXIS_INSTANCE_DEALLOCATE_DELAY                    0.5

#
#pragma mark XAXIS amobee tracking ad space ids
#
#define kXAXIS_REPORTING_PLACEMENT_ID_IP_STARTED            @"15569"
#define kXAXIS_REPORTING_PLACEMENT_ID_IP_FAILED             @"15571"
#define kXAXIS_REPORTING_PLACEMENT_ID_IP_FIRST_QUARTILE     @"15573"
#define kXAXIS_REPORTING_PLACEMENT_ID_IP_MIDPOINT           @"15575"
#define kXAXIS_REPORTING_PLACEMENT_ID_IP_THIRD_QUARTILE     @"15577"
#define kXAXIS_REPORTING_PLACEMENT_ID_IP_FINISHED           @"15579"
#define kXAXIS_REPORTING_PLACEMENT_ID_IP_IMPRESSION         @"15581"

#
#pragma mark XAXIS amobee tracking parameters
#
#define kGUJURLParameterSmartStreamReportTimeStamp          @"repdt"
#define kGUJURLParameterSmartStreamPlacementId              @"plmid"
#define kGUJURLParameterFormateForReportingTimeStamp        @"YYYYMMdd"

#endif
