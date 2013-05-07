//
//  MTDNavigationAppBuiltInMaps.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDNavigationApp.h"

/**
 A specific subclass of MTDNavigationApp that represents the built-in Maps.app.
 
 Since the built-in Maps application only supports travelling per pedes,
 by public transport or by car, MTDDirectionsRouteTypePedestrian is used in case MTDDirectionsRouteTypeBicycle
 was specified.
 */
@interface MTDNavigationAppBuiltInMaps : MTDNavigationApp

@end
