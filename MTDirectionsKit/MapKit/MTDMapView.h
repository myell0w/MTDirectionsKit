//
//  MTDMapView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"
#import "MTDDirectionsDisplayType.h"
#import "MTDDirectionsDefines.h"
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
@interface MTDMapView : MKMapView

/******************************************
 @name Delegate
 ******************************************/

/** The receiver's directionsDelegate */
@property (nonatomic, mtd_weak) id<MTDDirectionsDelegate> directionsDelegate;

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
 active directionsOverlay and the mapView already requested an an instance of MKOverlayView
 for the specified directionsOverlay.
 */
@property (nonatomic, strong, readonly) MTDDirectionsOverlayView *directionsOverlayView;

/** 
 The current display type of the directions overlay. You can change the way the directions
 are shown on top of your instance of MTDMapView by changing the property. A change results
 in a re-draw of the overlay.
 
 Currently there are the following types supported:
 
 - MTDDirectionsDisplayTypeNone: don't display anything
 - MTDDirectionsDisplayTypeOverview: displays a polyline with all Waypoints of the route
 */
@property (nonatomic, assign) MTDDirectionsDisplayType directionsDisplayType;

/** the starting coordinate of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;

/** the total distance of the directions of the currenty displayed overlay in meters */
@property (nonatomic, readonly) CLLocationDistance distanceInMeter;
/** the total estimated time of the directions */
@property (nonatomic, readonly) NSTimeInterval timeInSeconds;

/** 
 The type of travelling used to compute the directions of the currently displayed overlay 
 
 The following types of travelling are supported:
 
 - MTDDirectionsRouteTypeFastestDriving
 - MTDDirectionsRouteTypeShortestDriving
 - MTDDirectionsRouteTypePedestrian
 - MTDDirectionsRouteTypePedestrianIncludingPublicTransport
 - MTDDirectionsRouteTypeBicycle
 */
@property (nonatomic, readonly) MTDDirectionsRouteType routeType;

/**
 The padding that will be used when zooming the map to the displayed directions.
 If not specified, a default padding of UIEdgeInsetsMake(40.f, 15.f, 15.f, 15.f) will be used.
 */
@property (nonatomic, assign) UIEdgeInsets directionsEdgePadding;

/**
 Starts a request and loads the directions between the specified coordinates.
 When the request is finished the directionsOverlay gets set on the MapView and
 the region gets zoomed (animated) to show the whole overlay, if the flag zoomToShowDirections is set.
 
 @param fromCoordinate the start point of the direction
 @param toCoordinate the end point of the direction
 @param routeType the type of the route requested, e.g. pedestrian, cycling, fastest driving
 @param zoomToShowDirections flag whether the mapView gets zoomed to show the overlay (gets zoomed animated)
 
 @see loadDirectionsFromAddress:toAddress:routeType:zoomToShowDirections:
 @see loadDirectionsFrom:to:intermediateGoals:optimizeRoute:routeType:zoomToShowDirections:
 @see loadAlternativeDirectionsFrom:to:routeType:zoomToShowDirections:
 @see cancelLoadOfDirections
 */
