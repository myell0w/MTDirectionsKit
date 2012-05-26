//
//  MTDDirectionsRouteType.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


/**
 When requesting routing information you can tell your instance of MTDMapView in which way
 the user wants to travel, that means whether he wants to walk, bike or drive.
 
 The following types of travelling are supported currently:
 
 - MTDDirectionsRouteTypeFastestDriving
 - MTDDirectionsRouteTypeShortestDriving
 - MTDDirectionsRouteTypePedestrian
 - MTDDirectionsRouteTypePedestrianIncludingPublicTransport
 - MTDDirectionsRouteTypeBicycle
 */
typedef enum {
    MTDDirectionsRouteTypeFastestDriving = 0,
    MTDDirectionsRouteTypeShortestDriving,
    MTDDirectionsRouteTypePedestrian,
    MTDDirectionsRouteTypePedestrianIncludingPublicTransport,
    MTDDirectionsRouteTypeBicycle
} MTDDirectionsRouteType;
