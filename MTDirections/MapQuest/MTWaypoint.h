//
//  MTWaypoint.h
//  WhereTU
//
//  Created by Tretter Matthias on 25.12.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MTWaypoint : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+ (MTWaypoint *)waypointWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
