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
#import "ORMMAMapCallHandler.h"
#import "GUJNativeMapView.h"

@implementation ORMMAMapCallHandler

- (BOOL)__hasProperty:(NSString*)property
{
    return ([[[self call] value] objectForKey:property] != nil);
}

- (BOOL)__hasProperty:(NSString*)property withValue:(NSString*)value
{
    BOOL result = ([[[self call] value] objectForKey:property] != nil);
    if( result ) {
        if( ![((NSString*)[[[self call] value] objectForKey:property]) isEqualToString:value] ) {
            result = NO;
        }
    }
    return result;
}

- (NSString*)__stringValueForProperty:(NSString*)property
{
    NSString *result = nil;
    if( [self __hasProperty:property] ) {
        result = [[[self call] value] objectForKey:property];
        result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return result;
}

- (void)performHandler:(void(^)(BOOL result))completion
{
    BOOL result = NO;
    if( [[self call] value] ) {
        NSString *poiString         = [self __stringValueForProperty:@"poi"];
        NSString *annotationName    = kEmptyString;
        float    lat                = 0.0;
        float    lon                = 0.0;        
        
        /*
         * Possible stringformats: 
         * 51.209722,6.781071+My POI
         * +51.209722,6.781071+My POI
         * +51.209722,+6.781071+My POI
         * +51.209722,-6.781071+My POI
         * -51.209722,6.781071+My POI
         * -51.209722,-6.781071+My POI         
         */
        if( poiString ) {
            poiString = [poiString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // get lat and lon
            if( [poiString rangeOfString:@","].location != NSNotFound ) {
                
                // convert latitude
                NSArray *latLon = [poiString componentsSeparatedByString:@","];
                if( [latLon count] >= 1 ) {
                    NSString *latStr = ((NSString*)[latLon objectAtIndex:0]);                    
                    if( [latStr hasPrefix:@"+"] ) {
                        latStr = [latStr stringByReplacingOccurrencesOfString:@"+" withString:kEmptyString];
                    }
                    NSNumber *number = NSNUMBER_WITH_FLOAT([latStr floatValue]);
                    lat     = [number floatValue];
                    
                    // convert longitude
                    NSString *lonStr = ((NSString*)[latLon objectAtIndex:1]); 
                    if( [lonStr hasPrefix:@"+"] ) {
                        NSArray *chunks = [lonStr componentsSeparatedByString:@"+"];
                        if( [chunks count] > 0 ) {
                            lonStr = [chunks objectAtIndex:1];
                            if( [chunks count] > 1 ) { // check if we have a annotation text
                                annotationName = [chunks objectAtIndex:2];
                            }
                        }
                    } else if([lonStr rangeOfString:@"+"].location != NSNotFound ) {
                        NSArray *chunks = [lonStr componentsSeparatedByString:@"+"];
                        if( [chunks count] > 0 ) {// check if we have a annotation text
                            annotationName = [chunks objectAtIndex:1];
                        }
                    }
                    number  = NSNUMBER_WITH_FLOAT([lonStr floatValue]);
                    lon     = [number floatValue];
                    result  = YES;
                }
                
            }
            // display the mapview if the values fit
            if( result ) {
                _logd_tm(self, [NSString stringWithFormat:@"%f %f %@",lat,lon,annotationName],nil);
                MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
                region.center.latitude      = lat;
                region.center.longitude     = lon;
                region.span.latitudeDelta   = 0.01;
                region.span.longitudeDelta  = 0.01;
                [[[GUJNativeMapView alloc] init] mapViewForRegion:region title:annotationName subtitle:nil];
            }
        }
    }
    completion(result);
}


@end
