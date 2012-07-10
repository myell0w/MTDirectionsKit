//
//  MTDDirectionsRouteType+Google.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


NS_INLINE NSString* MTDDirectionStringForDirectionRouteTypeGoogle(MTDDirectionsRouteType routeType) {
    switch (routeType) {    
        case MTDDirectionsRouteTypePedestrian:
            return @"walking";

        case MTDDirectionsRouteTypePedestrianIncludingPublicTransport:
            return @"transit";
            
        case MTDDirectionsRouteTypeBicycle:
            return @"bicycling";
            
        case MTDDirectionsRouteTypeShortestDriving:
        case MTDDirectionsRouteTypeFastestDriving:
        default:
            return @"driving";
    }
}
