#import "MTDGMSDirectionsOverlayView.h"
#import "MTDRoute+MTDGoogleMapsSDK.h"


#define kMTDDefaultLineWidthFactor      1.8f
#define kMTDMinimumLineWidthFactor      0.7f
#define kMTDMaximumLineWidthFactor      3.0f

#define kMTDMultiplicationFactor         4.f


@interface MTDGMSDirectionsOverlayView ()

@property (nonatomic, mtd_weak) MTDDirectionsOverlay *directionsOverlay;
@property (nonatomic, mtd_weak) MTDRoute *route;

@end

@implementation MTDGMSDirectionsOverlayView

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay route:(MTDRoute *)route {
    if ((self = [super init])) {
        self.path = route.path;
        self.tappable = YES;

        _directionsOverlay = directionsOverlay;
        _route = route;
        _overlayLineWidthFactor = kMTDDefaultLineWidthFactor;

        self.strokeWidth = _overlayLineWidthFactor * kMTDMultiplicationFactor;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - GMSPolyline
////////////////////////////////////////////////////////////////////////

- (CGFloat)strokeWidth {
    if (self.directionsOverlay.activeRoute == self.route) {
        return self.overlayLineWidthFactor * kMTDMultiplicationFactor;
    } else {
        return self.overlayLineWidthFactor * kMTDMultiplicationFactor * 0.75f;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDGMSDirectionsOverlayView
////////////////////////////////////////////////////////////////////////

- (void)setOverlayColor:(UIColor *)overlayColor {
    if (overlayColor != nil) {
        self.strokeColor = overlayColor;
    }
}

- (void)setOverlayLineWidthFactor:(CGFloat)overlayLineWidthFactor {
    if (overlayLineWidthFactor >= kMTDMinimumLineWidthFactor && overlayLineWidthFactor <= kMTDMaximumLineWidthFactor) {
        _overlayLineWidthFactor = overlayLineWidthFactor;
    }
}

@end
