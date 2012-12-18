#import "MTDNavigationAppBuiltInMaps.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"
#import "MTDAddress.h"
#import "MTDNavigationAppGoogleMaps.h"


@implementation MTDNavigationAppBuiltInMaps

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDNavigationApp
////////////////////////////////////////////////////////////////////////

+ (BOOL)isAppInstalled {
    return YES;
}

+ (BOOL)openDirectionsFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to routeType:(MTDDirectionsRouteType)routeType {
    if ((from.hasValidCoordinate || from == [MTDWaypoint waypointForCurrentLocation]) &&
        (to.hasValidCoordinate || to == [MTDWaypoint waypointForCurrentLocation])) {
        if (MTDDirectionsSupportsAppleMaps()) {
            MKMapItem *fromMapItem = nil;
            MKMapItem *toMapItem = nil;

            if (from == [MTDWaypoint waypointForCurrentLocation]) {
                fromMapItem = [MKMapItem mapItemForCurrentLocation];
            } else {
                MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:from.coordinate addressDictionary:from.address.addressDictionary];
                fromMapItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
            }

            if (to == [MTDWaypoint waypointForCurrentLocation]) {
                toMapItem = [MKMapItem mapItemForCurrentLocation];
            } else {
                MKPlacemark *toPlacemark = [[MKPlacemark alloc] initWithCoordinate:to.coordinate addressDictionary:to.address.addressDictionary];
                toMapItem = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
            }

            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey: MTDMKLaunchOptionFromMTDDirectionsRouteType(routeType)};
            return [MKMapItem openMapsWithItems:@[fromMapItem, toMapItem] launchOptions:launchOptions];
        }

        // This URL scheme opens the Google Maps App on iOS 5
        else {
            return [MTDNavigationAppGoogleMaps openWebsiteDirectionsFrom:from to:to routeType:routeType];
        }
    }
    
    return NO;
}

@end
