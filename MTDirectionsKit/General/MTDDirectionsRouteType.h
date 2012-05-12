//
//  MTDDirectionsRouteType.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter on 21.01.12.
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/** 
 The type of route we want to request
 */
typedef enum {
    MTDDirectionsRouteTypeFastestDriving = 0,
    MTDDirectionsRouteTypeShortestDriving,
    MTDDirectionsRouteTypePedestrian,
    MTDDirectionsRouteTypePedestrianIncludingPublicTransport,
    MTDDirectionsRouteTypeBicycle
} MTDDirectionsRouteType;


/** The default route type used when not specified */
#define kMTDDefaultDirectionsRouteType        MTDDirectionsRouteTypePedestrian