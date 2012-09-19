#import "MTDDirectionsRouteType.h"


NSString* MTDMKLaunchOptionFromMTDDirectionsRouteType(MTDDirectionsRouteType routeType) {
    switch (routeType) {
        case MTDDirectionsRouteTypeFastestDriving:
        case MTDDirectionsRouteTypeShortestDriving: {
            return MKLaunchOptionsDirectionsModeDriving;
        }
            
        case MTDDirectionsRouteTypePedestrian:
        case MTDDirectionsRouteTypeBicycle:
        case MTDDirectionsRouteTypePedestrianIncludingPublicTransport:
        default: {
            return MKLaunchOptionsDirectionsModeWalking;
        }
    }
}
