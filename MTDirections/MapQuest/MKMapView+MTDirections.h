//
//  MKMapView+MTDirections.h
//  WhereTU
//
//  Created by Tretter Matthias on 25.12.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (MTDirections)

@property (nonatomic, strong) NSArray *waypoints;
@property (nonatomic, strong) MKPolyline *routeOverlay;
@property (nonatomic, strong) UIColor *routeOverlayColor;

- (void)zoomToShowRouteAnimated:(BOOL)animated;

- (void)loadRouteFrom:(CLLocationCoordinate2D)fromCoordinate
                   to:(CLLocationCoordinate2D)toCoordinate
      zoomToShowRoute:(BOOL)zoomToShowRoute;

- (MKOverlayView *)viewForDirectionsOverlay:(id<MKOverlay>)overlay;

@end
