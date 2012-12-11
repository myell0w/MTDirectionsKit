//
//  MTDDirectionsRequest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"
#import "MTDDirectionsDefines.h"
#import "MTDHTTPRequest.h"
#import "MTDDirectionsAPI.h"
#import "MTDDirectionsRequestOption.h"


@class MTDWaypoint;


/**
 An instance of MTDDirectionsRequest is used to retreive information about a route from a given fromCoordinate
 to a given toCoordinate. MTDDirectionsRequest itself cannot be instantiated and must be subclassed.
 */
@interface MTDDirectionsRequest : NSObject

/******************************************
 @name Route
 ******************************************/

/** the start waypoint of the route to request. */
@property (nonatomic, readonly) MTDWaypoint *from;
/** the end waypoint of the route to request. */
@property (nonatomic, readonly) MTDWaypoint *to;
/** the intermediate goals along the route, can be nil if none are set. */
@property (nonatomic, readonly) NSArray *intermediateGoals;
/** the block that gets executed once the request is finished */
@property (nonatomic, copy, readonly) mtd_parser_block completion;
/** the type of the route to request */
@property (nonatomic, readonly) MTDDirectionsRouteType routeType;

/******************************************
 @name API
 ******************************************/

/** the address of the the request to perform */
@property (nonatomic, readonly) NSString *HTTPAddress;

/** the used API of this request */
@property (nonatomic, readonly) MTDDirectionsAPI API;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 This method is used to create a request of a specific API from a given start- to a given end waypoint
 with a specified routeType, options and optional intermediate goals.

 @param API the API used to request the data (MTDDirectionsAPI)
 @param from the start waypoint of the route to request
 @param to the end waypoint of the route to request
 @param intermediateGoals an optional array of waypoint we want to travel to along the route
 @param routeType the type of the route to request
 @param options a bitmask of MTDDirectionsRequestOption
 (MTDDirectionsRequestOptionAlternativeRoutes and MTDDirectionsRequestOptionOptimize can't be specified  at once)
 @param completion the block to execute when the request is finished
 */
+ (instancetype)requestDirectionsAPI:(MTDDirectionsAPI)API
                                from:(MTDWaypoint *)from
                                  to:(MTDWaypoint *)to
                   intermediateGoals:(NSArray *)intermediateGoals
                           routeType:(MTDDirectionsRouteType)routeType
                             options:(MTDDirectionsRequestOptions)options
                          completion:(mtd_parser_block)completion;

/**
 The designated initializer used to instantiate an MTDDirectionsRequest.

 @param from the starting waypoint of the route to request
 @param to the end waypoint of the route to request
 @param intermediateGoals an optional array of waypoint we want to travel to along the route
 @param routeType the type of route to request
 @param options a bitmask of MTDDirectionsRequestOption
 (MTDDirectionsRequestOptionAlternativeRoutes and MTDDirectionsRequestOptionOptimize can't be specified  at once)
 @param completion block that is executed when requesting of the route is finished
 */
- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
         routeType:(MTDDirectionsRouteType)routeType
           options:(MTDDirectionsRequestOptions)options
        completion:(mtd_parser_block)completion;

/******************************************
 @name Request
 ******************************************/

/**
 This method first calls a subclass-hook to allow final modification of the URL to call and then starts the request.

 @see preparedURLForAddress:
 */
- (void)start;
/** Cancels a possible ongoing request, does nothing if the request isn't active. */
- (void)cancel;

/**
 Let's you set string parameter values that get passed to the directions service as get parameter.

 @param value the value of the parameter to set
 @param parameter the name of the parameter
 */
- (void)setValue:(NSString *)value forParameter:(NSString *)parameter;

/**
 Let's you set array parameter values that get passed to the directions service as get parameter.
 When the URL gets created, the parameter key gets repeated with each value, e.g.
 to=VALUE_1&to=VALUE_2&to=VALUE_3

 @param array an array of values for the given parameter key
 @param parameter the name of the parameter
 */
- (void)setArrayValue:(NSArray *)array forParameter:(NSString *)parameter;

/**
 Convenience function to set a parameter based on an array of intermediate goals of the route.

 @param intermediateGoals array of waypoints we want to travel to along the route
 */
- (void)setValueForParameterWithIntermediateGoals:(NSArray *)intermediateGoals;

/**
 Let's you remove a once specified value for a parameter

 @param parameter the name of the parameter
 */
- (void)removeValueForParameter:(NSString *)parameter;


/******************************************
 @name Subclass Hooks
 ******************************************/

/**
 This method get's executed right before the request gets send to the specified API (- [MTDDirectionsRequest start]).
 The default implementation just returns the address as is without changing it, but subclasses can override this
 method to change the request address the way they want to. MTDDirectionsRequestGoogle for example uses this hook
 to compute a signature for the address, when a business was registered. This method gets called on a global concurrent queue.

 @param address the address we want to request from the specified API
 @return the final URL we will request
 */
- (NSURL *)preparedURLForAddress:(NSString *)address;

@end
