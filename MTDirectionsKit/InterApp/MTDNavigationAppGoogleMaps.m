#import "MTDNavigationAppGoogleMaps.h"
#import "MTDWaypoint.h"


#define kMTDURLScheme           @"comgooglemaps://"


@implementation MTDNavigationAppGoogleMaps

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDNavigationApp
////////////////////////////////////////////////////////////////////////

+ (BOOL)isAppInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kMTDURLScheme]];
}

// comgooglemaps://?saddr=Google+Inc,+8th+Avenue,+New+York,+NY&daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York&directionsmode=transit
+ (BOOL)openDirectionsFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to routeType:(MTDDirectionsRouteType)routeType {
    if ((from.hasValidCoordinate || from == [MTDWaypoint waypointForCurrentLocation]) &&
        (to.hasValidCoordinate || to == [MTDWaypoint waypointForCurrentLocation])) {
        NSString *googleMapsURL = kMTDURLScheme @"?";

        // if we don't specify from or to, the current location is used
        if (from != [MTDWaypoint waypointForCurrentLocation]) {
            googleMapsURL = [googleMapsURL stringByAppendingFormat:@"saddr=%f,%f", from.coordinate.latitude,from.coordinate.longitude];
        }
        
        if (to != [MTDWaypoint waypointForCurrentLocation]) {
            googleMapsURL = [googleMapsURL stringByAppendingFormat:@"daddr=%f,%f", to.coordinate.latitude,to.coordinate.longitude];
        } 

        switch (routeType) {
            case MTDDirectionsRouteTypePedestrian:
            case MTDDirectionsRouteTypeBicycle: {
                googleMapsURL = [googleMapsURL stringByAppendingString:@"&directionsmode=walking"];
                break;
            }

            case MTDDirectionsRouteTypePedestrianIncludingPublicTransport: {
                googleMapsURL = [googleMapsURL stringByAppendingString:@"&directionsmode=transit"];
                break;
            }

            case MTDDirectionsRouteTypeFastestDriving:
            case MTDDirectionsRouteTypeShortestDriving:
            default: {
                googleMapsURL = [googleMapsURL stringByAppendingString:@"&directionsmode=driving"];
                break;
            }
        }

        return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURL]];
    }

    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDNavigationAppGoogleMaps
////////////////////////////////////////////////////////////////////////

+ (BOOL)openWebsiteDirectionsFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to routeType:(MTDDirectionsRouteType)routeType {
    NSString *googleMapsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
                               from.coordinate.latitude,from.coordinate.longitude,
                               to.coordinate.latitude, to.coordinate.longitude];

    switch (routeType) {
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

    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURL]];
}

@end