- (void)loadDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
                        to:(CLLocationCoordinate2D)toCoordinate
                 routeType:(MTDDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections;

/**
 Starts a request and loads the directions between the specified addresses.
 When the request is finished the directionsOverlay gets set on the MapView and
 the region gets zoomed (animated) to show the whole overlay, if the flag zoomToShowDirections is set.
 
 @param fromAddress the address of the starting point of the route
 @param toAddress the addresss of the end point of the route
 @param routeType the type of the route requested, e.g. pedestrian, cycling, fastest driving
 @param zoomToShowDirections flag whether the mapView gets zoomed to show the overlay (gets zoomed animated)
 
 @see loadDirectionsFrom:to:routeType:zoomToShowDirections:
 @see loadDirectionsFrom:to:intermediateGoals:optimizeRoute:routeType:zoomToShowDirections:
 @see loadAlternativeDirectionsFrom:to:routeType:zoomToShowDirections:
 @see cancelLoadOfDirections
 */
- (void)loadDirectionsFromAddress:(NSString *)fromAddress
                        toAddress:(NSString *)toAddress
                        routeType:(MTDDirectionsRouteType)routeType
             zoomToShowDirections:(BOOL)zoomToShowDirections;

/**
 Starts a request and loads the directions between the specified start and end waypoints while 
 travelling to all intermediate goals along the route. When the request is finished the
 directionsOverlay gets set on the MapView and the region gets zoomed (animated) to show the
 whole overlay, if the flag zoomToShowDirections is set.
 
 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param intermediateGoals an optional array of waypoint we want to travel to along the route
 @param optimizeRoute a flag that indicates whether the route shall get optimized if there are intermediate goals.
 if YES, the intermediate goals can get reordered to guarantee a fast route traversal
 @param routeType the type of the route requested, e.g. pedestrian, cycling, fastest driving
 @param zoomToShowDirections flag whether the mapView gets zoomed to show the overlay (gets zoomed animated)
 
 @see loadDirectionsFrom:to:routeType:zoomToShowDirections:
 @see loadDirectionsFromAddress:toAddress:routeType:zoomToShowDirections:
 @see loadAlternativeDirectionsFrom:to:routeType:zoomToShowDirections:
 @see cancelLoadOfDirections
 */
- (void)loadDirectionsFrom:(MTDWaypoint *)from
                        to:(MTDWaypoint *)to
         intermediateGoals:(NSArray *)intermediateGoals
             optimizeRoute:(BOOL)optimizeRoute
                 routeType:(MTDDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections;

/**
 Starts a request and loads maximumNumberOfAlternatives different routes between the
 specified start and end waypoints. When the request is finished the directionsOverlay gets set
 on the MapView and the region gets zoomed (animated) to show the whole overlay, if the flag 
 zoomToShowDirections is set.
 
 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param routeType the type of the route requested, e.g. pedestrian, cycling, fastest driving
 @param zoomToShowDirections flag whether the mapView gets zoomed to show the overlay (gets zoomed animated)
 
 @see loadDirectionsFrom:to:routeType:zoomToShowDirections:
 @see loadDirectionsFromAddress:toAddress:routeType:zoomToShowDirections:
 @see loadDirectionsFrom:to:intermediateGoals:optimizeRoute:routeType:zoomToShowDirections:
 @see cancelLoadOfDirections
 */
- (void)loadAlternativeDirectionsFrom:(MTDWaypoint *)from
                                   to:(MTDWaypoint *)to
                            routeType:(MTDDirectionsRouteType)routeType
                 zoomToShowDirections:(BOOL)zoomToShowDirections;

/**
 Cancels a possible ongoing request for loading directions.
 Does nothing if there is no request active.
 
 @see loadDirectionsFrom:to:routeType:zoomToShowDirections:
 */
- (void)cancelLoadOfDirections;

/**
 Removes the currenty displayed directionsOverlay view from the MapView,
 if one exists. Does nothing otherwise.
 */
- (void)removeDirectionsOverlay;

/**
 If multiple routes are available, selects the active route.
 The delegate will be called as if the user had changed the active route by tapping on it
 
 @param route the new active route
 */
- (void)activateRoute:(MTDRoute *)route;

/******************************************
 @name Inter-App
 ******************************************/

/**
 If directionsOverlay is currently set, this method opens the same directions
 that are currently displayed on top of your MTDMapView in the built-in Maps.app
 of the user's device. Does nothing otherwise.
 
 @return YES in case the directionsOverlay is currently set and the Maps App was opened, NO otherwise
 */
- (BOOL)openDirectionsInMapsApp;

/******************************************
 @name Region
 ******************************************/

/**
 Sets the region of the MapView to show the whole directionsOverlay at once.
 
 @param animated flag whether the region gets changed animated, or not
 */
- (void)setRegionToShowDirectionsAnimated:(BOOL)animated;

@end
