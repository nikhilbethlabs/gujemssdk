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
#import "AdConsole.h"

@implementation AdConsole

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"AdConsole_iPhone" owner:self options:nil] objectAtIndex:0];
        [self addConsoleText:@"init"];
    }
    return self;
}

- (IBAction)clearConsole {
    [[self debugTextView] setText:@""];
}

- (void)addConsoleText:(NSString*)text
{
    NSString *_debugtext = [self debugTextView].text;
    _debugtext = [NSString stringWithFormat:@"%@\n%@",text,_debugtext];
    [[self debugTextView] setText:_debugtext];
}

- (void)showConsole
{
    if( ![self visible] ) {
        [self showHideConsole:nil];
    }
}

- (void)hideConsole
{
    if( [self visible] ) {
        [self showHideConsole:nil];
    }
}

- (IBAction)showHideConsole:(id)sender {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float _y = 0.0f;
    if( [self visible] ) {
        _y = (screenRect.size.height)+140;
        [self setVisible:NO];
    } else {
        _y = (screenRect.size.height)-(self.frame.size.height)-141;
        [self setVisible:YES];
    }
    CGRect frame = self.frame;
    frame.origin.y = _y;
    [self setFrame:frame];
}
@end
