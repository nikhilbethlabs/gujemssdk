//
//  MASTOrmmaHelper.m
//

#import "MASTOrmmaHelper.h"

@implementation MASTOrmmaHelper


+ (NSString*)registerOrmmaUpCaseObject {
    return @"window.Ormma=window.ormma;";
}

+ (NSString*)signalReadyInWebView {
    return @"window.ormma.signalReady();";
}

+ (NSString*)nativeCallComplete:(NSString*)command {
    return [NSString stringWithFormat:@"window.ormmaview.nativeCallComplete('%@');", command];
}

+ (NSString*)setState:(ORMMAState)state {
    if (state == ORMMAStateDefault) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{state: 'default'}", state]];
    } else if (state == ORMMAStateExpanded) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{state: 'expanded'}", state]];
    } else if (state == ORMMAStateHidden) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{state: 'hidden'}", state]];
    } else if (state == ORMMAStateResized) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{state: 'resized'}", state]];
    } else {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{state: 'default'}", state]];
    }
}

+ (NSString*)setViewable:(BOOL)viewable {
    if (viewable) {
        return [MASTOrmmaHelper fireChangeEvent:@"{viewable: true}"];
    } else {
        return [MASTOrmmaHelper fireChangeEvent:@"{viewable: false}"];
    }
}

+ (NSString*)setNetwork:(MASTNetworkStatus)status {
    NSString* network = nil;
    switch (status) {
		case ReachableViaWWAN:
			network = @"cell";
            break;
		case ReachableViaWiFi:
			network = @"wifi";
            break;
        default:
			network = @"offline";
            break;
	}
    if (network) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{network: '%@'}", network]];
    } else {
        return @"";
    }
}

+ (NSString*)setSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{size: { width: %f, height: %f }}", size.width, size.height]];
}

+ (NSString*)setMaxSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{maxSize: { width: %f, height: %f }}", size.width, size.height]];
}

+ (NSString*)setScreenSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{screenSize: { width: %f, height: %f }}", size.width, size.height]];
}

+ (NSString*)setDefaultPosition:(CGRect)frame {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{defaultPosition: { x: %f, y: %f, width: %f, height: %f }}", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height]];
}

+ (NSString*)setPlacementInterstitial:(BOOL)interstitial {
    if (interstitial) {
        return [MASTOrmmaHelper fireChangeEvent:@"{placementType: 'interstitial'}"];
    } else {
        return [MASTOrmmaHelper fireChangeEvent:@"{placementType: 'inline'}"];
    }
}

+ (NSString*)setExpandPropertiesWithMaxSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{expandProperties: { width: %f, height: %f }}", size.width, size.height]];
}

+ (NSString*)setAllExpandPropertiesWithMaxSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{expandProperties: { width: %f, height: %f, useCustomClose: !1, isModal: !1, lockOrientation: !1, useBackground: !1, backgroundColor: \"#ffffff\", backgroundOpacity:1 }}", size.width, size.height]];
}

+ (NSString*)setOrientation:(UIInterfaceOrientation)orientation {
    NSInteger orientationAngle = -1;
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			orientationAngle = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			orientationAngle = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			orientationAngle = 270;
			break;
		case UIInterfaceOrientationLandscapeRight:
			orientationAngle = 90;
			break;
		default:
			orientationAngle = -1;
			break;
	}
    
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{orientation: %i}", orientationAngle]];
}

+ (NSString*)setSupports:(NSArray*)supports {
    NSString* value = [supports componentsJoinedByString:@", "];
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{supports: [%@]}", value]];
}

+ (NSString*)setKeyboardShow:(BOOL)isShow {
    if (isShow) {
        return [MASTOrmmaHelper fireChangeEvent:@"{keyboardState: true}"];
    } else {
        return [MASTOrmmaHelper fireChangeEvent:@"{keyboardState: false}"];
    }
}

+ (NSString*)setTilt:(CMAccelerometerData*)accelerometerData {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{tilt: { x: %f, y: %f, z: %f }}", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z]];
}

+ (NSString*)setHeading:(CGFloat)heading {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{heading: %f }", heading]];
}

+ (NSString*)setLatitude:(CGFloat)latitude longitude:(CGFloat)longitude accuracy:(CGFloat)accuracy {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{location: { lat: %f, lon: %f, acc: %f }}", latitude, longitude, accuracy]];
}

+ (NSString*)fireResponseEvent:(NSString*)response uri:(NSString*)uri {
    return [NSString stringWithFormat:@"window.ormmaview.fireResponseEvent('%@', '%@');", uri, response];
}



+ (NSString*)fireChangeEvent:(NSString*)value {
    return [NSString stringWithFormat:@"window.ormmaview.fireChangeEvent(%@);", value];
}

+ (NSString*)fireShakeEventInWebView {
    return @"window.ormmaview.fireShakeEvent();";
}

+ (NSString*)fireError:(NSString*)message forEvent:(NSString*)event {
    return [NSString stringWithFormat:@"window.ormmaview.fireErrorEvent('%@', '%@');", message, event];
}

+ (CGSize)screenSizeForOrientation:(UIInterfaceOrientation)orientation {
	CGSize size;
	UIScreen *screen = [UIScreen mainScreen];
	CGSize screenSize = screen.bounds.size;	
	if (UIDeviceOrientationIsLandscape(orientation)) {
		// Landscape Orientation, reverse size values
		size.width = screenSize.height;
		size.height = screenSize.width;
	} else {
		// portrait orientation, use normal size values
		size.width = screenSize.width;
		size.height = screenSize.height;
	}
	return size;
}

+ (NSDictionary *)parametersFromJSCall:(NSString *)parameterString {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	NSArray *parameterList = [parameterString componentsSeparatedByString:@"&"];
	for (NSString *parameterEntry in parameterList) {
		NSArray *kvp = [parameterEntry componentsSeparatedByString:@"="];
		NSString *key = [kvp objectAtIndex:0];
		NSString *encodedValue = [kvp objectAtIndex:1];
		NSString *value = [encodedValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
		[parameters setObject:value forKey:key];
	}
	
	return parameters;
}

+ (CGFloat)floatFromDictionary:(NSDictionary*)dictionary
						forKey:(NSString*)key {
	NSString *stringValue = [dictionary valueForKey:key];
	if (stringValue == nil) {
		return 0;
	}
	CGFloat value = [stringValue floatValue];
	return value;
}

+ (NSString*)requiredStringFromDictionary:(NSDictionary*)dictionary
                                   forKey:(NSString *)key {
    NSString *value = [dictionary objectForKey:key];
	if (value == nil || [value isEqual:[NSNull null]]) {
		return nil;
	}
	value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (value.length == 0 || [value isEqual:[NSNull null]] || value == nil) {
		return nil;
	}
	return value;
}

+ (BOOL)booleanFromDictionary:(NSDictionary *)dictionary
					   forKey:(NSString *)key {
	NSString *stringValue = [dictionary valueForKey:key];
	BOOL value = [@"Y" isEqualToString:stringValue] || [@"y" isEqualToString:stringValue] || [@"true" isEqualToString:stringValue];
	return value;
}

@end
