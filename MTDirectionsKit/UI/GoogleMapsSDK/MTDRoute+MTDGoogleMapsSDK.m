#import "MTDRoute+MTDGoogleMapsSDK.h"
#import <GoogleMaps/GoogleMaps.h>
#import <objc/runtime.h>


static char pathKey;


@implementation MTDRoute (MTDGoogleMapsSDK)

- (GMSPath *)path {
    GMSMutablePath *path = objc_getAssociatedObject(self, &pathKey);
    if (path != nil) {
        return path;
    }

    path = [GMSMutablePath new];

    for (MTDWaypoint *waypoint in self.waypoints) {
        [path addCoordinate:waypoint.coordinate];
    }

    objc_setAssociatedObject(self, &pathKey, path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    return path;
}

@end
