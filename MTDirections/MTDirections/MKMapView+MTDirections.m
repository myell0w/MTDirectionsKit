#import "MKMapView+MTDirections.h"
#import "MTWaypoint.h"
#import "MTManeuver.h"
#import "MTDirectionsRequest.h"
#import "MTDirectionsOverlay.h"
#import "MTDirectionsOverlayView.h"
#import <objc/runtime.h>

static char overlayKey;
static char requestKey;

@interface MKMapView ()

@property (nonatomic, strong, setter = mt_setRequest:) MTDirectionsRequest *mt_request;

@end

@implementation MKMapView (MTDirections)

////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapView+MTDirections
////////////////////////////////////////////////////////////////////////

- (void)setRegionToShowDirectionsAnimated:(BOOL)animated {
    NSArray *waypoints = self.directionsOverlay.waypoints;
    
    if (waypoints != nil) {
        CLLocationDegrees maxLat = -90.0f;
        CLLocationDegrees maxLon = -180.0f;
        CLLocationDegrees minLat = 90.0f;
        CLLocationDegrees minLon = 180.0f;
        MKCoordinateRegion region;
        
        for (NSUInteger i=0; i<waypoints.count; i++) {
            MTWaypoint *currentLocation = [waypoints objectAtIndex:i];
            
            if (currentLocation.coordinate.latitude > maxLat) {
                maxLat = currentLocation.coordinate.latitude;
            }
            if (currentLocation.coordinate.latitude < minLat) {
                minLat = currentLocation.coordinate.latitude;
            }
            if (currentLocation.coordinate.longitude > maxLon) {
                maxLon = currentLocation.coordinate.longitude;
            }
            if (currentLocation.coordinate.longitude < minLon) {
                minLon = currentLocation.coordinate.longitude;
            }
        }
        
        region.center.latitude     = (maxLat + minLat) / 2;
        region.center.longitude    = (maxLon + minLon) / 2;
        region.span.latitudeDelta  = maxLat - minLat;
        region.span.longitudeDelta = maxLon - minLon;
        
        [self setRegion:region animated:animated];
    }
}

- (MKOverlayView *)viewForDirectionsOverlay:(id<MKOverlay>)overlay {
    MTDirectionsOverlay *directionsOverlay = self.directionsOverlay;
    
    if (![overlay isKindOfClass:[MTDirectionsOverlay class]] || directionsOverlay == nil) {
        return nil;
    }
    
    MTDirectionsOverlayView *overlayView = [[MTDirectionsOverlayView alloc] initWithOverlay:directionsOverlay];
	
    return overlayView;
}

- (void)loadDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
                        to:(CLLocationCoordinate2D)toCoordinate
                 routeType:(MTDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections {
    __unsafe_unretained MKMapView *blockSelf = self;
    
    [self.mt_request cancel];
    self.mt_request = [MTDirectionsRequest requestFrom:fromCoordinate
                                                    to:toCoordinate
                                             routeType:routeType
                                            completion:^(MTDirectionsOverlay *overlay) {
                                                blockSelf.directionsOverlay = overlay;
                                                
                                                // If we found at least one waypoint (start and end are always contained)
                                                // zoom the mapView to show the whole direction
                                                if (zoomToShowDirections && overlay.waypoints.count > 2) {
                                                    [blockSelf setRegionToShowDirectionsAnimated:YES];
                                                }
                                            }];
    
    [self.mt_request start];
}

- (void)cancelLoadOfDirections {
    [self.mt_request cancel];
    self.mt_request = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
////////////////////////////////////////////////////////////////////////

- (void)setDirectionsOverlay:(MTDirectionsOverlay *)directionsOverlay {
    MTDirectionsOverlay *overlay = self.directionsOverlay;
    
    // remove old overlay and annotations
    if (overlay != nil) {
        [self removeAnnotations:overlay.maneuvers];
        [self removeOverlay:overlay];
    }
    
    // add new overlay
    if (directionsOverlay != nil) {
        [self addOverlay:directionsOverlay];
        [self addAnnotations:directionsOverlay.maneuvers];
    }
    
    objc_setAssociatedObject(self, &overlayKey, directionsOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MTDirectionsOverlay *)directionsOverlay {
    return objc_getAssociatedObject(self, &overlayKey);
}

- (void)mt_setRequest:(MTDirectionsRequest *)mt_request {
    objc_setAssociatedObject(self, &requestKey, mt_request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MTDirectionsRequest *)mt_request {
    return objc_getAssociatedObject(self, &requestKey);
}

@end
