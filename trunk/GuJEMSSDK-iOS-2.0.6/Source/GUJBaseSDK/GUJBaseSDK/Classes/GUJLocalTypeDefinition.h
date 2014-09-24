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
#ifndef GEAdBaseSDK_GUJLocalTypeDefinition_h
#define GEAdBaseSDK_GUJLocalTypeDefinition_h

typedef BOOL (^gujAdViewCompletionHandler)(NSObject* _loadedAdView, NSError* _loadingError);

#pragma mark URL Builder
enum {
    GUJURLParameterType                 = 0,
    GUJURLParameterPartner              = 1,
    GUJURLParameterAdSpace              = 2,
    GUJURLParameterMarkup               = 3,
    GUJURLParameterTimeStamp            = 4,
    GUJURLParameterIPAddress            = 5,
    GUJURLParameterKeyword              = 6,
    GUJURLParameterLatitude             = 7,
    GUJURLParameterLongitude            = 8,
    GUJURLParameterUserId               = 9,
}; typedef NSUInteger GUJURLParameter; // maybe rename to GUJAdServerURLParameter in 1.2.2


#pragma mark device capabilities
enum {
    GUJDeviceCapabilityUnkown           = -1,
    GUJDeviceCapabilityNetwork          = 0,
    GUJDeviceCapabilityPhone            = 1,
    GUJDeviceCapabilitySMS              = 2,
    GUJDeviceCapabilityEmail            = 3,
    GUJDeviceCapabilityTilt             = 4,
    GUJDeviceCapabilityScreenSize       = 5,
    GUJDeviceCapabilityShake            = 6,
    GUJDeviceCapabilityOrientation      = 7,
    GUJDeviceCapabilityHeading          = 8,
    GUJDeviceCapabilityLocation         = 9,
    GUJDeviceCapabilityMapKit           = 10,
    GUJDeviceCapabilityCalendar         = 11,
    GUJDeviceCapabilityCamera           = 12,
    GUJDeviceCapabilityNativeAudio      = 13,
    GUJDeviceCapabilityNativeVideo      = 14,
    GUJDeviceCapabilityLevel1           = 15,
    GUJDeviceCapabilityLevel2           = 16,
    GUJDeviceCapabilityLevel3           = 17,
    GUJDeviceCapabilityKeyboard         = 18
    
}; typedef NSUInteger GUJDeviceCapability;

#pragma mark AdBanner
enum {
    GUJBannerTypeUndefined              = 0,
    GUJBannerTypeMobile                 = 4, // 6:1, 4:1, 2:1
    GUJBannerTypeRichMedia              = 3, // SoWeFo
    GUJBannerTypeInterstitial           = 5, // Interstitial
    GUJBannerTypeDefault                = 3, // GUJBannerTypeRichMedia
}; typedef NSUInteger GUJBannerType;

// optional implementaion of banner formats.
enum {
    GUJBannerFormatSmall                = 0, // 6:1
    GUJBannerFormatMedium               = 1, // 4:1
    GUJBannerFormatBig                  = 2, // 2:1
    GUJBannerFormatRichMedia            = 3, // SoWeFo
    GUJBannerFormatInterstitial         = 4  // Interstitial
}; typedef NSUInteger GUJBannerFormat;

enum {
    GUJBannerMarkupUndefined            = 0,
    GUJBannerMarkupXML                  = 1, // kGUJBannerMarkupBannerXML
    GUJBannerMarkupXHTML                = 2  // kGUJBannerMarkupBannerXHTML
}; typedef NSUInteger GUJBannerMarkup;

enum {
    GUJMoviePlayerStatePrepared,
    GUJMoviePlayerStateMovieLoaded,
    GUJMoviePlayerStateMovieFailedLoading,
    GUJMoviePlayerStateMoviePreloaded,
    GUJMoviePlayerStateEmbeddedPlayerStarted,
    GUJMoviePlayerStateFullscreenPlayerStarted,
    GUJMoviePlayerStatePlaybackDidFinish,
    GUJMoviePlayerStateStopped,
    GUJMoviePlayerStatePlaying,
    GUJMoviePlayerStatePaused,
    GUJMoviePlayerStateInterrupted,
    GUJMoviePlayerStateSeekingForward,
    GUJMoviePlayerStateSeekingBackward
};
typedef NSInteger GUJMoviePlayerState;


enum {
    GUJAudioPlayerStatePrepared,
    GUJAudioPlayerStateLoaded,
    GUJAudioPlayerStateFailedLoading,
    GUJAudioPlayerStateDecodingError,
    GUJAudioPlayerStatePlaybackStarted,
    GUJAudioPlayerStatePlaybackDidFinish,
    GUJAudioPlayerStatePlaybackStopped,
    GUJAudioPlayerStatePlaybackPlaying,
    GUJAudioPlayerStatePlaybackPaused,
    GUJAudioPlayerStateBeginInterruption,
    GUJAudioPlayerStateEndInterruption
};
typedef NSInteger GUJAudioPlayerState;

#pragma mark inline functions

