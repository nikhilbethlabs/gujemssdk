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
#import "GUJNativeShakeObserver.h"

@implementation GUJNativeShakeObserver

@synthesize lastAcceleration = _lastAcceleration;

static GUJNativeShakeObserver *sharedInstance_;

- (UIAccelerationValue)__calculateIntensity
{
    UIAccelerationValue result = 0.0;
    if( [self acceleration] != nil ) {
        float x,y,z = 0.0;
        x = ([self acceleration].x * kGUJNativeAccelerometerIntensityFilter)
        + ([self acceleration].x * (1.0 - kGUJNativeAccelerometerIntensityFilter));
        
        y = ([self acceleration].z * kGUJNativeAccelerometerIntensityFilter)
        + ([self acceleration].z * (1.0 - kGUJNativeAccelerometerIntensityFilter));
        
        x = [self acceleration].x - x;
        y = [self acceleration].y - y;
        z = [self acceleration].z - z;
        result = sqrt(x * x + y * y + z * z);
    }
    return result;
}

- (void)__startShakeObserver
{
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)__stopShakeObserver
{
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

- (void)__enableAccelerometer
{
    [self setAccelerometerEnabled:YES];
}

- (BOOL)__testForAccelerometerEvent:(UIAcceleration*)acceleration threshold:(double)threshold free:(BOOL)free
{
    BOOL result = NO;
    double deltaX = fabs([self lastAcceleration].x - acceleration.x);
    double deltaY = fabs([self lastAcceleration].y - acceleration.y);
    double deltaZ = fabs([self lastAcceleration].z - acceleration.z);
    
    if( free ) {
        result =  (deltaX < threshold && deltaY < threshold)&&
        (deltaX < threshold && deltaZ < threshold) &&
        (deltaY < threshold && deltaZ < threshold);
    } else {
        result =  (deltaX > threshold && deltaY > threshold) ||
        (deltaX > threshold && deltaZ > threshold) ||
        (deltaY > threshold && deltaZ > threshold);
    }
    return result;
}

- (BOOL)__testForShakingEvent:(UIAcceleration*)acceleration
{
    return [self __testForAccelerometerEvent:acceleration threshold:kGUJNativeAccelerometerManagerShakeThreshold free:NO];
}

- (BOOL)__testForHysteresisExcited:(UIAcceleration*)acceleration
{
    return [self __testForAccelerometerEvent:acceleration threshold:kGUJNativeAccelerometerManagerFreeThreshold free:YES];
}

+ (GUJNativeShakeObserver*)sharedInstance
{
    static dispatch_once_t _onceT;
    dispatch_once(&_onceT, ^{
        if( sharedInstance_ == nil ) {
            sharedInstance_ = [[GUJNativeShakeObserver alloc] init];
        }
    });
    return sharedInstance_;
}

- (id)init
{
    if( sharedInstance_ == nil ) {
        self = [super init];
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityShake];
        }
    }
    return self;
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    [UIAccelerometer sharedAccelerometer].delegate = nil;
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
    [self __startShakeObserver];
    return YES;
}

- (BOOL)stopObserver
{
    [self __stopShakeObserver];
    return YES;
}

#pragma mark public methods
- (UIAccelerationValue)intensity
{
    return [self accelerationIntensity];
}

- (NSTimeInterval)interval
{
    return [self accelerationInterval];
}

#pragma mark accelerometer delegate
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
#pragma unused(accelerometer)
    if ([self lastAcceleration] && [self accelerometerEnabled] ) {
        if (![self hysteresisExcited] && [self __testForShakingEvent:acceleration] ) {
            [self setHysteresisExcited:YES];
            [self setIsShaking:YES];
            [self setLastAcceleration:acceleration];
            [self setAccelerationInterval:acceleration.timestamp];
            [self setAccelerationIntensity:0.0];
        } else if ( [self hysteresisExcited] && [self isShaking] && [self __testForHysteresisExcited:acceleration] ) {
            [self setHysteresisExcited:NO];
            [self setIsShaking:NO];
            [self setAccelerometerEnabled:NO];
            @autoreleasepool {
                [self setAcceleration:acceleration];
                [self setAccelerationInterval:(acceleration.timestamp - [self accelerationInterval])];
            }
            if( [self __calculateIntensity] > [self accelerationIntensity] ) {
                [self setAccelerationIntensity:[self __calculateIntensity]];
            }
            [self setLastAcceleration:nil];
            // send shake notificaion
            [[NSNotificationCenter defaultCenter] postNotification:
             [NSNotification notificationWithName:GUJDeviceShakeNotification object:self]
             ];
            // wait
            [self performSelector:@selector(__enableAccelerometer) withObject:nil afterDelay:1.5];
        } else {
            if( [self isShaking] ) {
                [self setAcceleration:acceleration];
                if( [self __calculateIntensity] > [self accelerationIntensity]  ) {
                    [self setAccelerationIntensity:[self __calculateIntensity]];
                }
            }
        }
    } else if (!self.lastAcceleration && ![self accelerometerEnabled] ) {
        [self performSelector:@selector(__enableAccelerometer) withObject:nil afterDelay:0.1];
    }
    [self setLastAcceleration:acceleration];
}

@end

