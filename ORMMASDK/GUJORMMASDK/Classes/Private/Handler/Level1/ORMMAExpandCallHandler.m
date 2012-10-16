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

#import "ORMMAExpandCallHandler.h"
#import "ORMMAStateObserver.h"
#import "ORMMAView.h"
@implementation ORMMAExpandCallHandler

- (float)__floatForPrameter:(NSString*)parameter
{
    float result = 0;
    if( parameter ) {
        result = [[NSNumber numberWithLongLong:[parameter longLongValue]] floatValue];
    }
    return result;
}

- (BOOL)performHandler
{
    BOOL result = NO;
    NSDictionary *values = [call_ value];    
    if( values && adView_ ) {
        BOOL resizeWebView      = YES;
        float x,y,width,height  = 0.0;        
        x       = [self __floatForPrameter:((NSString*)[values objectForKey:kORMMAParameterKeyForOriginX])];
        y       = [self __floatForPrameter:((NSString*)[values objectForKey:kORMMAParameterKeyForOriginY])];
        width   = [self __floatForPrameter:((NSString*)[values objectForKey:kORMMAParameterKeyForSizeWidth])];
        height  = [self __floatForPrameter:((NSString*)[values objectForKey:kORMMAParameterKeyForSizeHeight])];        

        // just resize the adViews height. 
        CGRect adViewFrame = adView_.frame;
        adViewFrame.size.height = height;  

        // calculate the y origin for the expanded adView frame
        if( (adViewFrame.size.height+adViewFrame.origin.y) > [GUJUtil sizeOfFirstResponder].height ) {
            float oldOriginY     = adViewFrame.origin.y;
            adViewFrame.origin.y = ((adViewFrame.size.height+adViewFrame.origin.y)
                                    -[GUJUtil sizeOfFirstResponder].height);            
            if( adViewFrame.origin.y == oldOriginY ) {
                adViewFrame.origin.y = adViewFrame.origin.y - oldOriginY;
            } else {
                adViewFrame.origin.y = ([GUJUtil sizeOfFirstResponder].height-height)/2;
            }
            if( adViewFrame.origin.y < 0 ) {
                adViewFrame.origin.y = 0;
            }
            resizeWebView = NO;
        }
        
        //publish the frame
        [adView_ setFrame:adViewFrame];  

        if( resizeWebView ) {
            // resize the content views size (webView)
            [((ORMMAView*)adView_) setWebViewFrame:CGRectMake(x, y, width, height)];
        }
        
        // fire change state event
        [[ORMMAStateObserver sharedInstance] changeState:kORMMAParameterValueForStateExpanded];
        
        result = YES;
    }
    return result;
}

@end
