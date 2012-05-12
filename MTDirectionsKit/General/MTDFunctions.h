//
//  MTDFunction.h
//  MTDirectionsKit
//
//  Created by Tretter Matthias on 12.05.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "MTDDirectionsRouteType.h"

/**
 Opens the built in Maps.app and displays the directions from fromCoordinate to toCoordinate
 with the chosen routeType. The supported routeTypes are only car, walking and public transport,
 so if the function is called with routeType MTDDirectionsRouteTypeBicycle, MTDDirectionsRouteTypePedestrian
 is chosen instead
 
 @param fromCoordinate the start coordinate of the route
 @param toCoordinate the end coordinate of the route
 @param routeType the type of the route
 */
void MTDDirectionsOpenInMapsApp(CLLocationCoordinate2D fromCoordinate, CLLocationCoordinate2D toCoordinate, MTDDirectionsRouteType routeType);

