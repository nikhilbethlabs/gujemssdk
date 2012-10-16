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
    if( acceleration_ != nil ) {
        float x,y,z = 0.0;
        x = (acceleration_.x * kGUJNativeAccelerometerIntensityFilter) 
        + (acceleration_.x * (1.0 - kGUJNativeAccelerometerIntensityFilter));
        
        y = (acceleration_.y * kGUJNativeAccelerometerIntensityFilter) 
        + (acceleration_.y * (1.0 - kGUJNativeAccelerometerIntensityFilter));
        
        y = (acceleration_.z * kGUJNativeAccelerometerIntensityFilter) 
        + (acceleration_.z * (1.0 - kGUJNativeAccelerometerIntensityFilter));
        
        x = acceleration_.x - x;
        y = acceleration_.y - y;
        z = acceleration_.z - z;        
        result = sqrt(x * x + y * y + z * z);
    }
    return result;    
}

- (void)__startShakeObserver
{
    [UIAccelerometer sharedAccelerometer].delegate = sharedInstance_;
    // register for shake notifications
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceShakeNotification object:nil]; 
}

- (void)__stopShakeObserver
{
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    // unregister shake notifications
    [[NSNotificationCenter defaultCenter] removeObserver:[GUJNotificationObserver sharedInstance] name:GUJDeviceShakeNotification object:nil];
}

- (void)__enableAccelerometer
{
    accelerometerEnabled_ = YES;
}

- (BOOL)__testForAccelerometerEvent:(UIAcceleration*)acceleration threshold:(double)threshold free:(BOOL)free
{
    BOOL result = NO;
    double deltaX = fabs(_lastAcceleration.x - acceleration.x);
    double deltaY = fabs(_lastAcceleration.y - acceleration.y);
    double deltaZ = fabs(_lastAcceleration.z - acceleration.z);
    
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
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeShakeObserver alloc] init];
    }          
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
    sharedInstance_ = nil;
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJDeviceShakeNotification selector:selector];
}

- (void)unregisterForNotfication:(id)receiver
{
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJDeviceShakeNotification];
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
- (UIAcceleration*)acceleration
{
    return acceleration_;
}

- (UIAccelerationValue)intensity
{
    return accelerationIntensity_;
}

- (NSTimeInterval)interval
{
    return accelerationInterval_;
}

#pragma mark accelerometer delegate
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{    
#pragma unused(accelerometer)
    if (self.lastAcceleration && accelerometerEnabled_ ) {
        if (!hysteresisExcited_ && [self __testForShakingEvent:acceleration] ) {
            hysteresisExcited_      = YES;
            isShaking_              = YES;
            _lastAcceleration       = acceleration;
            accelerationInterval_   = acceleration.timestamp;
            accelerationIntensity_  = 0.0;
        } else if ( hysteresisExcited_ && isShaking_ && [self __testForHysteresisExcited:acceleration] ) {
            hysteresisExcited_      = NO;
            isShaking_              = NO;
            accelerometerEnabled_   = NO;            
            @autoreleasepool {
                acceleration_         = acceleration;   
                accelerationInterval_ = (acceleration.timestamp - accelerationInterval_);
            }
            if( [self __calculateIntensity] > accelerationIntensity_ ) {
                accelerationIntensity_ = [self __calculateIntensity];
            }            
            _lastAcceleration       = nil;
            
            // send shake notificaion
            [[NSNotificationCenter defaultCenter] postNotification:
             [NSNotification notificationWithName:GUJDeviceShakeNotification object:[GUJNativeShakeObserver sharedInstance]]
             ];              
            // wait
            [self performSelector:@selector(__enableAccelerometer) withObject:nil afterDelay:1.5];
        } else {
            if( isShaking_ ) {
                acceleration_ = acceleration;
                if( [self __calculateIntensity] > accelerationIntensity_ ) {
                    accelerationIntensity_ = [self __calculateIntensity];
                }                
            }
        }
    } else if (!self.lastAcceleration && !accelerometerEnabled_ ) {
        [self performSelector:@selector(__enableAccelerometer) withObject:nil afterDelay:0.1];
    }
    
    self.lastAcceleration = acceleration;
}

@end

