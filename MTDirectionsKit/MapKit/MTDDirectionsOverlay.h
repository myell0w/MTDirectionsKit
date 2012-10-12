//
//  MTDDirectionOverlay.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


@class MTDDistance;
@class MTDAddress;
@class MTDRoute;


/**
 An instance of MTDirectionsOverlay implements the MKOverlay protocol and represents 
 an overlay used to store information about already parsed directions with a given
 fromCoordinate and toCoordinate. It stores all waypoint along the route and the total
 distance of the route.
 */
@interface MTDDirectionsOverlay : NSObject <MKOverlay>

/******************************************
 @name Directions/Routes
 ******************************************/

/** an array of alternative routes for the given start- and endpoint */
@property (nonatomic, copy, readonly) NSArray *routes;
/** the currently active route if there are more alternatives or the only route object if there is only one */
@property (nonatomic, readonly) MTDRoute *activeRoute;
/** the best route of the alternatives according to the API used */
@property (nonatomic, readonly) MTDRoute *bestRoute;
/** the fastest route of the alternatives */
@property (nonatomic, readonly) MTDRoute *fastestRoute;
/** the shortest route of the alternatives  */
@property (nonatomic, readonly) MTDRoute *shortestRoute;
/** The intermediate goals along the route */
@property (nonatomic, copy, readonly) NSArray *intermediateGoals;
/** the type of travelling used to compute the directions, e.g. walking, by bike etc. */
@property (nonatomic, assign, readonly) MTDDirectionsRouteType routeType;

/******************************************
 @name Forwarding to Active Route
 ******************************************/

/** all waypoints of the active route, including fromCoordinate and toCoordinate */
@property (nonatomic, strong, readonly) NSArray *waypoints;
/** the starting coordinate of the active route */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the active route */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;
/** The address of the starting coordinat of the active route */
@property (nonatomic, readonly) MTDAddress *fromAddress;
/** The address of the end coordinate of the active route */
@property (nonatomic, readonly) MTDAddress *toAddress;
/** the total distance between fromCoordinate and toCoordinate of the active route, when travelled along the given waypoints */
@property (nonatomic, strong, readonly) MTDDistance *distance;
/** the total estimated time for the active route */
@property (nonatomic, assign, readonly) NSTimeInterval timeInSeconds;
/** the estimated time of the active route as formatted string */
@property (nonatomic, readonly) NSString *formattedTime;
/** all maneuvers of the active route */
@property (nonatomic, strong) NSArray *maneuvers;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 Creates an overlay with the given routes, distance and routeType.
 
 @param routes the waypoints of the route
 @param intermediateGoals the intermediate goals along the route, can be nil
 @param routeType the type of route computed
 
 @return an overlay encapsulating the given route-information
 */
- (id)initWithRoutes:(NSArray *)routes
   intermediateGoals:(NSArray *)intermediateGoals
           routeType:(MTDDirectionsRouteType)routeType;

/******************************************
 @name Forwarding to Active Route
 ******************************************/

/**
 The estimated time of the active route as formatted string with a specified time format.
 
 @param format the format of the time, e.g. H:mm:ss
 @return a string-representation of the estimated time with the given format
 */
- (NSString *)formattedTimeWithFormat:(NSString *)format;

@end
