#import "MTDFunctions.h"


void MTDDirectionsOpenInMapsApp(CLLocationCoordinate2D fromCoordinate, CLLocationCoordinate2D toCoordinate, MTDDirectionsRouteType routeType) {
	NSString *googleMapsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
							   fromCoordinate.latitude,fromCoordinate.longitude, toCoordinate.latitude, toCoordinate.longitude];
    
    switch(routeType) {
        case MTDDirectionsRouteTypePedestrian:
        case MTDDirectionsRouteTypeBicycle: {
            googleMapsURL = [googleMapsURL stringByAppendingString:@"&dirflg=w"];
            break;
        }
            
        case MTDDirectionsRouteTypePedestrianIncludingPublicTransport: {
            googleMapsURL = [googleMapsURL stringByAppendingString:@"&dirflg=r"];
            break;
        }
            
        case MTDDirectionsRouteTypeFastestDriving:
        case MTDDirectionsRouteTypeShortestDriving:
        default: {
            // do nothing
            break;
        }
    }
    
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURL]];
}

NSString* MTDURLEncodedString(NSString *string) {
    NSMutableString *umlautlessString = [NSMutableString stringWithString:string];
    
    // replace umlauts, because they don't work in the MapQuest API
    [umlautlessString replaceOccurrencesOfString:@"ü" withString:@"ue" options:NSCaseInsensitiveSearch range:NSMakeRange(0, umlautlessString.length)];
    [umlautlessString replaceOccurrencesOfString:@"ö" withString:@"oe" options:NSCaseInsensitiveSearch range:NSMakeRange(0, umlautlessString.length)];
    [umlautlessString replaceOccurrencesOfString:@"ä" withString:@"ae" options:NSCaseInsensitiveSearch range:NSMakeRange(0, umlautlessString.length)];
    [umlautlessString replaceOccurrencesOfString:@"ß" withString:@"ss" options:NSCaseInsensitiveSearch range:NSMakeRange(0, umlautlessString.length)];
    
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[umlautlessString description],
                                                                                 NULL,
                                                                                 CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                 kCFStringEncodingUTF8);
}

NSString* MTDGetFormattedTime(NSTimeInterval time) {
    if (time < 0.) {
        return @"0:00";
    }
    
    NSInteger seconds = ((NSInteger)time) % 60;
    NSInteger minutes = time / 60;
    NSInteger hours = minutes / 60;
    minutes = ((NSInteger)minutes) % 60;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
}

NSString* MTDStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate) {
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        return [NSString stringWithFormat:@"(%f,%f)", coordinate.latitude, coordinate.longitude];
    } else {
        return @"Invalid CLLocationCoordinate2D";
    }
}

UIColor* MTDDarkenedColor(UIColor *color, CGFloat difference) {
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
    NSUInteger numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
    
    if (numberOfComponents != 3) {
        return color;
    }
    
    CGFloat alpha = CGColorGetAlpha(color.CGColor);
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    const CGFloat r = components[0];
    const CGFloat g = components[1];
    const CGFloat b = components[2];
    
    return [UIColor colorWithRed:MAX(0, r - difference)
                           green:MAX(0, g - difference)
                            blue:MAX(0, b - difference)
                           alpha:alpha];
}

BOOL MTDDirectionLineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect rect) {
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    
    return MKMapRectIntersectsRect(rect, r2);
}
