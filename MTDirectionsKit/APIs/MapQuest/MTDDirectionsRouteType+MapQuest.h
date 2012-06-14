//
//  MTDDirectionsRouteType+MapQuest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"

/**
 MTDDirectionStringForDirectionRouteTypeMapQuest returns a string-representation of the given routeType
 used for the [MapQuest Open Directions API](http://open.mapquestapi.com/directions/ "MapQuest Open Directions API").
 */
NS_INLINE NSString* MTDDirectionStringForDirectionRouteTypeMapQuest(MTDDirectionsRouteType routeType) {
    switch (routeType) {
        case MTDDirectionsRouteTypeShortestDriving:
            return @"shortest";
            
        case MTDDirectionsRouteTypePedestrian:
            return @"pedestrian";
            
        case MTDDirectionsRouteTypePedestrianIncludingPublicTransport:
            return @"multimodal";
            
        case MTDDirectionsRouteTypeBicycle:
            return @"bicycle";
            
        case MTDDirectionsRouteTypeFastestDriving:
        default:
            return @"fastest";
            
    }
}
