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


/**
 An instance of MTDDirectionsRequest is used to retreive information about a route from a given fromCoordinate
 to a given toCoordinate. MTDDirectionsRequest itself cannot be instantiated and must be subclassed.
 */
@interface MTDDirectionsRequest : NSObject

/******************************************
 @name Route
 ******************************************/

/** the start coordinate of the route to request, can be invalid if not set in init. */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the route to request, can be invalid if not set in init. */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;
/** the start coordinate of the route to request, can be nil if not set in init. */
@property (nonatomic, copy, readonly) NSString *fromAddress;
/** the address of the end coordinate of the route to request, can be nil if not set in init. */
@property (nonatomic, copy, readonly) NSString *toAddress;
/** the block that gets executed once the request is finished */
@property (nonatomic, copy, readonly) mtd_parser_block completion;
/** the type of the route to request */
@property (nonatomic, readonly) MTDDirectionsRouteType routeType;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 This method is used to create a request from a given fromCoordinate to a given toCoordinate with a specified routeType.
 
 @param fromCoordinate the start coordinate of the route to request
 @param toCoordinate the end coordinate of the route to request
 @param routeType the type of the route to request
 @param completion the block to execute when the request is finished
 */
+ (id)requestFrom:(CLLocationCoordinate2D)fromCoordinate
               to:(CLLocationCoordinate2D)toCoordinate
        routeType:(MTDDirectionsRouteType)routeType
       completion:(mtd_parser_block)completion;

/**
 This method is used to create a request from a given fromCoordinate to a given toCoordinate with a specified routeType.
 
 @param fromAddress the address of the starting coordinate of the route to request
 @param toAddress the address of the end coordinate of the route to request
 @param routeType the type of the route to request
 @param completion the block to execute when the request is finished
 */
+ (id)requestFromAddress:(NSString *)fromAddress
               toAddress:(NSString *)toAddress
               routeType:(MTDDirectionsRouteType)routeType
              completion:(mtd_parser_block)completion;

/**
 The designated initializer used to instantiate an MTDDirectionsRequest.
 
 @param fromCoordinate the starting coordinate of the route to request
 @param toCoordinate the end coordinate of the route to request
 @param routeType the type of route to request
 @param completion block that is executed when requesting of the route is finished
 */
- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDDirectionsRouteType)routeType
    completion:(mtd_parser_block)completion;

/**
 The designated initializer used to instantiate an MTDDirectionsRequest.
 
 @param fromAddress the address of the starting coordinate of the route to request
 @param toAddress the address of the end coordinate of the route to request
 @param routeType the type of route to request
 @param completion block that is executed when requesting of the route is finished
 */
- (id)initFromAddress:(NSString *)fromAddress
            toAddress:(NSString *)toAddress
            routeType:(MTDDirectionsRouteType)routeType
           completion:(mtd_parser_block)completion;

/******************************************
 @name Request
 ******************************************/

/** Starts the request */
- (void)start;
/** Cancels a possible ongoing request, does nothing if the request isn't active. */
- (void)cancel;

/**
 Let's you set parameter values that get passed to the directions service as get parameter.
 
 @param value the value of the parameter to set
 @param parameter the name of the parameter
 */
- (void)setValue:(NSString *)value forParameter:(NSString *)parameter;

@end
