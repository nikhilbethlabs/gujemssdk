//
//  TransparentUIView.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 6/28/11.
//  Copyright 2011 AdMobile Mobile. A subsidiary of Mojiva, Inc. All rights reserved.
//

#import "MASTTransparentUIView.h"


@implementation MASTTransparentUIView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self isPointTransparent:point]) {
        return NO;
    }
    
    return [super pointInside:point withEvent:event];
}

@end
