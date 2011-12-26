//
//  MKMapView+MTDirections.m
//  WhereTU
//
//  Created by Tretter Matthias on 25.12.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "MKMapView+MTDirections.h"
#import "MTWaypoint.h"
#import "MTDirectionRequest.h"
#import <objc/runtime.h>

#define kMTDirectionDefaultColor    [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f]

static char waypointsKey;
static char overlayKey;
static char colorKey;

@implementation MKMapView (MTDirections)

////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapView+MTDirections
////////////////////////////////////////////////////////////////////////

- (void)zoomToShowRouteAnimated:(BOOL)animated {
    NSArray *waypoints = self.waypoints;
    CLLocationDegrees maxLat = -90.0f;
	CLLocationDegrees maxLon = -180.0f;
	CLLocationDegrees minLat = 90.0f;
	CLLocationDegrees minLon = 180.0f;
	
	for (int i = 0; i < waypoints.count; i++) {
		MTWaypoint *currentLocation = [waypoints objectAtIndex:i];
		if(currentLocation.coordinate.latitude > maxLat) {
			maxLat = currentLocation.coordinate.latitude;
		}
		if(currentLocation.coordinate.latitude < minLat) {
			minLat = currentLocation.coordinate.latitude;
		}
		if(currentLocation.coordinate.longitude > maxLon) {
			maxLon = currentLocation.coordinate.longitude;
		}
		if(currentLocation.coordinate.longitude < minLon) {
			minLon = currentLocation.coordinate.longitude;
		}
	}
	
	MKCoordinateRegion region;
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[self setRegion:region animated:animated];
}

- (MKOverlayView *)viewForDirectionsOverlay:(id<MKOverlay>)overlay {
    MKPolyline *routeOverlay = self.routeOverlay;
    
    if (routeOverlay == nil) {
        return nil;
    }
    
	MKPolylineView *routeLineView = [[MKPolylineView alloc] initWithPolyline:routeOverlay];
    
	routeLineView.fillColor = self.routeOverlayColor;
	routeLineView.strokeColor = self.routeOverlayColor;
	routeLineView.lineWidth = 4;
	
    return routeLineView;
}

- (void)loadRouteFrom:(CLLocationCoordinate2D)fromCoordinate
                   to:(CLLocationCoordinate2D)toCoordinate
      zoomToShowRoute:(BOOL)zoomToShowRoute {
    __unsafe_unretained MKMapView *blockSelf = self;
    
    MTDirectionRequest *request = [[MTDirectionRequest alloc] initFrom:fromCoordinate
                                                                    to:toCoordinate
                                                            completion:^(NSArray *waypoints) {
                                                                blockSelf.waypoints = waypoints; 
                                                                
                                                                if (zoomToShowRoute) {
                                                                    [blockSelf zoomToShowRouteAnimated:YES];
                                                                }
                                                            }];
    
    [request start];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
////////////////////////////////////////////////////////////////////////

- (void)setWaypoints:(NSArray *)waypoints {
    MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * waypoints.count);

	for (NSUInteger i = 0; i < waypoints.count; i++) {
		MTWaypoint *waypoint = [waypoints objectAtIndex:i];
		MKMapPoint point = MKMapPointForCoordinate(waypoint.coordinate);
        
		points[i] = point;
	}
	
	self.routeOverlay = [MKPolyline polylineWithPoints:points count:waypoints.count];
    free(points);
    
    objc_setAssociatedObject(self, &waypointsKey, waypoints, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)waypoints {
    return objc_getAssociatedObject(self, &waypointsKey);
}

- (void)setRouteOverlay:(MKPolyline *)routeOverlay {
    MKPolyline *overlay = self.routeOverlay;
    
    // remove old overlay
	if (overlay != nil) {
		[self removeOverlay:overlay];
	}
    
    // add new overlay
    if (routeOverlay != nil) {
        [self addOverlay:routeOverlay];
    }
    
    objc_setAssociatedObject(self, &overlayKey, routeOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MKPolyline *)routeOverlay {
    return objc_getAssociatedObject(self, &overlayKey);
}

- (void)setRouteOverlayColor:(UIColor *)color {
    objc_setAssociatedObject(self, &colorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)routeOverlayColor {
    UIColor *color = (UIColor *)objc_getAssociatedObject(self, &colorKey);
    
    if (color == nil) {
        self.routeOverlayColor = kMTDirectionDefaultColor;
        return kMTDirectionDefaultColor;
    }
    
    return color;
}

@end
