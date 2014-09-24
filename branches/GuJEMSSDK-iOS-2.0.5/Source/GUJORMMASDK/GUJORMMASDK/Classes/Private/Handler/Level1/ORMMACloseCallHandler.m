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
#import "ORMMACloseCallHandler.h"
#import "ORMMAView.h"
#import "GUJAdConfiguration.h"

@implementation ORMMACloseCallHandler

- (void)performHandler:(void(^)(BOOL result))completion
{
    BOOL result = YES;
    NSString *_currentORMMAState = [((ORMMAView*)[self adView]) ormmaViewState];
    BOOL downgradeSize = ([_currentORMMAState isEqualToString:kORMMAParameterValueForStateResized] ||
                          [_currentORMMAState isEqualToString:kORMMAParameterValueForStateExpanded] );
    
    if( downgradeSize ) {
        if( [[self adView] isKindOfClass:[ORMMAView class]] ) {
            
            CGRect defaultFrame = [((ORMMAView*)[self adView]) initialAdViewFrame];
            defaultFrame.size.width = [GUJUtil sizeOfFirstResponder].width;
            [[self adView] setFrame:defaultFrame];
            
            // resize in modal window
            if( [[[self adView] adConfiguration] willShowAdModal] ) {
                if( [GUJUtil firstResponder] != nil && [[GUJUtil firstResponder] isKindOfClass:[UIViewController class]] ) {
                    [self adView].center = ((UIViewController*)[GUJUtil firstResponder]).view.center;
                    ((ORMMAView*)[self adView]).webView.frame = CGRectMake(0, 0, defaultFrame.size.width, defaultFrame.size.height);
                }
            } else {
                // resize the content views size (webView)
                [((ORMMAView*)[self adView]) setWebViewFrame:((ORMMAView*)[self adView]).webView.frame];
                ((ORMMAView*)[self adView]).webView.center = ((ORMMAView*)[self adView]).center;
            }
            [((ORMMAView*)[self adView]) changeState:kORMMAParameterValueForStateDefault];
            
            // disable scrolling
            if( [((ORMMAView*)[self adView]) webView] != nil ) {
                id scrollView = [[[((ORMMAView*)[self adView]) webView] subviews] lastObject];
                if( [scrollView isKindOfClass:[UIScrollView class]] ) {
                    [ORMMAUtil changeScrollView:scrollView scrolling:NO];
                }
            }
        }
    } else {
        if( [[self adView] isKindOfClass:[ORMMAView class]] ) {
            [((ORMMAView*)[self adView]) hide];
        }
    }
    completion(result);
}

@end
