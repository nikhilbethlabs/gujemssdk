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
#import "ORMMAJavaScriptBridge.h"
#import "ORMMAView.h"

#import "GUJNativeOrientationManager.h"

@implementation ORMMAJavaScriptBridge

#define kORMMACallErrorIdentifier                   @"error"
#define kORMMACallHeadingChangeIdentifier           @"headingChange"
#define kORMMACallKeyboardChangeIdentifier          @"keyboardChange"
#define kORMMACallLocationChangeIdentifier          @"locationChange"
#define kORMMACallNetworkChangeIdentifier           @"networkChange"
#define kORMMACallOrientationChangeIdentifier       @"orientationChange"
#define kORMMACallScreenChangeIdentifier            @"screenChange"
#define kORMMACallSizeChangeIdentifier              @"sizeChange"
#define kORMMACallStateChangeIdentifier             @"stateChange"
#define kORMMACallShakeChangeIdentifier             @"shake"
#define kORMMACallTiltChangeIdentifier              @"tiltChange"
#define kORMMACallViewableChangeIdentifier          @"viewableChange"

#define kORMMACallNativeCallStateTrue               @"Y"
#define kORMMACallNativeCallStateFalse              @"N"

static ORMMAJavaScriptBridge *sharedInstance_;

+(ORMMAJavaScriptBridge*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[super alloc] init];
    }
    @synchronized(sharedInstance_) {        
        return sharedInstance_;
    }
}

- (void)attachToAdView:(id)adView
{
    if( [self __isORMMAView:adView] ) {
        ormmaView_ = adView;
        webView_ = [((ORMMAView*)adView) webView];
        [webView_ setDelegate:self];
    } else {        
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:GUJ_ERROR_CODE_FAILED_TO_ASSIGN_OBJ userInfo:nil]];
    }
}

- (BOOL)isAttachedToAdView
{
    return ( webView_ != nil );
}

- (BOOL)isAttachedToAdView:(id)adView
{
    return [ormmaView_ isEqual:adView];
}

- (UIWebView*)attachedAdView
{
    return webView_;
}

- (void)setORMMASupport:(NSString*)ormmaSupport
{
    ormmaSupport_ = ormmaSupport;
}

- (ORMMACommandState)executeCommand:(ORMMACommand*)command
{
    if( [command state] == ORMMACommandStatePrepared ) {
        if( webView_ != nil ) {
            NSString *cmdResult = [webView_ stringByEvaluatingJavaScriptFromString:[command stringRepresentation]];
            [command setCommandResult:cmdResult];
            _logd_tm(self,@"executeCommand:",[command stringRepresentation],@"Result:",cmdResult,nil);
            if( [cmdResult isEqualToString:kEmptyString] ) {
                [command setCommandState:ORMMACommandStateFailed];                
            } else {
                [command setCommandState:ORMMACommandStateSucceed];
            }
        } else {
            [command setCommandState:ORMMACommandStateFailed];               
        }
    }
    return [command state];
}

- (void)unload
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    
    [[ORMMAResourceBundleManager sharedInstance] freeInstance];
    
    [[ORMMAHTMLTemplate sharedInstance] freeInstance];
    [[ORMMAWebBrowser sharedInstance] freeInstance];
    
    [self __unloadNativeInterfaces];
    [webView_ setDelegate:nil];
    ormmaSupport_   = nil;
    ormmaInit_      = NO;
    ormmaSetup_     = NO;
    sharedInstance_ = nil;
}

