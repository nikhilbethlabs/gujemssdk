//
//  OrmmaHelper.m
//  AdMobileSDK
//
//  Created by Constantine Mureev on 8/29/11.
//

#import "MASTOrmmaHelper.h"
#import "MASTOrmmaConstants.h"

@implementation MASTOrmmaHelper


+ (NSString*)registerOrmmaUpCaseObject {
    return ORMMA_REGISTER_UP_CASE_OBJECT;
}

+ (NSString*)signalReadyInWebView {
    return ORMMA_SIGNAL_READY_FOR_WEBVIEW;
}

+ (NSString*)nativeCallComplete:(NSString*)command {
    return [NSString stringWithFormat:@"%@('%@');", ORMMA_WINDOW_NATIVE_CALL_COMPLETE, command];
}

+ (NSString*)setState:(ORMMAState)state {
    if (state == ORMMAStateDefault) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:ORMMA_EVENT_DEFAULT_STATE, state]];
    } else if (state == ORMMAStateExpanded) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:ORMMA_EVENT_EXPAND_STATE, state]];
    } else if (state == ORMMAStateHidden) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:ORMMA_EVENT_HIDDEN_STATE, state]];
    } else if (state == ORMMAStateResized) {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:ORMMA_EVENT_RESIZE_STATE, state]];
    } else {
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:ORMMA_EVENT_DEFAULT_STATE, state]];
    }
}

+ (NSString*)setViewable:(BOOL)viewable {
    if (viewable) {
        return [MASTOrmmaHelper fireChangeEvent:ORMMA_EVENT_VIEWABLE_TRUE];
    } else {
        return [MASTOrmmaHelper fireChangeEvent:ORMMA_EVENT_VIEWABLE_FALSE];
    }
}

+ (NSString*)setNetwork:(NetworkStatus)status {
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
        return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ '%@'}", ORMMA_EVENT_NETWORK, network]];
    } else {
        return @"";
    }
}

+ (NSString*)setSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ { width: %f, height: %f }}", ORMMA_EVENT_SIZE, size.width, size.height]];
}

+ (NSString*)setMaxSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ { width: %f, height: %f }}", ORMMA_EVENT_MAX_SIZE, size.width, size.height]];
}

+ (NSString*)setScreenSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ { width: %f, height: %f }}", ORMMA_EVENT_SCREEN_SIZE, size.width, size.height]];
}

+ (NSString*)setDefaultPosition:(CGRect)frame {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ { x: %f, y: %f, width: %f, height: %f }}", ORMMA_EVENT_DEFAULT_POSITION, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height]];
}

+ (NSString*)setPlacementInterstitial:(BOOL)interstitial {
    if (interstitial) {
        return [MASTOrmmaHelper fireChangeEvent:ORMMA_EVENT_PLACEMENT_TYPE_INTERSTITIAL];
    } else {
        return [MASTOrmmaHelper fireChangeEvent:ORMMA_EVENT_PLACEMENT_TYPE_INLINE];
    }
}

+ (NSString*)setExpandPropertiesWithMaxSize:(CGSize)size {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ { width: %f, height: %f, useCustomClose: !1, isModal: !1, lockOrientation: !1, useBackground: !1, backgroundColor: \"#ffffff\", backgroundOpacity:1 }}", ORMMA_EVENT_EXPAND_PROPERTIES, size.width, size.height]];
}

+ (NSString*)setOrientation:(UIDeviceOrientation)orientation {
    NSInteger orientationAngle = -1;
	switch (orientation) {
		case UIDeviceOrientationPortrait:
			orientationAngle = 0;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			orientationAngle = 180;
			break;
		case UIDeviceOrientationLandscapeLeft:
			orientationAngle = 270;
			break;
		case UIDeviceOrientationLandscapeRight:
			orientationAngle = 90;
			break;
		default:
			orientationAngle = -1;
			break;
	}
    
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ %i}", ORMMA_EVENT_ORIENTATION, orientationAngle]];
}

+ (NSString*)setSupports:(NSArray*)supports {
    NSString* value = [supports componentsJoinedByString:@", "];
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ [%@]}", ORMMA_EVENT_SUPPORTS, value]];
}

+ (NSString*)setKeyboardShow:(BOOL)isShow {
    if (isShow) {
        return [MASTOrmmaHelper fireChangeEvent:ORMMA_EVENT_KEYBOARD_STATE_TRUE];
    } else {
        return [MASTOrmmaHelper fireChangeEvent:ORMMA_EVENT_KEYBOARD_STATE_FALSE];
    }
}

+ (NSString*)setTilt:(UIAcceleration*)acceleration {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ { x: %f, y: %f, z: %f }}", ORMMA_EVENT_TILT, acceleration.x, acceleration.y, acceleration.z]];
}

+ (NSString*)setHeading:(CGFloat)heading {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ %f }", ORMMA_EVENT_HEADING, heading]];
}

+ (NSString*)setLatitude:(CGFloat)latitude longitude:(CGFloat)longitude accuracy:(CGFloat)accuracy {
    return [MASTOrmmaHelper fireChangeEvent:[NSString stringWithFormat:@"{%@ { lat: %f, lon: %f, acc: %f }}", ORMMA_EVENT_LOCATION, latitude, longitude, accuracy]];
}

+ (NSString*)fireResponseEvent:(NSData*)data uri:(NSString*)uri {
    return [NSString stringWithFormat:@"%@('%@', '%@');", ORMMA_WINDOW_FIRE_RESPONSE_EVENT, uri, [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
}



+ (NSString*)fireChangeEvent:(NSString*)value {
    return [NSString stringWithFormat:@"%@(%@);", ORMMA_WINDOW_FIRE_CHANGE_EVENT, value];
}

+ (NSString*)fireShakeEventInWebView {
    return ORMMA_WINDOW_FIRE_SHAKE_EVENT;
}

+ (NSString*)fireError:(NSString*)message forEvent:(NSString*)event {
    return [NSString stringWithFormat:@"%@('%@', '%@');", ORMMA_WINDOW_FIRE_ERROR_EVENT, message, event];
}

+ (CGSize)screenSizeForOrientation:(UIDeviceOrientation)orientation {
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
