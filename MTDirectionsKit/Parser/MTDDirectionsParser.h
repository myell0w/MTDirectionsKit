//
//  MTDDirectionsParser.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsDefines.h"
#import "MTDDirectionsRouteType.h"


@class MTDWaypoint;


/**
 The MTDDirectionsParser protocol defines a set of required methods that instances of
 MTDDirectionsParser need to implement, that want to act as a directions parser.
 */
@protocol MTDDirectionsParser <NSObject>

@required

/******************************************
 @name Directions
 ******************************************/

/** The object used to store the information about the route. */
@property (nonatomic, strong, readonly) id data;
/** The starting waypoint of the route */
@property (nonatomic, strong, readonly) MTDWaypoint *from;
/** The end waypoint of the route */
@property (nonatomic, strong, readonly) MTDWaypoint *to;
/** The intermediate goals along the route */
@property (nonatomic, copy, readonly) NSArray *intermediateGoals;
/** The type of the route */
@property (nonatomic, assign, readonly) MTDDirectionsRouteType routeType;

/******************************************
 @name Parsing
 ******************************************/

/**
 This method is not implemented in MTDDirectionsParser and must be overwritten by each concrete
 subclass. It parses the data and calls the completion block once finished.
 
 @param completion block that is called, once parsing is finished
 */
- (void)parseWithCompletion:(mtd_parser_block)completion;

@end


/**
 An instance of MTDDirectionsParser is used to parse information about a route from a given fromCoordinate to a given
 toCoordinate. MTDDirectionsParser itself doesn't implement any logic and crashes if you try to parse data with a direct
 instance of MTDDirectionsParser, but is the base class for each concrete parser used in MTDirectionsKit.
 */
@interface MTDDirectionsParser : NSObject <MTDDirectionsParser>

/******************************************
 @name Lifecycle
 ******************************************/

/**
 This method is used to instantiate a concrete MTDDirctionsParser-subclass.
 
 @param from the starting waypoint of the route
 @param to the end waypoint of the route
 @param intermediateGoals the intermediate goals along the route
 @param routeType the type of the route
 @param data the data holding information about the route
 */
- (id)initWithFrom:(MTDWaypoint *)from
                to:(MTDWaypoint *)to
 intermediateGoals:(NSArray *)intermediateGoals
         routeType:(MTDDirectionsRouteType)routeType
              data:(id)data;


/******************************************
 @name Parsing
 ******************************************/

/**
 Updates the names of the routes with the name of the longest maneuver on this route.
 
 @param routes array of MTDRoute objects
 @param forceUpdate if forceUpdate is set to YES the name of the route gets updated, even if it's already set
 */
- (void)updateRouteNamesFromLongestDistanceManeuver:(NSArray *)routes forceUpdate:(BOOL)forceUpdate;

/**
 Calls the given completion block on the main queue, if it is not nil.
 
 @param completion the block to execute on the main queue
 @param overlay the overlay that get's passed to the completion block
 @param error the error that get's passed to the completion block
 */
- (void)callCompletion:(mtd_parser_block)completion overlay:(MTDDirectionsOverlay *)overlay error:(NSError *)error;

@end
