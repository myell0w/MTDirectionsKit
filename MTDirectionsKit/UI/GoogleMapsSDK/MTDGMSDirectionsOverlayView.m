#import "MTDGMSDirectionsOverlayView.h"
#import "MTDRoute+MTDGoogleMapsSDK.h"


#define kMTDDefaultLineWidthFactor      1.8f
#define kMTDMinimumLineWidthFactor      0.7f
#define kMTDMaximumLineWidthFactor      3.0f


@implementation MTDGMSDirectionsOverlayView

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithRoute:(MTDRoute *)route {
    if ((self = [super init])) {
        self.path = route.path;
        self.tappable = YES;

        self.overlayLineWidthFactor = kMTDDefaultLineWidthFactor;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDGMSDirectionsOverlayView
////////////////////////////////////////////////////////////////////////

- (void)setOverlayLineWidthFactor:(CGFloat)overlayLineWidthFactor {
    if (overlayLineWidthFactor >= kMTDMinimumLineWidthFactor && overlayLineWidthFactor <= kMTDMaximumLineWidthFactor) {
        _overlayLineWidthFactor = overlayLineWidthFactor;

        self.strokeWidth = overlayLineWidthFactor * 4.f;
    }
}

@end
