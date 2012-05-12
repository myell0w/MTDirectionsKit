//
//  MTDDirectionsRouteType+MapQuest.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


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