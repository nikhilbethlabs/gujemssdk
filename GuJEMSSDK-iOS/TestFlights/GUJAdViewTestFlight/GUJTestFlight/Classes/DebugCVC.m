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

#import "DebugCVC.h"

@interface DebugCVC ()

@end

@implementation DebugCVC
@synthesize loadingSpinner;
@synthesize hideConsole;
@synthesize clearBtn;
@synthesize consoleBtn;
@synthesize tfDebugOutput;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    hideConsole.enabled = NO;
    clearBtn.enabled = NO;
    loadingSpinner.hidden = YES;
}

- (void)setOwner:(id)owner
{
    owner_ = owner;
}

- (void)setFrame:(CGRect)frame
{
    defaultFrame_ = frame;
    [self.view setFrame:frame];
}

- (IBAction)unloadAd:(id)sender 
{
    if( owner_ != nil && [owner_ respondsToSelector:@selector(releaseAdViewCtx)] ) {
        [owner_ performSelectorOnMainThread:@selector(releaseAdViewCtx) withObject:nil waitUntilDone:YES];
    }
}

- (IBAction)loadAd:(id)sender 
{
    if( owner_ != nil && [owner_ respondsToSelector:@selector(_performAdRequest)] ) {
        tfDebugOutput.text = @"";
        [owner_ performSelector:@selector(_performAdRequest)];
        [self enableSpinner:YES];
    }
}

- (IBAction)expandConsole:(id)sender 
{
    float height = (self.view.superview.frame.size.height-100);
    self.view.frame = CGRectMake(0, 100, defaultFrame_.size.width, height);
    hideConsole.enabled = YES;   
    consoleBtn.enabled = NO;    
    [[self.view superview] bringSubviewToFront:self.view];
}

- (IBAction)collapseConsole:(id)sender 
{
    self.view.frame = defaultFrame_;
    hideConsole.enabled = NO;    
    consoleBtn.enabled = YES;
}

- (void)viewDidUnload {
    [self setHideConsole:nil];
    [self setTfDebugOutput:nil];
    [self setClearBtn:nil];
    [self setConsoleBtn:nil];
    [self setLoadingSpinner:nil];
    [super viewDidUnload];
}

- (void)adTextToConsole:(NSString*)console
{
    NSString *message = [NSString stringWithFormat:@"%@%@\r\n",tfDebugOutput.text,console];
    [tfDebugOutput performSelectorOnMainThread:@selector(setText:) withObject:message waitUntilDone:YES];
}

- (void)enableSpinner:(BOOL)enable
{
    if( enable ) {
        loadingSpinner.hidden = NO;
        [loadingSpinner performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:YES];
    } else {
        loadingSpinner.hidden = YES;
        [loadingSpinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];        
    }
}

- (void)enableUnloadAd:(BOOL)enable
{
    if( enable ) {        
        clearBtn.enabled = YES;
    } else {        
        clearBtn.enabled = NO;        
    }
}
@end
