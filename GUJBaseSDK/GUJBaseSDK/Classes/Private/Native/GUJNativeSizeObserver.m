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
#import "GUJNativeSizeObserver.h"

@implementation GUJNativeSizeObserver

static GUJNativeSizeObserver *sharedInstance_;

#pragma mark private methods
- (void)__startEventListener
{
    if( [self runLoop] == nil ) {
        [self setRunLoop:[NSRunLoop currentRunLoop]];
    }
    @autoreleasepool {
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(__sizeChangedListenerEvent) userInfo:nil repeats:YES]];
    }
    [[self runLoop] run];
}

- (void)__stopEventListener
{
    if( [self runLoop] != nil ) {
        [[self timer] invalidate];
        CFRunLoopStop([[self runLoop] getCFRunLoop]);
        [self setRunLoop:nil];
        [self setTimer:nil];
    }
}

- (void)__sizeChangedListenerEvent
{
    @autoreleasepool {
        if( [self superview] ) {
            CGSize viewSize = [self superview].frame.size;
            if( viewSize.width != [self lastSuperviewSize].width || viewSize.height != [self lastSuperviewSize].height ) {
                [[NSNotificationCenter defaultCenter] postNotification:
                 [NSNotification notificationWithName:GUJDeviceSuperviewSizeChangedNotification object:[self superview]]
                 ];
                [self setLastSuperviewSize:[self superview].frame.size];
            }
        }
        if( [self window] ) {
            CGSize windowSize = [self window].frame.size;
            if( windowSize.width != [self lastWindowSize].width || windowSize.height != [self lastWindowSize].height ) {
                [[NSNotificationCenter defaultCenter] postNotification:
                 [NSNotification notificationWithName:GUJDeviceScreenSizeChangedNotification object:[self window]]
                 ];
                [self setLastWindowSize:[self window].frame.size];
            }
        }
        if( [self adView] ) {
            CGSize adViewSize = [self adView].frame.size;
            if( adViewSize.width != [self lastAdViewSize].width || adViewSize.height != [self lastAdViewSize].height ) {
                [[NSNotificationCenter defaultCenter] postNotification:
                 [NSNotification notificationWithName:GUJBannerSizeChangeNotification object:[self adView]]
                 ];
                [self setLastAdViewSize:[self adView].frame.size];
            }
        }
    }
}

#pragma mark public methods
+(GUJNativeSizeObserver*)sharedInstance
{
    static dispatch_once_t _onceT;
    dispatch_once(&_onceT, ^{
        if( sharedInstance_ == nil ) {
            sharedInstance_ = [[GUJNativeSizeObserver alloc] init];
        }
    });
    return sharedInstance_;
}

- (id)init
{
    if( sharedInstance_ == nil ) {
        self = [super init];
        if( self ) {
            
        }
    }
    return self;
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        [sharedInstance_ stopObserver];
        [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];
    }
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

- (BOOL)isObserver
{
    return YES;
}

- (BOOL)startObserver
{
    BOOL result = NO;
    if( ![self runLoop] ) {
        // start a thread to be safe and non blocking
        [NSThread detachNewThreadSelector:@selector(__startEventListener) toTarget:self withObject:nil];
        result = YES;
    }
    return result;
}

- (BOOL)stopObserver
{
    BOOL result = NO;
    if( [self runLoop] ) {
        [self __stopEventListener];
        result = YES;
    }
    return result;
}

#pragma mark public methods
- (void)listenForResizingAdView:(_GUJAdView*)adView
{
    if( adView ) {
        @autoreleasepool {
            [self setAdView:adView];
            [self setLastAdViewSize:adView.frame.size];
        }
        // start if not allready started
        [self startObserver];
        
        // post initial size
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:GUJBannerSizeChangeNotification object:[self adView]]
         ];
    }
}

- (void)stopListeningForResizingAdView
{
    [self setLastAdViewSize:CGSizeZero];
}

- (void)listenForResizingSuperview:(UIView*)view
{
    if( [view superview] ) {
        @autoreleasepool {
            [self setSuperview:[view superview]];
            [self setLastSuperviewSize:[view superview].frame.size];
        }
        // start if not allready started
        [self startObserver];
    }
}

- (void)stopListeningForResizingSuperview
{
    [self setLastSuperviewSize:CGSizeZero];
}

- (void)listenForScreenResizing
{
    @autoreleasepool {
        [self setWindow:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
        if( [self window] ) {
            [self setLastWindowSize:[self window].frame.size];
        }
    }
    // start if not allready started
    [self startObserver];
}

- (void)stopListeningForScreenResizing
{
    [self setLastWindowSize:CGSizeZero];
}

@end
