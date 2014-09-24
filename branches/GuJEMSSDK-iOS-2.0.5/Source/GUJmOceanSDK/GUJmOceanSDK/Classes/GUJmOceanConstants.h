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
#import "GUJmOceanSDKVersion.h"

#ifndef GUJmOceanSDK_GUJmOceanConstants_h
#define GUJmOceanSDK_GUJmOceanConstants_h

#define kGUJ_MOCEAN_LOG_MODE_ALL                        2 // AdLogModeAll
#define kGUJ_MOCEAN_LOG_MODE_NONE                       0 // AdLogModeNone
#ifdef kGUJEMS_Debug    
#define kGUJ_MOCEAN_LOG_MODE                            kGUJ_MOCEAN_LOG_MODE_NONE
#else
#define kGUJ_MOCEAN_LOG_MODE                            kGUJ_MOCEAN_LOG_MODE_ALL
#endif  


#define kGUJ_MOCEAN_MAST_AD_VIEW_CLASS                  @"MASTAdView"

#define kGUJ_MOCEAN_CONFIGURATION_KEY_SITE_ID           @"GUJ_MOCEAN_SITE_ID"
#define kGUJ_MOCEAN_CONFIGURATION_KEY_ZONE_ID           @"GUJ_MOCEAN_ZONE_ID"


#define kGUJ_MOCEAN_AD_VIEW_EVENT_START_FULL_SCREEN     @"adWillStartFullScreen"
#define kGUJ_MOCEAN_AD_VIEW_EVENT_END_FULL_SCREEN       @"adDidEndFullScreen"
#define kGUJ_MOCEAN_AD_VIEW_EVENT_SHOULD_OPEN_URL       @"adShouldOpen: %@"
#define kGUJ_MOCEAN_AD_VIEW_EVENT_ORMMA_PROCESS_EVENT   @"ormmaProcess:event:parameters: %@"
#
#pragma mark error domains
#
#define kGUJmOceanErrorDomain                           @"kGUJmOceanErrorDomain"

#
#pragma mark ormma error codes
#
#define GUJ_MOCEAN_MAST_ERROR_CODE_UNABLE_TO_ATTACH     60001
#define GUJ_MOCEAN_MAST_ERROR_CODE_SETUP_FAILD          60002
#define GUJ_MOCEAN_MAST_ERROR_CODE_INVALID_UI_OBJECT    60003
#define GUJ_MOCEAN_MAST_ERROR_CODE_LIBRARY_NOT_LINKED   69999

#endif