#pragma mark webview delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    _logd_frame(webView, webView.frame);
    _logd_tm(self,@"webView:shouldStartLoadWithRequest:",@"URL:",[[request URL] description],nil);
    
    // recreate a non cached urlrequest
    request = [NSMutableURLRequest requestWithURL:[request URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kGUJDefaultAdReloadInterval];
    
    // parse the current url and check if its an call object
    ORMMACall *call = [ORMMACall parse:[[request URL] description]];
    if( [call isValidCall] ) {
        if( ormmaSetup_ ) {
            /*
             * if ORMMA is setted up, we start to handle every call-back
             * normally all event-handlers will be initalized and native services will be activated at the beginning.
             */
            [self performSelectorOnMainThread:@selector(__handleCall:) withObject:call waitUntilDone:YES];
        } else {
            /*
             * initial callback received
             */
            if( [call isServiceCall] ) {
                [self performSelectorOnMainThread:@selector(__handleCall:) withObject:call waitUntilDone:YES];              
            } else {
                /* we can not receive calls other than service calls before the setup phase.
                 * so all this invalid cammands, except the close command, will be ignored. 
                 * (!) this can/will/must interrupt a invalid banner implementation.
                 */
                if( [[call name] isEqualToString:kORMMAParameterValueForCommandClose] ) {                    
                    [self performSelectorOnMainThread:@selector(__handleCall:) withObject:call waitUntilDone:YES];
                } else {                    
                    _logd_tm(self, @"UndefinedORMMACall",[call name],nil);
                }
            }
        }
        return NO;
    } else {
        if( (ormmaSetup_ && ormmaInit_) || [self __isExternalAdViewRequest] ) {
            [webView_ stopLoading];
            if( [((ORMMAView*)ormmaView_) isInterstitial] ) {
                [((ORMMAView*)ormmaView_) hideIinterstitialVC];
            }
            [self performSelector:@selector(__openInternalWebBrowser:) withObject:request afterDelay:0.5];
            id delegate = [ormmaView_ performSelector:@selector(__superDelegate)];
            
            if( [((ORMMAView*)ormmaView_) isInterstitial] ) {
                if( [GUJUtil typeIsNotNil:delegate andRespondsToSelector:@selector(bannerView:receivedEvent:)] ) {
                    [delegate bannerView:ormmaView_ receivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeSystemMessage message:ORMMA_EVENT_MESSAGE_RELOAD_AD_VIEW]];
                }   
            } else {
                if( [GUJUtil typeIsNotNil:delegate andRespondsToSelector:@selector(interstitialViewReceivedEvent:)] ) {
                    [delegate interstitialViewReceivedEvent:[GUJAdViewEvent eventForType:GUJAdViewEventTypeSystemMessage message:ORMMA_EVENT_MESSAGE_RELOAD_AD_VIEW]];
                }                  
            }
            
            return NO;
        } else {
            return YES;
        }
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if( ![webView_.request.URL.absoluteString isEqualToString:kORMMAURLAboutBlank] ) {
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:error.code userInfo:[error userInfo]]];
    }
}

- (void)__resizeAndDisplayAdView
{
    if( !ormmaInit_ ) {
        if( [self __sizeToFitAdContent] ) {
            ormmaInit_ = YES;
            if( [self __hasORMMAObject] && [self __hasORMMAReadyFunction] ) {        
                _logd_tm(self, @"webViewDidFinishLoad:",@"ORMMA-Object and ORMMAReadyFunction found.",nil);
                [self performSelector:@selector(__performInitialORMMASequence) withObject:nil afterDelay:0.5];                
            } else {
                /*
                 * A RichMedia Ad that does not implement ORMMA has been loaded. Show the contents.
                 */
                _logd_tm(self, @"webViewDidFinishLoad:",@"No ORMMA-Object or ORMMAReady-Function found",nil);                
                [ormmaView_ show];
            }
        } else {            
            /*
             * Error is allready thrown by __sizeToFitAdContent .
             * Do nothing.
             */
        }
    } else {  
        // error: ormmaInit is not FALSE. Something went wrong. Unload the ad now.
        id delegate = [ormmaView_ performSelector:@selector(__superDelegate)];
        if( [GUJUtil typeIsNotNil:delegate andRespondsToSelector:@selector(view:didFailToLoadAdWithUrl:andError:)] ) {
            [delegate view:ormmaView_ didFailToLoadAdWithUrl:nil andError:[GUJUtil errorForDomain:kORMMAJavaScriptBridgeErrorDomain andCode:ORMMA_ERROR_CODE_ILLEGAL_CONTENT_SIZE]];
        }          
    }
}

