#import "MKMapView+MTDirections.h"
#import "MTWaypoint.h"
#import "MTDirectionsRequest.h"
#import "MTDirectionsOverlay.h"
#import "MTDirectionsOverlayView.h"
#import <objc/runtime.h>

#define kMTDirectionsDefaultColor        [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.6f]
#define kMTDirectionsDefaultLineWidth    9.f

static char waypointsKey;
static char overlayKey;
static char colorKey;
static char requestKey;

@interface MKMapView ()

@property (nonatomic, strong, setter = mt_setRequest:) MTDirectionsRequest *mt_request;

@end

@implementation MKMapView (MTDirections)

////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapView+MTDirections
////////////////////////////////////////////////////////////////////////

- (void)setRegionToShowDirectionsAnimated:(BOOL)animated {
    NSArray *waypoints = self.waypoints;
    
    if (self.waypoints != nil) {
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
                                            completion:^(NSArray *waypoints) {
                                                blockSelf.waypoints = waypoints; 
                                                
                                                if (zoomToShowDirections) {
                                                    [blockSelf setRegionToShowDirectionsAnimated:YES];
                                                }
                                            }];
    
    [self.mt_request start];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
////////////////////////////////////////////////////////////////////////

- (void)setWaypoints:(NSArray *)waypoints {
    self.directionsOverlay = [MTDirectionsOverlay overlayWithWaypoints:waypoints];
    objc_setAssociatedObject(self, &waypointsKey, waypoints, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)waypoints {
    return objc_getAssociatedObject(self, &waypointsKey);
}

- (void)setDirectionsOverlay:(MTDirectionsOverlay *)directionsOverlay {
    MTDirectionsOverlay *overlay = self.directionsOverlay;
    
    // remove old overlay
    if (overlay != nil) {
        [self removeOverlay:overlay];
    }
    
    // add new overlay
    if (directionsOverlay != nil) {
        [self addOverlay:directionsOverlay];
    }
    
    objc_setAssociatedObject(self, &overlayKey, directionsOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MTDirectionsOverlay *)directionsOverlay {
    return objc_getAssociatedObject(self, &overlayKey);
}

- (void)setDirectionsOverlayColor:(UIColor *)color {
    objc_setAssociatedObject(self, &colorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)directionsOverlayColor {
    UIColor *color = (UIColor *)objc_getAssociatedObject(self, &colorKey);
    
    if (color == nil) {
        self.directionsOverlayColor = kMTDirectionsDefaultColor;
        return kMTDirectionsDefaultColor;
    }
    
    return color;
}

- (void)mt_setRequest:(MTDirectionsRequest *)mt_request {
    objc_setAssociatedObject(self, &requestKey, mt_request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MTDirectionsRequest *)mt_request {
    return objc_getAssociatedObject(self, &requestKey);
}

@end
