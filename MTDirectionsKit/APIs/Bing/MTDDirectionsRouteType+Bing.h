//
//  MTDDirectionsRouteType+Bing.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"


/**
 MTDDirectionStringForDirectionRouteTypeBing returns a string-representation of the given routeType
 used for the [Bing Routes API](http://msdn.microsoft.com/en-us/library/ff701705 "Bing Routes API").
 */
NS_INLINE NSString* MTDDirectionStringForDirectionRouteTypeBing(MTDDirectionsRouteType routeType) {
    switch (routeType) {
        case MTDDirectionsRouteTypeShortestDriving:
            return @"Driving";

        case MTDDirectionsRouteTypePedestrian:
            return @"Walking";

        case MTDDirectionsRouteTypePedestrianIncludingPublicTransport:
            return @"Transit";

        case MTDDirectionsRouteTypeBicycle:
            return @"Walking";

        case MTDDirectionsRouteTypeFastestDriving:
        default:
            return @"Driving";

    }
}
