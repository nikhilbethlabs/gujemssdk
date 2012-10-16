//
//  GUJNativeScreenSizeManager.m
//  GEAdBaseSDK
//
//  Created by Sven Ewert on 16.08.12.
//  Copyright (c) 2012 gomindo gmbh. All rights reserved.
//

#import "GUJNativeScreenSizeManager.h"

@implementation GUJNativeScreenSizeManager

- (id)init {
    self = [super init];
    
    if(self) {        
       // [super __setRequiredDeviceCapability:GUJDeviceCapabilitySMS];
    }
    
    return self;
}  

- (BOOL)willPostNotification
{
    return YES;
}

@end