- (void)__resizeAndDisplayAdViewWithDelay
{
    [self performSelector:@selector(__resizeAndDisplayAdView) withObject:nil afterDelay:kGUJDefaultAdViewResizeAndDisplayDelay];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /*
     * If the device is NOT on Wi-Fi, we perform a delayed resize to ensure the ad is fully loaded in background
     */
    /*
     * Wi-Fi check skipped, cause Wi-Fi can also be very slow.
     //if( [[GUJUtil networkInterfaceName] isEqualToString:kNetworkInterfaceIdentifierForTypeEn0] ) {
     //  [self performSelectorOnMainThread:@selector(__resizeAndDisplayAdView) withObject:nil waitUntilDone:NO];        
     //} else {
     //  [self performSelectorOnMainThread:@selector(__resizeAndDisplayAdViewWithDelay) withObject:nil waitUntilDone:NO];
     //}
     */
    [self performSelectorOnMainThread:@selector(__resizeAndDisplayAdViewWithDelay) withObject:nil waitUntilDone:NO];
}

@end

/*
 * Implementation of ORMMAJavaScriptBridge(PrivateImplementation)
 *
 */
@implementation ORMMAJavaScriptBridge(PrivateImplementation)

- (BOOL)__isORMMAView:(id)view
{
    return [view isKindOfClass:[ORMMAView class]];
}

- (BOOL)__hasORMMAObject
{
    BOOL result = NO;
    NSString *jsResponse = [webView_ stringByEvaluatingJavaScriptFromString:kORMMAJavascriptTypeOfOrmmaView];
    result = ( jsResponse != nil && [jsResponse isEqualToString:kORMMAJavascriptObejctIdentifier] );
    return result;
}

- (BOOL)__hasORMMAReadyFunction
{
    BOOL result = NO;    
    NSString *jsResponse = [webView_ stringByEvaluatingJavaScriptFromString:kORMMAJavascriptTypeCheckOfOrmmaReadyFunction];
    result = (jsResponse != nil && [jsResponse isEqualToString:kORMMAParameterValueForBooleanTrue]);
    return result;
}

- (BOOL)__isExternalAdViewRequest
{
    BOOL result = NO;
    if( !([self __hasORMMAObject] && [self __hasORMMAReadyFunction]) ) {
        if( webView_ != nil && webView_.request != nil && webView_.request.URL != nil ) {
            NSString *currentURLString = webView_.request.URL.absoluteString;
            if(![currentURLString isEqualToString:kEmptyString] &&
               ![currentURLString isEqualToString:kORMMAURLAboutBlank] &&
               ![currentURLString hasSuffix:@"http://localhost"] ) {
                result = YES;
            }
        }
    }
    return result;
}

- (void) __unloadNativeInterfaces
{
    for (NSNumber *capability in [[GUJDeviceCapabilities sharedInstance] deviceCapabilities] ) {
        GUJNativeFrameWorkBridge *frameWorkBridge = [[GUJNativeFrameWorkBridge sharedInstance] nativeFrameWorkBridgeForDeviceCapability:[capability intValue]];
        if( frameWorkBridge ) {
            if( [frameWorkBridge isObserver] ) {
                [frameWorkBridge stopObserver];
                [frameWorkBridge unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];
            }
            // start location manager updates
            if( [capability intValue] == GUJDeviceCapabilityLocation ) {
                if( [frameWorkBridge respondsToSelector:@selector(stopUpdatingLocation)] ) {
                    [frameWorkBridge performSelector:@selector(stopUpdatingLocation)];
                }
            }
            // start heading updates
            if( [capability intValue] == GUJDeviceCapabilityHeading ) {
                if( [frameWorkBridge respondsToSelector:@selector(stopUpdatingHeading)] ) {
                    [frameWorkBridge performSelector:@selector(stopUpdatingHeading)];
                }
            }  
            if( [frameWorkBridge respondsToSelector:@selector(freeInstance)] ) {
                [frameWorkBridge performSelector:@selector(freeInstance)];
            }
        }        
    }
}

