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

static GUJNativeSMSComposer *sharedInstance_;

#pragma mark private methods
- (void)__showMessageComposerOnRootViewController
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if( [rootVC isKindOfClass:[UIViewController class]] ) {
        [((UIViewController*)rootVC) presentModalViewController:_messageComposerVC animated:YES];        
    }
}
#pragma mark MFMessageComposeViewController delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:YES];
    if( result == MessageComposeResultFailed ) {        
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kGUJNativeSMSComposerErrorDomain code:GUJ_ERROR_CODE_COMMAND_FAILD_OR_UNKNOWN userInfo:nil]];
    }
}   

#pragma mark public methods
+(GUJNativeSMSComposer*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[super alloc] init];
    }
    @synchronized(sharedInstance_) {            
        return sharedInstance_;
    }
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [super init];        
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilitySMS];
        }
    }
    @synchronized(sharedInstance_) {            
        return sharedInstance_;
    }
}    

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];
    }
    sharedInstance_ = nil;
}

- (BOOL)canComposeMessage
{
    return ( [GUJUtil iosVersion] >= __IPHONE_4_0 && [self isAvailableForCurrentDevice] && [MFMessageComposeViewController canSendText]);
}

- (void)composeMessagelTo:(NSString*)recipient title:(NSString*)title body:(NSString*)body
{
    if( [self canComposeMessage] ) {
        _messageComposerVC = [[MFMessageComposeViewController alloc] init];
        [_messageComposerVC setRecipients:[NSArray arrayWithObject:recipient]];
        [_messageComposerVC setTitle:title];
        [_messageComposerVC setBody:body];
        [_messageComposerVC setMessageComposeDelegate:[GUJNativeSMSComposer sharedInstance]];
        [self performSelectorOnMainThread:@selector(__showMessageComposerOnRootViewController) withObject:nil waitUntilDone:NO];
    } else {
        if( [GUJUtil iosVersion] < __IPHONE_4_0 ) {
            NSURL *smsURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",recipient]];
            if( [[UIApplication sharedApplication] canOpenURL:smsURL] ) {
                [[UIApplication sharedApplication] openURL:smsURL];
            } else {
                [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kGUJNativeSMSComposerErrorDomain code:GUJ_ERROR_CODE_UNAVAILABLE userInfo:nil]];
            }
        }
    }
}

@end
