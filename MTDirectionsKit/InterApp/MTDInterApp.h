//
//  MTDInterApp.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDNavigationAppBuiltInMaps.h"
#import "MTDNavigationAppGoogleMaps.h"


typedef NS_ENUM(NSUInteger, MTDNavigationAppType) {
    MTDNavigationAppTypeBuiltInMaps,
    MTDNavigationAppTypeGoogleMaps,
    MTDNavigationAppTypeTomTom,
    MTDNavigationAppTypeNavigon
};


NS_INLINE BOOL MTDDirectionsOpenDirectionsInApp(MTDNavigationAppType appType, MTDWaypoint *from, MTDWaypoint *to, MTDDirectionsRouteType routeType) {
    switch (appType) {
        case MTDNavigationAppTypeBuiltInMaps: {
            return [MTDNavigationAppBuiltInMaps openDirectionsFrom:from to:to routeType:routeType];
        }

        case MTDNavigationAppTypeGoogleMaps: {
            return [MTDNavigationAppGoogleMaps openDirectionsFrom:from to:to routeType:routeType];
        }

        case MTDNavigationAppTypeTomTom: {
            // TODO:
            break;
        }

        case MTDNavigationAppTypeNavigon: {
            // TODO: 
            break;
        }

        default: {
            return NO;
        }
    }

    return NO;
}