- (BOOL) __loadNativeInterfaceForDeviceCapability:(GUJDeviceCapability)capability notificationState:(NSString*)ormmaState
{
    BOOL result             = NO;
    BOOL notificationState  = [ormmaState isEqualToString:kORMMACallNativeCallStateTrue];
    
    GUJNativeFrameWorkBridge *frameWorkBridge = [[GUJNativeFrameWorkBridge sharedInstance] nativeFrameWorkBridgeForDeviceCapability:capability];
    
    if( frameWorkBridge != nil && [frameWorkBridge respondsToSelector:@selector(isAvailableForCurrentDevice)]) {
        result = (BOOL)[frameWorkBridge performSelector:@selector(isAvailableForCurrentDevice)];
        
        if( result ) {            
            /*
             * this causes the banner changes the state.
             * register for notifications if framework bridge will post notifications
             * and ormma state is true.
             */
            notificationState = notificationState && [frameWorkBridge willPostNotification];
            if( notificationState ) {
                // register for notification
                [frameWorkBridge registerForNotification:[ORMMAJavaScriptBridge sharedInstance] selector:@selector(__nativeNotification:)];        
                
                if( [frameWorkBridge isObserver] ) {
                    result = [frameWorkBridge startObserver];
                }
                
                /*
                 * now, test for class type and enable or disable specific services.
                 */
                
                // start location manager updates
                if( capability == GUJDeviceCapabilityLocation ) {
                    if( [frameWorkBridge respondsToSelector:@selector(startUpdatingLocation)] ) {
                        [frameWorkBridge performSelector:@selector(startUpdatingLocation)];
                    }
                }
                // start heading updates
                if( capability == GUJDeviceCapabilityHeading ) {
                    if( [frameWorkBridge respondsToSelector:@selector(startUpdatingHeading)] ) {
                        [frameWorkBridge performSelector:@selector(startUpdatingHeading)];
                    }
                }                  
                
            } else { // ohterwiese try to unregister for notifications. 
                if( [frameWorkBridge isObserver] ) {
                    result = [frameWorkBridge stopObserver];
                }             
                if( [frameWorkBridge respondsToSelector:@selector(freeInstance)] ) {
                    [frameWorkBridge freeInstance];
                }
                [frameWorkBridge unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];  
                
            }          
            
        } // not result. class not loaded
        
    }   
    _logd_tm(self,[NSString stringWithFormat:@"Cap:(%i) Loaded: %i",capability,result],nil);
    return result;
}

- (BOOL)__sizeToFitAdContent
{ 
    BOOL result = NO;
    
    // stop all size observers
    [[GUJNativeNetworkObserver sharedInstance] unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];        
    [[GUJNativeSizeObserver sharedInstance] stopListeningForResizingAdView];        
    [[GUJNativeSizeObserver sharedInstance] stopObserver];   
    
    // call resize on ormmaview
    [((ORMMAView*)ormmaView_) performSelector:@selector(__sizeToFitAdContent)];
    // check size
    if( (webView_.frame.size.width > 1.0f) && (webView_.frame.size.height > 1.0f) ) {
        _logd_frame(self, webView_.frame);
        result = YES;
    } else {
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:GUJ_ERROR_CODE_UNABLE_TO_COMPLETE userInfo:nil]];
        // hide the ormma view and unload the webview instance
        [((ORMMAView*)ormmaView_) hide];        
        [webView_ loadHTMLString:kEmptyString baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kORMMAProtocolIdentifier,kORMMAParameterValueForCommandClose]]];
        result = NO;
    }
    return result;
}

- (void)__openInternalWebBrowser:(NSURLRequest*)urlRequest
{     
    [webView_ stopLoading];
    [[ORMMAWebBrowser sharedInstance] setDelegate:ormmaView_];
    [[ORMMAWebBrowser sharedInstance] navigateToURL:urlRequest];
    [GUJUtil showPresentModalViewController:[ORMMAWebBrowser sharedInstance]];        
}

@end //PrivateImplementation

/*
 * implementation of ORMMAJavaScriptBridge(InitialSequence)
 */
@implementation ORMMAJavaScriptBridge(PrivateInitialSequence)

