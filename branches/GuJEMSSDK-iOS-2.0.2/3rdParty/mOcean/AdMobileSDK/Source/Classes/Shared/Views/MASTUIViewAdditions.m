//
//  UIViewAdditions.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 3/9/11.
//

#import "MASTUIViewAdditions.h"

void useCatagory8(){
    NSLog(@"do nothing, just for make catagory linked");
}

CGContextRef CreateARGBBitmapContext (size_t pixelsWide, size_t pixelsHigh) {
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
        return nil;
    
    bitmapData = malloc( bitmapByteCount );
    memset(bitmapData, 0, bitmapByteCount );
    
    if (bitmapData == NULL) 
    {
        CGColorSpaceRelease( colorSpace );
        return nil;
    }
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@implementation UIView (UIView_mOcean)

- (BOOL) isViewVisible {
	BOOL result = NO;
	
	if (!self.hidden && self.window) {
		result = YES;
	}
	
	return result;
}

- (UIImageView*)takeSnapshot {
	@synchronized (self) {
		UIGraphicsBeginImageContext(self.bounds.size);
		[self.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
		return [imageView autorelease];
	}
}

- (UIViewController*)viewControllerForView {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [(UIView*)nextResponder viewControllerForView];
    } else {
        return nil;
    }
}


- (NSData *)ARGBData {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    size_t w = CGImageGetWidth(image.CGImage);
    size_t h = CGImageGetHeight(image.CGImage);
    
    CGContextRef cgctx = CreateARGBBitmapContext(w, h);
    if (cgctx == NULL) 
        return nil;
    
    CGRect rect = {{0,0},{w,h}}; 
    CGContextDrawImage(cgctx, rect, image.CGImage); 
    
    void *data = CGBitmapContextGetData (cgctx);
    CGContextRelease(cgctx); 
    if (!data)
        return nil;
    
    size_t dataSize = 4 * w * h; // ARGB = 4 8-bit components
    
    NSData *argbData = [NSData dataWithBytes:data length:dataSize];
    free(data);
    
    return argbData;
}

- (BOOL)isPointTransparent:(CGPoint)point rawData:(NSData*)rawData {    
    size_t bpp = 4;
    size_t bpr = self.frame.size.width * 4;
    
    NSUInteger ind = floor(point.x) * bpp + (floor(point.y) * bpr);
    char *rawDataBytes = (char *)[rawData bytes];
    
    return ([rawData length] > ind && rawDataBytes[ind] == 0);
}

- (BOOL)isPointTransparent:(CGPoint)point {
    NSData *rawData = [self ARGBData];  // See about caching this
    if (rawData == nil)
        return NO;
    
    size_t bpp = 4;
    size_t bpr = self.frame.size.width * 4;
    
    NSUInteger ind = point.x * bpp + (point.y * bpr);
    char *rawDataBytes = (char *)[rawData bytes];
    
    return ([rawData length] > ind && rawDataBytes[ind] == 0);
}

@end
