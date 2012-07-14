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
 @name Directions Overlay
 ******************************************/

/** an array of alternative routes for the given start- and endpoint */
@property (nonatomic, copy, readonly) NSArray *routes;
/** the currently active route if there are more alternatives or the only route object, if there is only one */
@property (nonatomic, readonly) MTDRoute *activeRoute;
/** The intermediate goals along the route */
@property (nonatomic, copy, readonly) NSArray *intermediateGoals;
/** the type of travelling used to compute the directions, e.g. walking, by bike etc. */
@property (nonatomic, assign, readonly) MTDDirectionsRouteType routeType;

/******************************************
 @name Routes
 ******************************************/

/** all waypoints of the route/directions, including fromCoordinate and toCoordinate */
@property (nonatomic, strong, readonly) NSArray *waypoints;
/** the starting coordinate of the directions */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the directions */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;
/** The address of the starting coordinate, can be nil if not provided by API */
@property (nonatomic, readonly) MTDAddress *fromAddress;
/** The address of the end coordinate, can be nil if not provided by API */
@property (nonatomic, readonly) MTDAddress *toAddress;
/** the total distance between fromCoordinate and toCoordinate, when travelled along the given waypoints */
@property (nonatomic, strong, readonly) MTDDistance *distance;
/** the total estimated time for this route */
@property (nonatomic, assign, readonly) NSTimeInterval timeInSeconds;
/** the estimated time as formatted string */
@property (nonatomic, readonly) NSString *formattedTime;

/**
 Dictionary containing additional information retreived, e.g. warnings and copyrights when using the Google Directions API.
 You have to handle this information on your own and stick to the terms of usage of the API you use
 */
@property (nonatomic, readonly) NSDictionary *additionalInfo;

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
 @name Directions
 ******************************************/

/**
 The estimated time as formatted string with a specified time format.
 
 @param format the format of the time, e.g. H:mm:ss
 @return a string-representation of the estimated time with the given format
 */
- (NSString *)formattedTimeWithFormat:(NSString *)format;

@end