- (void)__performInitialORMMASequence
{
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter stringParameter:kORMMAParameterValueForStateHidden 
                                                   forKey:kORMMAParameterKeyForState]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter stringParameter:[ORMMAUtil translateNetworkInterface:[[GUJNativeNetworkObserver sharedInstance] networkInterfaceName]]
                                                   forKey:kORMMAParameterKeyForNetwork]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter sizeParameter:[GUJUtil sizeOfFirstResponder] 
                                                 forKey:kORMMAParameterKeyForScreenSize]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter sizeParameter:[((ORMMAView*)ormmaView_) webViewFrame].size
                                                 forKey:kORMMAParameterKeyForSize]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter sizeParameter:[GUJUtil sizeOfFirstResponder] 
                                                 forKey:kORMMAParameterKeyForMaxSize]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter rectParameter:((ORMMAView*)ormmaView_).frame
                                                 forKey:kORMMAParameterKeyForDefaultPosition]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter parameter:NSNUMBER_WITH_INT( [[GUJNativeOrientationManager sharedInstance] deviceOrientation] )
                                             forKey:kORMMAParameterKeyForOrientation]]
     ];
    
    [self executeCommand:[ORMMACommand fireChangeEventCommand:
                          [ORMMAParameter parameter:ormmaSupport_
                                             forKey:kORMMAParameterKeyForSupports]]
     ];
    
    [self executeCommand:[ORMMACommand commandWithString:kORMMACommandStringForSignalReady]];     
    ormmaSetup_ = YES;    
}
@end // PrivateInitialSequence

/*
 * implementation of ORMMAJavaScriptBridge(PrivateNotificationHandling)
 */
@implementation ORMMAJavaScriptBridge(PrivateNotificationHandling)

