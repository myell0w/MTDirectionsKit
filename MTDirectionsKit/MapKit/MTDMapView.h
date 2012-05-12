//
//  MTDMapView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"
#import "MTDDirectionsDisplayType.h"


@class MTDDirectionsOverlay;
@class MTDDirectionsOverlayView;


/**
 An MTDMapView instance provides functionality to show directions directly on top of the MapView inside your App.
 MTDMapView is a subclass of MKMapView and therefore uses Google Maps as the data source for the map, which we all
 know and love.
 
    MTDMapView *mapView = [[MTDMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate = self;
 
    [mapView loadDirectionsFrom:CLLocationCoordinate2DMake(51.38713, -1.0316)
                             to:CLLocationCoordinate2DMake(51.4554, -0.9742)
                      routeType:MTDDirectionsRouteTypeFastestDriving
           zoomToShowDirections:YES];
 
 */
@interface MTDMapView : MKMapView

/******************************************
 @name Directions
 ******************************************/

/** 
 The current active direction overlay. Setting the directions overlay automatically removes
 the previous directionsOverlay (if existing) and adds the new directionsOverlay as an overlay
 to the underlying MKMapView.
 */
@property (nonatomic, strong) MTDDirectionsOverlay *directionsOverlay;

/** 
 The current active direction overlay view. This property is only set, if there is a current
 active directionsOverlay.
 */
@property (nonatomic, strong, readonly) MTDDirectionsOverlayView *directionsOverlayView;

/** 
 The current display type of the directions overlay. Currently the overlay can either be hidden
 or shown, depending on this property.
 */
@property (nonatomic, assign) MTDDirectionsDisplayType directionsDisplayType;

/** the starting coordinate of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;
/** the distance of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationDistance distance;
/** the routeType used to compute the directions of the currently displayed overlay */
@property (nonatomic, readonly) MTDDirectionsRouteType routeType;

/**
 Starts a request and loads the directions between the specified coordinates.
 When the request is finished the directionOverlay gets set on the MapView and
 the region gets set to show the overlay, if the flag zoomToShowDirections is set.
 
 @param fromCoordinate the start point of the direction
 @param toCoordinate the end point of the direction
 @param routeType the type of the route request, e.g. pedestrian, cycling, fastest driving
 @param zoomToShowDirections flag whether the mapView gets zoomed to show the overlay (gets zoomed animated)
 @see cancelLoadOfDirections
 */
- (void)loadDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
                        to:(CLLocationCoordinate2D)toCoordinate
                 routeType:(MTDDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections;

/**
 Cancels a possible ongoing request for loading directions.
 Does nothing if there is no request ongoing.
 
  @see loadDirectionsFrom:to:routeType:zoomToShowDirections:
 */
- (void)cancelLoadOfDirections;

/**
 Removes the currenty displayed directionsOverlay view from the MapView, if there exists one.
 Does nothing, if there doesn't exist a directionsOverlay.
 */
- (void)removeDirectionsOverlay;

/******************************************
 @name Inter-App
 ******************************************/

/**
 Opens the currently displayed directions in the built-in Maps.app of the iDevice.
 */
- (void)openDirectionsInMapApp;

/******************************************
 @name Region
 ******************************************/

/**
 Sets the region of the MapView to show the whole directionsOverlay at once.
 
 @param animated flag whether the region gets set animated or not
 */
- (void)setRegionToShowDirectionsAnimated:(BOOL)animated;

/**
 When the MapView is in the mode to show Maneuvers this method shows the next maneuver in detail (if possible).
 
 @return YES if there is a next maneuver to show, NO otherwise
 */
- (BOOL)showNextManeuver;

/**
 When the MapView is in the mode to show Maneuvers this method shows the previous maneuver in detail (if possible).
 
 @return YES if there is a previous maneuver to show, NO otherwise
 */
- (BOOL)showPreviousManeuver;


@end
