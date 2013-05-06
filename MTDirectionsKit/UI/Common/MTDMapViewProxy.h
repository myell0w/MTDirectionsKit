//
//  MTDMapViewDelegateProxy.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"
#import "MTDDirectionsRequestOption.h"


@protocol MTDMapView;
@protocol MTDDirectionsDelegate;
@class MTDWaypoint;
@class MTDDirectionsOverlay;
@class MTDRoute;


/**
 Since we subclass MKMapView we don't want to interfere with it's delegate-behaviour. MKMapView is known
 to at least respond to the protocol UIGestureRecognizerDelegate (not public), so we use an instance of
 MTDMapViewProxy as our delegate. 
 
 Furthermore this class implements common functionality that is used in MTDMapView as well as MTDGMSMapView.
 */
@interface MTDMapViewProxy : NSObject <UIGestureRecognizerDelegate, CLLocationManagerDelegate>

/******************************************
 @name Directions
 ******************************************/

/** The MapView to call back */
@property (nonatomic, mtd_weak) id<MTDMapView> mapView;

/** The receiver's directionsDelegate */
@property (nonatomic, mtd_weak) id<MTDDirectionsDelegate> directionsDelegate;

/**
 Creates an instance of the delegate proxy that doesn‘t retain the mapView to not create a retain cycle.
 
 @param mapView the mapView to call back
 @return an instance of MTDMapViewDelegateProxy
 */
- (id)initWithMapView:(id<MTDMapView>)mapView;

/**
 Starts a request and loads the directions between the specified start and end waypoints while
 travelling to all intermediate goals along the route. When the request is finished the
 directionsOverlay gets set on the MapView and the region gets zoomed (animated) to show the
 whole overlay, if the flag zoomToShowDirections is set.

 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param intermediateGoals an optional array of waypoint we want to travel to along the route
 @param routeType the type of the route requested, e.g. pedestrian, cycling, fastest driving
 @param options mask of options that can be specified on the request, e.g. optimization of the route, avoiding toll roads etc.
 @param zoomToShowDirections flag whether the mapView gets zoomed to show the overlay (gets zoomed animated)

 @see loadDirectionsFrom:to:routeType:zoomToShowDirections:
 @see loadDirectionsFromAddress:toAddress:routeType:zoomToShowDirections:
 @see loadAlternativeDirectionsFrom:to:routeType:zoomToShowDirections:
 @see cancelLoadOfDirections
 */
- (void)loadDirectionsFrom:(MTDWaypoint *)from
                        to:(MTDWaypoint *)to
         intermediateGoals:(NSArray *)intermediateGoals
                 routeType:(MTDDirectionsRouteType)routeType
                   options:(MTDDirectionsRequestOptions)options
      zoomToShowDirections:(BOOL)zoomToShowDirections;

/**
 Cancels a possible ongoing request for loading directions.
 Does nothing if there is no request active.

 @see loadDirectionsFrom:to:routeType:zoomToShowDirections:
 */

- (void)cancelLoadOfDirections;

/******************************************
 @name Location handling
 ******************************************/

- (void)startUpdatingLocationWithCompletion:(dispatch_block_t)completion;
- (void)stopUpdatingLocationCallingCompletion:(BOOL)callingCompletion;

/******************************************
 @name Delegation
 ******************************************/

- (void)notifyDelegateWillStartLoadingDirectionsFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to routeType:(MTDDirectionsRouteType)routeType;
- (MTDDirectionsOverlay *)notifyDelegateDidFinishLoadingOverlay:(MTDDirectionsOverlay *)overlay;
- (void)notifyDelegateDidFailLoadingOverlayWithError:(NSError *)error;
- (BOOL)askDelegateForSelectionEnabledStateOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay;
- (void)notifyDelegateDidActivateRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay;
- (UIColor *)askDelegateForColorOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay;
- (CGFloat)askDelegateForLineWidthFactorOfOverlay:(MTDDirectionsOverlay *)overlay;
- (void)notifyDelegateDidUpdateUserLocation:(CLLocation *)location;

@end
