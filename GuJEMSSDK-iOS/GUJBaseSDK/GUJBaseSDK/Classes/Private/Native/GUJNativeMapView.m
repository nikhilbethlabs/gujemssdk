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
#import "GUJNativeMapView.h"

@implementation GUJGenericAnnotation
@synthesize coordinate, title, subtitle, storeId;

@end

@implementation GUJNativeMapView

static GUJNativeMapView *sharedInstance_;

- (void)__showMapViewOnRootViewController
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if( [rootVC isKindOfClass:[UIViewController class]] ) {
        @autoreleasepool {        
            GUJModalViewController *mapViewController = [[GUJModalViewController alloc] initWithNibName:nil bundle:nil];
            [mapViewController addSubviewInset:mapView_];
            [((UIViewController*)rootVC) presentModalViewController:mapViewController animated:YES];            
        }            
    }  
}

+(GUJNativeMapView*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeMapView alloc] init];
    }          
    return sharedInstance_;   
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        self = [super init];        
        if( self ) {
            [super __setRequiredDeviceCapability:GUJDeviceCapabilityMapKit]; 
        }
    }           
    return self;
}   

- (void)freeInstance
{
    [NSObject cancelPreviousPerformRequestsWithTarget:sharedInstance_];
    if( sharedInstance_ != nil ) {
        [[NSNotificationCenter defaultCenter] removeObserver:sharedInstance_];
    }
    sharedInstance_ = nil;
}

- (void)openMapsApp:(float)latitude andLongitude:(float)longitude
{
    NSString *param = [NSString stringWithFormat:@"%f,%f",latitude,longitude];
    NSString *url   = [NSString stringWithFormat: @"http://maps.google.com/maps?ll=%@",[param stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)mapViewForRegion:(MKCoordinateRegion)region
{    
    [self mapViewForRegion:region title:nil subtitle:nil];
}

- (void)mapViewForRegion:(MKCoordinateRegion)region title:(NSString*)title subtitle:(NSString*)subtitle
{
    mapView_ = [[MKMapView alloc] initWithFrame:[GUJUtil frameOfKeyWindow]];
    GUJGenericAnnotation *annotation = [[GUJGenericAnnotation alloc] init];
    annotation.coordinate = region.center;
    if( title ) {
        annotation.title      = title;
    }
    if( subtitle ) {
        annotation.subtitle   = subtitle;
    }
    [mapView_ addAnnotation:(id)annotation];
    [mapView_ setCenterCoordinate:region.center animated:YES];
    [mapView_ setRegion:region animated:YES];
    [self performSelectorOnMainThread:@selector(__showMapViewOnRootViewController) withObject:nil waitUntilDone:NO];        
}

- (void)mapViewForAnnotation:(id<MKAnnotation>)annotation region:(MKCoordinateRegion)region
{
    mapView_ = [[MKMapView alloc] initWithFrame:[GUJUtil frameOfKeyWindow]];
    [mapView_ setRegion:region animated:YES];
    [mapView_ addAnnotation:(id)annotation];        
    [self performSelectorOnMainThread:@selector(__showMapViewOnRootViewController) withObject:nil waitUntilDone:NO];  
}

#pragma mark map view delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *annotationView = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"GUJAdViewMap.pin";
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( annotationView == nil ) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        }
        annotationView.pinColor = MKPinAnnotationColorRed;
        /*
         * custom code:
         * implement call-outs and listeners
         *
         pinView.canShowCallout = YES;
         pinView.animatesDrop = YES;
         [CODE FOR CALL OUT]
         *
         */       
        
    }
    else {
        [mapView.userLocation setTitle:@"Current Location"];
    }
    return annotationView;
}
@end