- (void)__nativeNotification:(NSNotification*)notification
{  
    _logd_tm(self, @"__nativeNotification:",notification.name,nil);
    
    if( [notification.name isEqualToString:GUJDeviceErrorNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[NSError class]] ) {
            NSError *error = (NSError*)notification.object;
            NSString *errorString = [NSString stringWithFormat:@"[%i] %@",[error code],[error localizedDescription]];
            [self executeCommand:[ORMMACommand fireErrorEventCommand:errorString key:[error domain]]];
        }
    }
    
    if( [notification.name isEqualToString:GUJDeviceOrientationChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeOrientationManager class]] ) {
            UIDeviceOrientation orientation = [((GUJNativeOrientationManager*)notification.object) deviceOrientation];              
            [self executeCommand:[ORMMACommand fireChangeEventCommand:[ORMMAParameter parameter:NSNUMBER_WITH_INT(GUJ_FORMAT_ORIENTATION_IN_DEGREES(orientation)) forKey:kORMMAParameterKeyForOrientation]]];            
            _logd_tm(self, @"orientationChanged:",NSNUMBER_WITH_INT(GUJ_FORMAT_ORIENTATION_IN_DEGREES(orientation)),NSNUMBER_WITH_INT(orientation),nil);            
        }  
    }
    if( [notification.name isEqualToString:GUJBannerStateChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[ORMMAStateObserver class]] ) {
            NSString *state = [((ORMMAStateObserver*)notification.object) state];
            _logd_tm(self, @"(NSNotification*)stateChanged:",state,nil);
            [self executeCommand:[ORMMACommand fireChangeEventCommand:
                                  [ORMMAParameter stringParameter:state 
                                                           forKey:kORMMAParameterKeyForState]]
             ];            
        }
    }
    if( [notification.name isEqualToString:GUJBannerSizeChangeNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[ORMMAView class]] ) {
            // in this case the resized object MUST be the ormma view
            ORMMAView *resizedObject = (ORMMAView*)notification.object;
            if( resizedObject == ((ORMMAView*)ormmaView_) ) {
                _logd_tm(self, @"(NSNotification*)sizeChanged:",nil);
                ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter sizeParameter:((ORMMAView*)ormmaView_).frame.size forKey:kORMMAParameterKeyForSize]];
                // the observer is not synced
                // must run on mainthread cause the webview is maybe processing a redraw which causes a crash when calling directly
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];
                
            }
        }
    }
    
    if([notification.name isEqualToString:GUJDeviceSuperviewSizeChangedNotification] || 
       [notification.name isEqualToString:GUJDeviceScreenSizeChangedNotification]) {
        if( notification.object != nil && [notification.object isKindOfClass:[UIView class]] ) {
            _logd_tm(self, @"(NSNotification*)sreenChanged:",nil);
            ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter sizeParameter:((UIView*)notification.object).frame.size forKey:kORMMAParameterKeyForScreenSize]];
            [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];
        }
    }
    
    if( [notification.name isEqualToString:GUJDeviceKeyboardStateChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeKeyboardObserver class]] ) {
            _logd_tm(self, @"(NSNotification*)keyboardChanged:",nil);
            [self executeCommand:[ORMMACommand fireChangeEventCommand:
                                  [ORMMAParameter boolParameter:[((GUJNativeKeyboardObserver*)notification.object) keyboardIsOnScreen] forKey:kORMMAParameterKeyForKeyboardState]]
             ]; 
        }
    }
    
    if( [notification.name isEqualToString:GUJDeviceLocationChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeFrameWorkBridge class]] ) {
            GUJNativeFrameWorkBridge *locationManager = ((GUJNativeFrameWorkBridge*)notification.object);
            if( locationManager != nil && [locationManager respondsToSelector:@selector(locationLatitudeStringRepresentation)] ) {
                // we got the locationmanager 
                NSString *lat = [locationManager performSelector:@selector(locationLatitudeStringRepresentation)];
                NSString *lon = [locationManager performSelector:@selector(locationLongitudeStringRepresentation)]; 
                NSString *acc = [locationManager performSelector:@selector(accuracyStringRepresentation)];    
                NSString *locationString = [NSString stringWithFormat:kORMMAStringFormatForLocationParameter,lat,lon,acc];
                _logd_tm(self, @"(NSNotification*)locationChanged:",locationString,nil);
                [self executeCommand:[ORMMACommand fireChangeEventCommand:
                                      [ORMMAParameter parameter:locationString 
                                                         forKey:kORMMAParameterKeyForLocation]]
                 ];    
                
            }
        }
    }
    
    if( [notification.name isEqualToString:GUJDeviceNetworkChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeNetworkObserver class]] ) {
            GUJNativeNetworkObserver *networkObserver = ((GUJNativeNetworkObserver*)notification.object);
            NSString *interfaceName = [ORMMAUtil translateNetworkInterface:[networkObserver networkInterfaceName]];
            _logd_tm(self, @"(NSNotification*)networkChange:",interfaceName,nil);
            ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter stringParameter:interfaceName forKey:kORMMAParameterKeyForNetwork]];
            // the observer is not synced
            // must run on mainthread cause the webview is maybe stoll processing before the command is thrown
            [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];            
            
        }
    }    
    if( [notification.name isEqualToString:GUJDeviceShakeNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeShakeObserver class]] ) {
            if( [((GUJNativeShakeObserver*)notification.object) acceleration] != nil ) {
                float interval  = [((GUJNativeShakeObserver*)notification.object) interval];
                float intensity = [((GUJNativeShakeObserver*)notification.object) intensity];
                NSString *accelerationString = [NSString stringWithFormat:kORMMAStringFormatForShakeParameter,interval,intensity];                 
                _logd_tm(self, @"(NSNotification*)shake:",accelerationString,nil);                
                ORMMACommand *changeCmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter parameter:accelerationString forKey:kORMMAParameterKeyForShakeProperties]];
                
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:changeCmd waitUntilDone:YES];                          
                ORMMACommand *cmd = [ORMMACommand fireShakeEventCommand:accelerationString];    
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];   
            }
        }
    }
    if( [notification.name isEqualToString:GUJDeviceTiltNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeTiltObserver class]] ) {
            UIAcceleration *acceleration = [((GUJNativeTiltObserver*)notification.object) acceleration];
            if( acceleration != nil ) {
                NSString *accelerationString = [NSString stringWithFormat:kORMMAStringFormatForTiltParameter,acceleration.x,acceleration.y,acceleration.z];           
                _logd_tm(self, @"(NSNotification*)tilt:",accelerationString,nil);                   
                ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter parameter:accelerationString forKey:kORMMAParameterKeyForTilt]];                
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];                  
            }
        }        
    }
    if( [notification.name isEqualToString:GUJDeviceHeadingChangedNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[GUJNativeFrameWorkBridge class]] ) {
            GUJNativeFrameWorkBridge *locationManager = ((GUJNativeFrameWorkBridge*)notification.object);
            if( locationManager != nil && [locationManager respondsToSelector:@selector(headingInDegreesStringRepresentation)] ) {
                NSString *headingString = [locationManager performSelector:@selector(headingInDegreesStringRepresentation)];
                _logd_tm(self, @"(NSNotification*)heading:",headingString,nil);                   
                ORMMACommand *cmd = [ORMMACommand fireChangeEventCommand:[ORMMAParameter parameter:headingString forKey:kORMMAParameterKeyForHeading]];                
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];                               
            }
        }
    }
    if( [notification.name isEqualToString:GUJDeviceErrorNotification] ) {
        if( notification.object != nil && [notification.object isKindOfClass:[NSError class]] ) {
            NSError *error = ((NSError*)notification.object);
            if( [error.domain isEqualToString:kORMMAWebBrowserErrorDomain] ) {
                /** a good place to publish the error to ormma */
                ORMMACommand *cmd = [ORMMACommand fireErrorEventCommand:[error debugDescription] key:kORMMAWebBrowserErrorDomain];             
                [self performSelectorOnMainThread:@selector(executeCommand:) withObject:cmd waitUntilDone:YES];              
            }
        }
    }
}

