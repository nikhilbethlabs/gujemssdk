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

- (id)init
{
    self = [super init];
    if( self ) {
        [super __setRequiredDeviceCapability:GUJDeviceCapabilityCamera];
    }
    return self;
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

#pragma mark public methods
- (void)openGallery
{
    [self setPickerController:[[UIImagePickerController alloc] init]];
    [[self pickerController] setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [[self pickerController] setDelegate:self];
    
    [self setCurrentImage:nil];
    // indentify as gallery image
    [self setIsGalleryImage:YES];
    [GUJUtil showPresentModalViewController:[self pickerController]];
}

- (void)openCamera
{
    [self setPickerController:[[UIImagePickerController alloc] init]];
    [[self pickerController] setSourceType:UIImagePickerControllerSourceTypeCamera];
    [[self pickerController] setDelegate:self];
    
    [self setCurrentImage:nil];
    // indentify as camera image
    [self setIsCameraImage:YES];
    
    [GUJUtil showPresentModalViewController:[self pickerController]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self setIsGalleryImage:YES];
    [self setIsCameraImage:YES];
    [self setCurrentImage:nil];
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
     [NSNotification notificationWithName:GUJDeviceCameraEventNotification object:self]
     ];
}

- (BOOL)hasCameraImage
{
    BOOL result = NO;
    if( [self isCameraImage] && [self currentImage] != nil ) {
        result = YES;
    }
    return result;
}

- (BOOL)hasGalleryImage
{
    BOOL result = NO;
    if( [self isGalleryImage] && [self currentImage] != nil ) {
        result = YES;
    }
    return result;
}

- (UIImage *)image
{
    return _currentImage;
}

@end