/*!
 * ORMMA Support
 LEVEL1      :'level-1',
 LEVEL2      :'level-2',
 LEVEL3      :'level-3',
 SCREEN      :'screen',
 ORIENTATION :'orientation'
 HEADING     :'heading'
 LOCATION    :'location'
 SHAKE       :'shake'
 TILT        :'tilt'
 NETWORK     :'network'
 SMS         :'sms'
 PHONE       :'phone'
 EMAIL       :'email'
 CALENDAR    :'calendar'
 CAMERA      :'camera'
 AUDIO       :'audio'
 VIDEO       :'video'
 MAP         :'map'1
 *
 */
static inline NSString* GUJ_FORMAT_DEVICE_CAPABILITY_TO_NSSTRING(GUJDeviceCapability deviceCapability)
{
    @autoreleasepool {
        NSString *result = nil;
        switch(deviceCapability) {
            case GUJDeviceCapabilityLevel1:
                result = @"level-1";
                break;
            case GUJDeviceCapabilityLevel2:
                result = @"level-2";
                break;
            case GUJDeviceCapabilityLevel3:
                result = @"level-3";
                break;
            case GUJDeviceCapabilityNetwork:
                result = @"network";
                break;
            case GUJDeviceCapabilityPhone:
                result = @"phone";
                break;
            case GUJDeviceCapabilitySMS:
                result = @"sms";
                break;
            case GUJDeviceCapabilityEmail:
                result = @"email";
                break;
            case GUJDeviceCapabilityScreenSize:
                result = @"screen";
                break;
            case GUJDeviceCapabilityShake:
                result = @"shake";
                break;
            case GUJDeviceCapabilityTilt:
                result = @"tilt";
                break;
            case GUJDeviceCapabilityOrientation:
                result = @"orientation";
                break;
            case GUJDeviceCapabilityHeading:
                result = @"heading";
                break;
            case GUJDeviceCapabilityLocation:
                result = @"location";
                break;
            case GUJDeviceCapabilityMapKit:
                result = @"map";
                break;
            case GUJDeviceCapabilityCalendar:
                result = @"calendar";
                break;
            case GUJDeviceCapabilityCamera:
                result = @"camera";
                break;
            case GUJDeviceCapabilityNativeAudio:
                result = @"audio";
                break;
            case GUJDeviceCapabilityNativeVideo:
                result = @"video";
                break;
            case GUJDeviceCapabilityKeyboard:
                result = @"keyboard";
                break;
            default:
                result = nil;
                break;
        }
        return result;
    }
}

static inline int GUJ_FORMAT_ORIENTATION_IN_DEGREES(UIDeviceOrientation deviceOrientation)
{
    @autoreleasepool {
        NSUInteger result = UIDeviceOrientationPortrait;
        switch(deviceOrientation) {
            case UIDeviceOrientationPortrait:
                result = 0;
                break;
            case UIDeviceOrientationLandscapeRight:
                result = 90;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                result = 180;
                break;
            case UIDeviceOrientationLandscapeLeft:
                result = 270;
                break;
            default:
                result = UIDeviceOrientationPortrait;
                break;
        }
        return (int)result;
    }
}
/*!
 log a message if kGUJEMS_Debug is defined
 */
static inline void _logd_m(__attribute__((unused))NSString *message)
{
#ifdef kGUJEMS_Debug
    NSLog(@"%@",message);
#endif
}

/*!
 log a message and the type-class if kGUJEMS_Debug is defined
 */
static inline void _logd_t(__attribute__((unused))id type, __attribute__((unused))NSString *message)
{
#ifdef kGUJEMS_Debug
    @autoreleasepool {
        NSLog(@"%@",[NSString stringWithFormat:@"[%@] %@",[[type class] description],message]);
    }
    
#endif
}

/*!
 log a message and the type-class if kGUJEMS_Debug is defined
 */
static inline void _logd_tm(__attribute__((unused))id type, __attribute__((unused))NSString *message, ... )
{
#ifdef kGUJEMS_Debug
    @autoreleasepool {
        va_list args;
        va_start(args, message);
        NSString *logMessage = [NSString stringWithFormat:@"[%@]",[[type class] description]];
        for (NSString *arg = message; arg != nil; arg = va_arg(args, NSString*))
        {
            logMessage = [NSString stringWithFormat:@"%@ %@",logMessage,arg];
        }
        va_end(args);
        NSLog(@"%@",logMessage);
    }
#endif
}

static inline void _logd_frame(__attribute__((unused))id type, __attribute__((unused))CGRect frame )
{
#ifdef kGUJEMS_Debug
    @autoreleasepool {
        NSString *logMessage = [NSString stringWithFormat:@"[%@]",[[type class] description]];
        logMessage = [NSString stringWithFormat:@"%@ x: %f y: %f w: %f h: %f",logMessage,frame.origin.x,frame.origin.y, frame.size.width,frame.size.height];
        NSLog(@"%@",logMessage);
    }
#endif
}
/*!
 log the message and type-class in any case
 */
static inline void _log_t(id type, NSString *message)
{
    @autoreleasepool {
        NSLog(@"%@",[NSString stringWithFormat:@"[%@] %@",[[type class] description],message]);
    }
    
}

static inline void _log_m(NSString *message)
{
    @autoreleasepool {
        NSLog(@"%@",message);
    }
}
@end

#define kAppSal @"VGhlIG9ubHkgd2F5IHRvIGdvZCBpcyBKZXN1cyEgVGhhbmsgeW91ISBZb3UgbWFrZSBzbyBtdWNoIHBvc3NpYmxlIQ=="

#endif
