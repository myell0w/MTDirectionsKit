//
//  MTDDirectionOverlay.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


@class MTDDistance;


/**
 An instance of MTDirectionsOverlay implements the MKOverlay protocol and represents 
 an overlay used to store information about already parsed directions with a given
 fromCoordinate and toCoordinate. It stores all waypoint along the route and the total
 distance of the route.
 */
@interface MTDDirectionsOverlay : NSObject <MKOverlay>

/******************************************
 @name Directions
 ******************************************/

/** all waypoints of the route/directions, including fromCoordinate and toCoordinate */
@property (nonatomic, strong, readonly) NSArray *waypoints;
/** the starting coordinate of the directions */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the directions */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;
/** the total distance between fromCoordinate and toCoordinate, when travelled along the given waypoints */
@property (nonatomic, strong, readonly) MTDDistance *distance;
/** the total estimated time for this route */
@property (nonatomic, assign, readonly) NSTimeInterval timeInSeconds;
/** the estimated time as formatted string */
@property (nonatomic, readonly) NSString *formattedTime;
/** the type of travelling used to compute the directions, e.g. walking, by bike etc. */
@property (nonatomic, assign, readonly) MTDDirectionsRouteType routeType;

/** all maneuvers on this route */
@property (nonatomic, strong) NSArray *maneuvers;

/******************************************
 @name MapKit interface
 ******************************************/

/** all mapPoints of the underlying polyline */
@property (nonatomic, readonly) MKMapPoint *points;
/** the number of mapPoints of the polyline */
@property (nonatomic, readonly) NSUInteger pointCount;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 Creates an overlay with the given waypoints, distance and routeType.
 
 @param waypoints the waypoints of the route
 @param distance the total distance from the first to the last waypoint
 @param routeType the type of route computed
 @return an overlay encapsulating the given route-information
 */
+ (MTDDirectionsOverlay *)overlayWithWaypoints:(NSArray *)waypoints 
                                      distance:(MTDDistance *)distance
                                 timeInSeconds:(NSTimeInterval)timeInSeconds
                                     routeType:(MTDDirectionsRouteType)routeType;

@end
