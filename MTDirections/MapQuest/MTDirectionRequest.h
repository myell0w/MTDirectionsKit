//
//  MTDirectionRequest.h
//  WhereTU
//
//  Created by Tretter Matthias on 25.12.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MTDirectionRouteType.h"

typedef void (^mt_direction_block)(NSArray *waypoints);

@interface MTDirectionRequest : NSObject

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
    completion:(mt_direction_block)completion;

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDirectionRouteType)routeType
    completion:(mt_direction_block)completion;

- (void)start;
- (void)cancel;

@end
