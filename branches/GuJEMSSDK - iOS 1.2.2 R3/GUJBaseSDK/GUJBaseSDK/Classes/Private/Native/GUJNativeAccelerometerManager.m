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
#import "GUJNativeAccelerometerManager.h"

@implementation GUJNativeAccelerometerManager

@synthesize lastAcceleration = _lastAcceleration;

static GUJNativeAccelerometerManager *sharedInstance_;

- (void)__initializeAccelerometer
{
    [UIAccelerometer sharedAccelerometer].delegate = sharedInstance_;
    
    // register for tilt notifications
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceTiltNotification object:nil]; 
    
    // register for shake notifications
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceShakeNotification object:nil]; 
}

- (void)__enableAccelerometer
{
    accelerometerEnabled_ = YES;
}

- (BOOL)__testForAccelerometerEvent:(UIAcceleration*)acceleration threshold:(double)threshold
{
    double deltaX = fabs(_lastAcceleration.x - acceleration.x);
    double deltaY = fabs(_lastAcceleration.y - acceleration.y);
    double deltaZ = fabs(_lastAcceleration.z - acceleration.z);
        return 
        (deltaX > threshold && deltaY > threshold) ||
        (deltaX > threshold && deltaZ > threshold) || 
        (deltaY > threshold && deltaZ > threshold);   
}

- (BOOL)__testForShakingEvent:(UIAcceleration*)acceleration 
{
    return [self __testForAccelerometerEvent:acceleration threshold:kGUJNativeAccelerometerManagerShakeThreshold];
}

- (BOOL)__testForTiltEvent:(UIAcceleration*)acceleration 
{
    return [self __testForAccelerometerEvent:acceleration threshold:kGUJNativeAccelerometerManagerTiltThreshold];
}

- (BOOL)__testForHysteresisExcited:(UIAcceleration*)acceleration 
{
    return [self __testForAccelerometerEvent:acceleration threshold:kGUJNativeAccelerometerManagerFreeThreshold];
}

+ (GUJNativeAccelerometerManager*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeAccelerometerManager alloc] init];
        [sharedInstance_ performSelector:@selector(__initializeAccelerometer)];
    }          
    return sharedInstance_;
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        self = [super init];        
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityShakeAndTilt];
        }
    }           
    return self;
}   
#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:receiver selector:selector name:GUJDeviceShakeNotification object:nil];  
}

#pragma mark accelerometer delegate
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{    
    if (self.lastAcceleration && accelerometerEnabled_ ) {
        if (!hysteresisExcited_ && [self __testForShakingEvent:acceleration] ) {
            hysteresisExcited_      = YES;
            isShaking_              = YES;
        } else if (!hysteresisExcited_ && !isShaking_ && [self __testForTiltEvent:acceleration] ) {
            _lastAcceleration       = nil;
            accelerometerEnabled_   = NO;        
            // send tilt notification
            [[NSNotificationCenter defaultCenter] postNotification:
             [NSNotification notificationWithName:GUJDeviceTiltNotification object:nil]
             ];              
            // wait            
            [self performSelector:@selector(__enableAccelerometer) withObject:nil afterDelay:0.5];            
        } else if ( hysteresisExcited_ && isShaking_ && [self __testForHysteresisExcited:acceleration] ) {
            hysteresisExcited_      = NO;
            isShaking_              = NO;
            accelerometerEnabled_   = NO;            
            _lastAcceleration       = nil;
            // send shake notificaion
            [[NSNotificationCenter defaultCenter] postNotification:
             [NSNotification notificationWithName:GUJDeviceShakeNotification object:nil]
             ];              
            // wait
            [self performSelector:@selector(__enableAccelerometer) withObject:nil afterDelay:1.5];
        }
    } else if (!self.lastAcceleration && !accelerometerEnabled_ ) {
        [self performSelector:@selector(__enableAccelerometer) withObject:nil afterDelay:0.1];
    }
    
    self.lastAcceleration = acceleration;
}

@end
