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
#import "GUJServerConnection.h"
#import "GUJAdView.h"

/*!
 * The GUJXAXSISTrackingServerConnection extends the GUJServerConnection.
 * 
 * This class is used to track all XAXIS Video Ad reporting events to the initial  
 * amobee ad server.
 *
 * Anatomically the tracking request is like an ad request.
 * 
 * BUT:
 * - Additional tracking event parameters will be added by the
 * - GUJXAXSISTrackingServerConnection.
 * - Each Tracking Event has its own ad-space-id
 *
 * The method sendAdServerRequest will pipe the request thru 
 * sendAdServerRequestWithReportingAdSpaceId.
 *
 */
@interface GUJXAXSISTrackingServerConnection : GUJServerConnection {
  @private
#ifndef __clang_analyzer__
    id<GUJAdViewDelegate> delegate_;
#endif
}

+ (GUJXAXSISTrackingServerConnection*)instanceWithDelegate:(id<GUJAdViewDelegate>)delegate;

- (void)sendAdServerRequestWithReportingAdSpaceId:(NSString*)reportingAdSpaceId placementId:(NSString*)placementId;

@end
