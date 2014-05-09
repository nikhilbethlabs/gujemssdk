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
#import "ORMMAViewableObserver.h"

@implementation ORMMAViewableObserver

static ORMMAViewableObserver *sharedInstance_;

#pragma mark public methods
+(ORMMAViewableObserver*)sharedInstance
{
    static dispatch_once_t _onceT;
    dispatch_once(&_onceT, ^{
        if( sharedInstance_ == nil ) {
            sharedInstance_ = [[ORMMAViewableObserver alloc] init];
        }
    });
    return sharedInstance_;
}

- (id)init
{
    if( sharedInstance_ == nil ) {
        self = [super init];
        if( self ) {
            viewable_ = NO;
        }
    }
    return self;
}

- (void)setViewable:(BOOL)viewable
{
    viewable_ = viewable;
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJBannerViewableChangedNotification object:[ORMMAViewableObserver sharedInstance]]
     ];
}

- (BOOL)isViewable
{
    return viewable_;
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
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJBannerStateChangedNotification object:nil
      ]];
    return YES;
}


- (BOOL)startObserverWithNotificationReceiver:(id)receiver selector:(SEL)notificationSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:receiver selector:notificationSelector name:GUJBannerViewableChangedNotification object:nil];
    return [self startObserver];
}

- (BOOL)stopObserver
{
    return YES;
}

- (BOOL)stopObserverWithNotificationReceiver:(id)receiver
{
    [[NSNotificationCenter defaultCenter] removeObserver:receiver name:GUJBannerViewableChangedNotification object:nil];
    return YES;
}

@end
