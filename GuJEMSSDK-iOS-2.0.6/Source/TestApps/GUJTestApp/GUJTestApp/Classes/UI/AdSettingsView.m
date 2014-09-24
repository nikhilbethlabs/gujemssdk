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
#import "AdSettingsView.h"

@implementation AdSettingsView

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* _kbValue = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect _kbFrame = [_kbValue CGRectValue];
    CGRect _frame = self.frame;
    _frame.origin.y = _frame.origin.y-_kbFrame.size.height+44;
    [self setFrame:_frame];
    [self setKeyboardVisible:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* _kbValue = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect _kbFrame = [_kbValue CGRectValue];
    CGRect _frame = self.frame;
    _frame.origin.y = _frame.origin.y+_kbFrame.size.height;
    [self setFrame:_frame];
    [self setKeyboardVisible:NO];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"AdSettingsView_iPhone" owner:self options:nil] objectAtIndex:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)showSettings
{
    if( ![self visible] ) {
        [self showHideSettings:nil];
    }
}

- (void)hideSettings
{
    if( [self visible] ) {
        [self showHideSettings:nil];
    }
}

- (IBAction)showHideSettings:(id)sender {
    
    if( [self keyboardVisible] ) {
        return;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float _y = 0.0f;
    if( [self visible] ) {
        _y = (screenRect.size.height)+140;
        [self setVisible:NO];
    } else {
        _y = (screenRect.size.height)-(self.frame.size.height)-98;
        [self setVisible:YES];
    }
    CGRect frame = self.frame;
    frame.origin.y = _y;
    [self setFrame:frame];
}

- (IBAction)requestAdTouched:(id)sender {
    [[self adSpaceId] resignFirstResponder];
    [[self zoneId] resignFirstResponder];
    [[self siteId] resignFirstResponder];
    if( [self visible] ) {
       [self showHideSettings:nil];
    }
}

@end
