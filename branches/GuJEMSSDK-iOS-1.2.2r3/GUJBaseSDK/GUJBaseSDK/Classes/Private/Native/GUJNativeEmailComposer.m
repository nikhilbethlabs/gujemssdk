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
#import "GUJNativeEmailComposer.h"

@implementation GUJNativeEmailComposer

@synthesize mailComposeVC = _mailComposeVC;

static GUJNativeEmailComposer *sharedInstance_;

#pragma mark private methods
- (void)__showMailComposerOnRootViewController
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if( rootVC && [rootVC isKindOfClass:[UIViewController class]] ) {
        [((UIViewController*)rootVC) presentModalViewController:_mailComposeVC animated:YES];        
    }
}

#pragma mark MFMailComposeViewController delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#pragma unused(result)
    [controller dismissModalViewControllerAnimated:YES];
    if( error != nil ) {
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kGUJNativeEmailComposerErrorDomain code:error.code userInfo:[error userInfo]]];        
    }
}

#pragma mark public methods
+(GUJNativeEmailComposer*)sharedInstance
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
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityEmail];
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

- (void)setHTMLEmail:(BOOL)isHTML
{
    isHTML_ = isHTML;
}

- (BOOL)isHTML
{
    return isHTML_;
}

- (BOOL)canComposeEmail
{
    return ([GUJUtil iosVersion] >= __IPHONE_3_0 && [self isAvailableForCurrentDevice] && [MFMailComposeViewController canSendMail]);
}

- (void)composeEmailTo:(NSString*)recipient subject:(NSString*)subject body:(NSString*)body
{
    if( [self canComposeEmail] ) {
        _mailComposeVC = [[MFMailComposeViewController alloc] init];
        [_mailComposeVC setMailComposeDelegate:[GUJNativeEmailComposer sharedInstance]];            
        [_mailComposeVC setToRecipients:[NSArray arrayWithObject:recipient]];
        [_mailComposeVC setSubject:subject];  
        [_mailComposeVC setMessageBody:body isHTML:isHTML_];
        [self performSelectorOnMainThread:@selector(__showMailComposerOnRootViewController) withObject:nil waitUntilDone:NO];
    } else {
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kGUJNativeEmailComposerErrorDomain code:GUJ_ERROR_CODE_UNAVAILABLE userInfo:nil]];
    }
}


@end
