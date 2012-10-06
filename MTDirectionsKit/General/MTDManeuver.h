//
//  MTDManeuver.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDWaypoint;


@interface MTDManeuver : NSObject

@property (nonatomic, strong, readonly) MTDWaypoint *waypoint;
@property (nonatomic, assign, readonly) CLLocationDistance distance;
@property (nonatomic, assign, readonly) NSTimeInterval time;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (MTDManeuver *)maneuverWithWaypoint:(MTDWaypoint *)waypoint
                             distance:(CLLocationDistance)distance
                                 time:(NSTimeInterval)time;


- (id)initWithWaypoint:(MTDWaypoint *)waypoint
              distance:(CLLocationDistance)distance
                  time:(NSTimeInterval)time;

@end
