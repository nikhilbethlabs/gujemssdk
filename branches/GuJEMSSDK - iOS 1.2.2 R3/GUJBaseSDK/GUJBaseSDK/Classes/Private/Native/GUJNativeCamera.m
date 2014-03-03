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
#import "GUJNativeCamera.h"

@implementation GUJNativeCamera

static GUJNativeCamera *sharedInstance_;

@synthesize currentImage = _currentImage;

- (void)__showImagePickerOnRootViewController
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if( [rootVC isKindOfClass:[UIViewController class]] ) {
        [((UIViewController*)rootVC) presentModalViewController:pickerController_ animated:YES];        
    }  
}

- (void)__initialize
{    
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceCameraEventNotification object:_currentImage];     
}

+(GUJNativeCamera*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeCamera alloc] init];
        [sharedInstance_ performSelector:@selector(__initialize)];
    }          
    return sharedInstance_;   
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        self = [super init];        
        if( self ) {
               [super __setRequiredDeviceCapability:GUJDeviceCapabilityCamera]; 
        }
    }           
    return self;
}   

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
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
    [[GUJNotificationObserver sharedInstance] registerForNotification:receiver name:GUJDeviceCameraEventNotification selector:selector];
}

- (void)unregisterForNotfication:(id)receiver
{
    [[GUJNotificationObserver sharedInstance] removeFromNotificationQueue:receiver name:GUJDeviceCameraEventNotification];
}

#pragma mark public methods
- (void)openGallery
{
    pickerController_ = [[UIImagePickerController alloc] init];
    [pickerController_ setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [pickerController_ setDelegate:self];
    
    _currentImage   = nil;
    // indentify as gallery image
    isGalleryImage_ = YES;

    [self performSelectorOnMainThread:@selector(__showImagePickerOnRootViewController) withObject:nil waitUntilDone:NO];    
}

- (void)openCamera
{
    pickerController_ = [[UIImagePickerController alloc] init]; 
    [pickerController_ setSourceType:UIImagePickerControllerSourceTypeCamera];
    [pickerController_ setDelegate:self];
    
    _currentImage   = nil;
    // indentify as camera image
    isCameraImage_ = YES;
    
    [self performSelectorOnMainThread:@selector(__showImagePickerOnRootViewController) withObject:nil waitUntilDone:NO];     
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    isGalleryImage_ = NO;
    isCameraImage_  = NO;
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{ 
#pragma unused(editingInfo) 
    [picker dismissModalViewControllerAnimated:YES];
    @autoreleasepool {
        if( [image respondsToSelector:@selector(copyWithZone:)] ) {
            _currentImage = [image copy];        
        } else {
            _currentImage = image;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:GUJDeviceCameraEventNotification object:_currentImage]
     ];     
}

- (BOOL)hasCameraImage
{
    BOOL result = NO;
    if( isCameraImage_ && _currentImage != nil ) {
        result = YES;
    }
    return result;
}

- (BOOL)hasGalleryImage
{
    BOOL result = NO;
    if( isGalleryImage_ && _currentImage != nil ) {
        result = YES;
    }
    return result;    
}

- (UIImage *)image
{
    return _currentImage;
}

@end
