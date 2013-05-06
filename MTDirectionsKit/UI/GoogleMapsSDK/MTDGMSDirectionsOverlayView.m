#import "MTDGMSDirectionsOverlayView.h"
#import "MTDRoute+MTDGoogleMapsSDK.h"


@implementation MTDGMSDirectionsOverlayView

- (id)initWithRoute:(MTDRoute *)route {
    if ((self = [super init])) {
        self.path = route.path;
    }

    return self;
}

@end
