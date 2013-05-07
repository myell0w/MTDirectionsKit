//
//  MTDMapView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDMapViewProtocol.h"
#import "MTDDirectionsRouteType.h"
#import "MTDDirectionsDefines.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDWeak.h"


@class MTDDistance;
@class MTDWaypoint;
@class MTDDirectionsOverlay;
@class MTDDirectionsOverlayView;
@class MTDRoute;
@protocol MTDDirectionsDelegate;


/**
 An MTDMapView instance provides functionality to show directions directly on top of the MapView inside your App.
 MTDMapView is a subclass of MKMapView and therefore uses Apple's standard way of displaying map data, which we all
 know and love. Up until iOS 5 this means that Google Maps is used as a backend for the map data, starting with iOS 6
 Apple Maps are used.
 
 Sample usage:
 
 MTDMapView *_mapView = [[MTDMapView alloc] initWithFrame:self.view.bounds];
 _mapView.directionsDelegate = self;
 
 [_mapView loadDirectionsFrom:CLLocationCoordinate2DMake(51.38713, -1.0316)
                           to:CLLocationCoordinate2DMake(51.4554, -0.9742)
                    routeType:MTDDirectionsRouteTypeFastestDriving
         zoomToShowDirections:YES];
 
 */
@interface MTDMapView : MKMapView <MTDMapView>

/******************************************
 @name Delegate
 ******************************************/

/** The receiver's directionsDelegate */
@property (nonatomic, mtd_weak) id<MTDDirectionsDelegate> directionsDelegate;

/******************************************
 @name Directions
 ******************************************/

/** 
 The current active direction overlay view. This property is only set, if there is a current
 active directionsOverlay and the mapView already requested an an instance of MKOverlayView
 for the specified directionsOverlay.
 */
@property (nonatomic, strong, readonly) MTDDirectionsOverlayView *directionsOverlayView;

/** the starting coordinate of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;

/**
 The padding that will be used when zooming the map to the displayed directions.
 If not specified, a default padding of UIEdgeInsetsMake(40.f, 15.f, 15.f, 15.f) will be used.
 */
@property (nonatomic, assign) UIEdgeInsets directionsEdgePadding;

@end
