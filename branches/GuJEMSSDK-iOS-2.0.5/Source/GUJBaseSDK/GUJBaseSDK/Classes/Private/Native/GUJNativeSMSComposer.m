//
//  GUJNativeSMSComposer.m
//  GEAdBaseSDK
//
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
#import "GUJNativeSMSComposer.h"

@implementation GUJNativeSMSComposer

@synthesize messageComposerVC = _messageComposerVC;

#pragma mark MFMessageComposeViewController delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
#pragma unused(result)
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark public methods
- (id)init
{
    self = [super init];
    if( self ) {
        [self __setRequiredDeviceCapability:GUJDeviceCapabilitySMS];
    }
    return self;
}

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (BOOL)canComposeMessage
{
    return ( [GUJUtil iosVersion] >= __IPHONE_4_0 && [self isAvailableForCurrentDevice] && [MFMessageComposeViewController canSendText]);
}

- (BOOL)composeMessagelTo:(NSString*)recipient title:(NSString*)title body:(NSString*)body
{
    BOOL result = NO;
    if( [self canComposeMessage] ) {
        _messageComposerVC = [[MFMessageComposeViewController alloc] init];
        [_messageComposerVC setRecipients:[NSArray arrayWithObject:recipient]];
        [_messageComposerVC setTitle:title];
        [_messageComposerVC setBody:body];
        [_messageComposerVC setMessageComposeDelegate:self];
        [GUJUtil showPresentModalViewController:_messageComposerVC];
        result = YES;
    }
    return result;
}

@end
