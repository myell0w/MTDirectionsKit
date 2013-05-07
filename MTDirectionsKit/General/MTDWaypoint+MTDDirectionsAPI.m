#import "MTDWaypoint+MTDDirectionsAPI.h"


@implementation MTDWaypoint (MTDDirectionsAPI)

- (NSString *)descriptionForAPI:(MTDDirectionsAPI)api {
    switch (api) {
            // Currently there's no difference between the used APIs here
        case MTDDirectionsAPIMapQuest:
        case MTDDirectionsAPIGoogle:
        case MTDDirectionsAPIBing: {
            if (self.hasValidCoordinate) {
                return [NSString stringWithFormat:@"%f,%f",self.coordinate.latitude, self.coordinate.longitude];
            } else {
                return self.address.description;
            }
        }

        default: {
            return @"";
        }
    }
}

@end