@end //PrivateNotificationHandling

/*
 * implementation of ORMMAJavaScriptBridge(PrivateORMMACallHandling)
 */
@implementation ORMMAJavaScriptBridge(PrivateORMMACallHandling)
/**
 * Handle a ORMMA-ServiceCall.
 * This method does not validate a call.
 * You must PRE-Validate the call to ensure passing a valid serviceCall.
 */
- (BOOL)__handleServiceCall:(ORMMACall*)serviceCall
{
    BOOL result = YES;
    
    if( [serviceCall isCallForIdentifier:kORMMACallErrorIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[GUJNativeErrorObserver sharedInstance] registerForNotification:[ORMMAJavaScriptBridge sharedInstance] selector:@selector(__nativeNotification:)];              
            [[GUJNativeErrorObserver sharedInstance] startObserver];
        } else {
            [[GUJNativeErrorObserver sharedInstance] stopObserver];  
            [[GUJNativeErrorObserver sharedInstance] unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];               
        }  
    }
    
    if( [serviceCall isCallForIdentifier:kORMMACallHeadingChangeIdentifier] ) { 
        result = [self __loadNativeInterfaceForDeviceCapability:GUJDeviceCapabilityHeading notificationState:[serviceCall serviceCallValue]];
    }
    
    if( [serviceCall isCallForIdentifier:kORMMACallKeyboardChangeIdentifier] ) { 
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[GUJNativeKeyboardObserver sharedInstance] registerForNotification:[ORMMAJavaScriptBridge sharedInstance] selector:@selector(__nativeNotification:)];              
            [[GUJNativeKeyboardObserver sharedInstance] startObserver];
        } else {
            [[GUJNativeKeyboardObserver sharedInstance] stopObserver];  
            [[GUJNativeKeyboardObserver sharedInstance] unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];               
        }    
    }            
    
    if( [serviceCall isCallForIdentifier:kORMMACallLocationChangeIdentifier] ) { 
        result = [self __loadNativeInterfaceForDeviceCapability:GUJDeviceCapabilityLocation notificationState:[serviceCall serviceCallValue]];                              
    }
    
    if( [serviceCall isCallForIdentifier:kORMMACallNetworkChangeIdentifier] ) {      
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[GUJNativeNetworkObserver sharedInstance] registerForNotification:[ORMMAJavaScriptBridge sharedInstance] selector:@selector(__nativeNotification:)];            
            [[GUJNativeNetworkObserver sharedInstance] startObserver];
        } else {
            [[GUJNativeNetworkObserver sharedInstance] stopObserver];       
            [[GUJNativeNetworkObserver sharedInstance] unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];            
        }                    
    }
    
    if( [serviceCall isCallForIdentifier:kORMMACallOrientationChangeIdentifier] ) {
        result = [self __loadNativeInterfaceForDeviceCapability:GUJDeviceCapabilityOrientation notificationState:[serviceCall serviceCallValue]];                  
    }
    
    if( [serviceCall isCallForIdentifier:kORMMACallScreenChangeIdentifier] ) {
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[GUJNativeSizeObserver sharedInstance] registerForNotification:[ORMMAJavaScriptBridge sharedInstance] selector:@selector(__nativeNotification:) notificationName:GUJDeviceSuperviewSizeChangedNotification];                        
            [[GUJNativeSizeObserver sharedInstance] listenForResizingSuperview:((ORMMAView*)ormmaView_)];
            [[GUJNativeSizeObserver sharedInstance] startObserver];          
        } else {
            [[GUJNativeSizeObserver sharedInstance] stopListeningForResizingSuperview];                
            [[GUJNativeSizeObserver sharedInstance] unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance] notificationName:GUJDeviceSuperviewSizeChangedNotification];               
        }
    }
    
    if( [serviceCall isCallForIdentifier:kORMMACallSizeChangeIdentifier] ) { 
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[GUJNativeSizeObserver sharedInstance] registerForNotification:[ORMMAJavaScriptBridge sharedInstance] selector:@selector(__nativeNotification:)];
            [[GUJNativeSizeObserver sharedInstance] listenForResizingAdView:((ORMMAView*)ormmaView_)];
            [[GUJNativeSizeObserver sharedInstance] startObserver];
        } else {
            [[GUJNativeSizeObserver sharedInstance] stopListeningForResizingAdView];    
            [[GUJNativeSizeObserver sharedInstance] unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];            
        }
    }            
    
    if( [serviceCall isCallForIdentifier:kORMMACallStateChangeIdentifier] ) {  
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[ORMMAStateObserver sharedInstance] registerForNotification:[ORMMAJavaScriptBridge sharedInstance] selector:@selector(__nativeNotification:)];
            [[ORMMAStateObserver sharedInstance] startObserver];                
        } else {            
            [[ORMMAStateObserver sharedInstance] stopObserver];            
            [[ORMMAStateObserver sharedInstance] unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];
        }
    }    
    
    if( [serviceCall isCallForIdentifier:kORMMACallTiltChangeIdentifier] ) { 
        result = [self __loadNativeInterfaceForDeviceCapability:GUJDeviceCapabilityTilt notificationState:[serviceCall serviceCallValue]];                
    }  
    
    if( [serviceCall isCallForIdentifier:kORMMACallShakeChangeIdentifier] ) {    
        result = [self __loadNativeInterfaceForDeviceCapability:GUJDeviceCapabilityShake notificationState:[serviceCall serviceCallValue]];                
    } 
    
    if( [serviceCall isCallForIdentifier:kORMMACallViewableChangeIdentifier] ) { 
        if( [[serviceCall serviceCallValue] isEqualToString:kORMMACallNativeCallStateTrue] ) {
            [[ORMMAViewableObserver sharedInstance] registerForNotification:[ORMMAJavaScriptBridge sharedInstance]  selector:@selector(__nativeNotification:)];
            [[ORMMAViewableObserver sharedInstance] startObserver];
        } else {
            [[ORMMAViewableObserver sharedInstance] stopObserver];            
            [[ORMMAViewableObserver sharedInstance] unregisterForNotfication:[ORMMAJavaScriptBridge sharedInstance]];            
        }    
    }      
    return result;
}

- (void)__handleCall:(ORMMACall*)call
{
    BOOL result = NO;
    if( [call isValidCall] ) {
        if( [call isServiceCall] ) { // native service calls    
            _logd_tm(self, @"ServiceCall:",[call name],nil);
            result = [self __handleServiceCall:call];              
        } else { // all other calls
            _logd_tm(self, @"Call:",[call name],nil);
            result = [ORMMACallHandler handle:call forAdView:((ORMMAView*)ormmaView_)];            
        }
    }
    if( result ) {
        [self executeCommand:[ORMMACommand nativeCallSucceededCommand]];
    } else {
        _logd_tm(self, @"Unknown Call:",[call name],nil);
        [[GUJNativeErrorObserver sharedInstance] distributeError:[NSError errorWithDomain:kORMMAJavaScriptBridgeErrorDomain code:GUJ_ERROR_CODE_COMMAND_FAILED_OR_UNKNOWN userInfo:nil]];        
        [self executeCommand:[ORMMACommand nativeCallFailedCommand]];
    } 
}
@end // PrivateORMMACallHandling

