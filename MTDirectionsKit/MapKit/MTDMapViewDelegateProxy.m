#import "MTDMapViewDelegateProxy.h"
#import "MTDMapView.h"
#import "MTDMapView+MTDirectionsPrivateAPI.h"


@implementation MTDMapViewDelegateProxy 

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithMapView:(MTDMapView *)mapView {
    if ((self = [super init])) {
        _mapView = mapView;
        _lastKnownUserCoordinate = kCLLocationCoordinate2DInvalid;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate
////////////////////////////////////////////////////////////////////////

- (void)locationManager:(__unused CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(__unused CLLocation *)oldLocation {
    MTDMapView *mapView = self.mapView;
    
    MTDLogVerbose(@"Location manager found a location for [MTDWaypoint waypointForCurrentLocation]");

    self.lastKnownUserCoordinate = newLocation.coordinate;
    [mapView mtd_stopUpdatingLocationCallingCompletion:YES];
}

- (void)locationManager:(__unused CLLocationManager *)manager didFailWithError:(NSError *)error {
    MTDMapView *mapView = self.mapView;
    
    MTDLogVerbose(@"Location manager failed while finding a location for [MTDWaypoint waypointForCurrentLocation]");

    [mapView mtd_stopUpdatingLocationCallingCompletion:NO];
    [mapView mtd_notifyDelegateDidFailLoadingOverlayWithError:error];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate
////////////////////////////////////////////////////////////////////////

- (BOOL)gestureRecognizer:(__unused UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *otherTapGestureRecognizer = (UITapGestureRecognizer *)otherGestureRecognizer;

        return otherTapGestureRecognizer.numberOfTapsRequired == 1;
    } else {
        return YES;
    }
}

@end
