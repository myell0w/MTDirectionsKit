//
//  MTDirectionRouteType.h
//  WhereTU
//
//  Created by Tretter Matthias on 25.12.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//


typedef enum {
    MTDirectionRouteTypeFastestDriving,
    MTDirectionRouteTypeShortestDriving,
    MTDirectionRouteTypePedestrian,
    MTDirectionRouteTypePedestrianIncludingPublicTransport,
    MTDirectionRouteTypeBicycle
} MTDirectionRouteType;

NS_INLINE NSString* MTDirectionAPIStringForDirectionRouteType(MTDirectionRouteType routeType) {
    switch (routeType) {
        case MTDirectionRouteTypeFastestDriving:
            return @"fastest";
            
        case MTDirectionRouteTypeShortestDriving:
            return @"shortest";
            
        case MTDirectionRouteTypePedestrian:
            return @"pedestrian";
            
        case MTDirectionRouteTypePedestrianIncludingPublicTransport:
            return @"multimodal";
            
        case MTDirectionRouteTypeBicycle:
        default:
            return @"bicycle";

    }
    
    return @"bicycle";
}