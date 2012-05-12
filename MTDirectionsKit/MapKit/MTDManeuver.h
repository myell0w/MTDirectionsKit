//
//  MTDManeuver.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDWaypoint;


@interface MTDManeuver : NSObject

@property (nonatomic, strong) MTDWaypoint *waypoint;
@property (nonatomic, assign) CLLocationDistance distance;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (MTDManeuver *)maneuverWithWaypoint:(MTDWaypoint *)waypoint
                            distance:(CLLocationDistance)distance
                                time:(NSTimeInterval)time;

- (id)init;
- (id)initWithWaypoint:(MTDWaypoint *)waypoint
              distance:(CLLocationDistance)distance
                  time:(NSTimeInterval)time;

@end
