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