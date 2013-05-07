#import "MTDMapView.h"
#import "MTDAddress.h"
#import "MTDWaypoint.h"
#import "MTDWaypoint+MTDirectionsPrivateAPI.h"
#import "MTDManeuver.h"
#import "MTDDistance.h"
#import "MTDDirectionsDelegate.h"
#import "MTDDirectionsRequest.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsOverlay+MTDirectionsPrivateAPI.h"
#import "MTDRoute.h"
#import "MTDDirectionsOverlayView.h"
#import "MTDDirectionsOverlayView+MTDirectionsPrivateAPI.h"
#import "MTDMapViewProxy.h"
#import "MTDCustomization.h"
#import "MTDInterApp.h"
#import "MTDAssert.h"
#import "MTDFunctions.h"


@interface MTDMapView () <MKMapViewDelegate>

@property (nonatomic, strong, readwrite) MTDDirectionsOverlayView *directionsOverlayView; // re-defined as read/write

/** The delegate that was set by the user, we forward all delegate calls */
@property (nonatomic, mtd_weak, setter = mtd_setTrueDelegate:) id<MKMapViewDelegate> mtd_trueDelegate;

/** the delegate proxy for CLLocationManagerDelegate and UIGestureRecognizerDelegate */
@property (nonatomic, strong) MTDMapViewProxy *mtd_proxy;
/** Gesture recognizer to change active route */
@property (nonatomic, strong) UITapGestureRecognizer *mtd_tapGestureRecognizer;

@end


@implementation MTDMapView

@synthesize directionsOverlay = _directionsOverlay;
@synthesize directionsDisplayType = _directionsDisplayType;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self mtd_setup];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self mtd_setup];
    }

    return self;
}

- (void)dealloc {
    _mtd_proxy.mapView = nil;
    _mtd_proxy = nil;
    _mtd_tapGestureRecognizer.delegate = nil;
    self.delegate = nil;
    [self cancelLoadOfDirections];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) {
        [self cancelLoadOfDirections];
    }

    [super willMoveToSuperview:newSuperview];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        [self cancelLoadOfDirections];
    }

    [super willMoveToWindow:newWindow];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Directions
////////////////////////////////////////////////////////////////////////

- (void)loadDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
                        to:(CLLocationCoordinate2D)toCoordinate
                 routeType:(MTDDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections {
    [self loadDirectionsFrom:[MTDWaypoint waypointWithCoordinate:fromCoordinate]
                          to:[MTDWaypoint waypointWithCoordinate:toCoordinate]
           intermediateGoals:nil
                   routeType:routeType
                     options:MTDDirectionsRequestOptionNone
        zoomToShowDirections:zoomToShowDirections];
}

- (void)loadDirectionsFromAddress:(NSString *)fromAddress
                        toAddress:(NSString *)toAddress
                        routeType:(MTDDirectionsRouteType)routeType
             zoomToShowDirections:(BOOL)zoomToShowDirections {
    [self loadDirectionsFrom:[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:fromAddress]]
                          to:[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:toAddress]]
           intermediateGoals:nil
                   routeType:routeType
                     options:MTDDirectionsRequestOptionNone
        zoomToShowDirections:zoomToShowDirections];
}

- (void)loadAlternativeDirectionsFrom:(MTDWaypoint *)from
                                   to:(MTDWaypoint *)to
                            routeType:(MTDDirectionsRouteType)routeType
                 zoomToShowDirections:(BOOL)zoomToShowDirections {

    [self loadDirectionsFrom:from
                          to:to
           intermediateGoals:nil
                   routeType:routeType
                     options:_MTDDirectionsRequestOptionAlternativeRoutes
        zoomToShowDirections:zoomToShowDirections];
}

- (void)loadDirectionsFrom:(MTDWaypoint *)from
                        to:(MTDWaypoint *)to
         intermediateGoals:(NSArray *)intermediateGoals
                 routeType:(MTDDirectionsRouteType)routeType
                   options:(MTDDirectionsRequestOptions)options
      zoomToShowDirections:(BOOL)zoomToShowDirections {

    [self.mtd_proxy loadDirectionsFrom:from
                                    to:to
                     intermediateGoals:intermediateGoals
                             routeType:routeType
                               options:options
                  zoomToShowDirections:zoomToShowDirections];
}

- (void)cancelLoadOfDirections {
    [self.mtd_proxy cancelLoadOfDirections];
}

- (void)removeDirectionsOverlay {
    [self removeOverlay:_directionsOverlay];

    _directionsOverlay = nil;
    _directionsOverlayView = nil;
}

- (void)activateRoute:(MTDRoute *)route {
    MTDRoute *activeRouteBefore = self.directionsOverlay.activeRoute;

    if (route != nil && route != activeRouteBefore) {
        [self.directionsOverlay mtd_activateRoute:route];
        MTDRoute *activeRouteAfter = self.directionsOverlay.activeRoute;

        if (activeRouteBefore != activeRouteAfter) {
            [self.mtd_proxy notifyDelegateDidActivateRoute:activeRouteAfter ofOverlay:self.directionsOverlay];
            [self.directionsOverlayView setNeedsDisplayInMapRect:MKMapRectWorld];
        }
    }
}

- (CGFloat)distanceBetweenActiveRouteAndCoordinate:(CLLocationCoordinate2D)coordinate {
    MTDAssert(CLLocationCoordinate2DIsValid(coordinate), @"We can't measure distance to invalid coordinates");

    MTDRoute *activeRoute = self.directionsOverlay.activeRoute;

    if (activeRoute == nil || !CLLocationCoordinate2DIsValid(coordinate)) {
        return FLT_MAX;
    }

    CGPoint point = [self convertCoordinate:coordinate toPointToView:self.directionsOverlayView];
    CGFloat distance = [self.directionsOverlayView distanceBetweenPoint:point route:self.directionsOverlay.activeRoute];

    return distance;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Region
////////////////////////////////////////////////////////////////////////

- (void)setRegionToShowDirectionsAnimated:(BOOL)animated {
    [self setVisibleMapRect:self.directionsOverlay.boundingMapRect edgePadding:self.directionsEdgePadding animated:animated];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
////////////////////////////////////////////////////////////////////////

- (void)setDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
    if (directionsOverlay != _directionsOverlay) {
        // remove old overlay and annotations
        if (_directionsOverlay != nil) {
            [self removeDirectionsOverlay];
        }

        _directionsOverlay = directionsOverlay;

        // add new overlay
        if (directionsOverlay != nil) {
            [self addOverlay:directionsOverlay];
        }

        // we enable the gesture recognizer to change the active route only,
        // if there is more than one route
        self.mtd_tapGestureRecognizer.enabled = directionsOverlay.routes.count > 1;
    }
}

- (void)setDirectionsDisplayType:(MTDDirectionsDisplayType)directionsDisplayType {
    if (directionsDisplayType != _directionsDisplayType) {
        _directionsDisplayType = directionsDisplayType;
        self.directionsOverlayView.drawManeuvers = (directionsDisplayType == MTDDirectionsDisplayTypeDetailedManeuvers);

        [self mtd_updateUIForDirectionsDisplayType:directionsDisplayType];
    }
}

- (void)setDirectionsDelegate:(id<MTDDirectionsDelegate>)directionsDelegate {
    self.mtd_proxy.directionsDelegate = directionsDelegate;
}

- (id<MTDDirectionsDelegate>)directionsDelegate {
    return self.mtd_proxy.directionsDelegate;
}

- (void)setDelegate:(id<MKMapViewDelegate>)delegate {
    if (delegate != _mtd_trueDelegate) {
        _mtd_trueDelegate = delegate;

        // if we haven't set a directionsDelegate and our delegate conforms to the protocol
        // MTDDirectionsDelegate, then we automatically set our directionsDelegate
        if (self.directionsDelegate == nil && [delegate conformsToProtocol:@protocol(MTDDirectionsDelegate)]) {
            self.directionsDelegate = (id<MTDDirectionsDelegate>)delegate;
        }
    }
}

- (id<MKMapViewDelegate>)delegate {
    return _mtd_trueDelegate;
}

- (CLLocationCoordinate2D)fromCoordinate {
    if (self.directionsOverlay != nil) {
        return self.directionsOverlay.from.coordinate;
    }

    return kCLLocationCoordinate2DInvalid;
}

- (CLLocationCoordinate2D)toCoordinate {
    if (self.directionsOverlay != nil) {
        return self.directionsOverlay.to.coordinate;
    }

    return kCLLocationCoordinate2DInvalid;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Inter-App
////////////////////////////////////////////////////////////////////////

- (BOOL)openDirectionsInMapsApp {
    if (self.directionsOverlay != nil) {
        return [MTDNavigationAppBuiltInMaps openDirectionsFrom:self.directionsOverlay.activeRoute.from
                                                            to:self.directionsOverlay.activeRoute.to
                                                     routeType:self.directionsOverlay.routeType];
    }

    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate Proxies
////////////////////////////////////////////////////////////////////////

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [trueDelegate mapView:mapView regionWillChangeAnimated:animated];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [trueDelegate mapView:mapView regionDidChangeAnimated:animated];
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]) {
        [trueDelegate mapViewWillStartLoadingMap:mapView];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [trueDelegate mapViewDidFinishLoadingMap:mapView];
    }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapViewDidFailLoadingMap:withError:)]) {
        [trueDelegate mapViewDidFailLoadingMap:mapView withError:error];
    }
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [trueDelegate mapViewWillStartLocatingUser:mapView];
    }
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [trueDelegate mapViewDidStopLocatingUser:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)]) {
        [trueDelegate mapView:mapView didUpdateUserLocation:userLocation];
    }

    [MTDWaypoint mtd_updateCurrentLocationCoordinate:userLocation.location.coordinate];
    [self.mtd_proxy notifyDelegateDidUpdateUserLocation:userLocation.location];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]) {
        [trueDelegate mapView:mapView didFailToLocateUserWithError:error];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        return [trueDelegate mapView:mapView viewForAnnotation:annotation];
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [trueDelegate mapView:mapView didAddAnnotationViews:views];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
        [trueDelegate mapView:mapView annotationView:view calloutAccessoryControlTapped:control];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)]) {
        [trueDelegate mapView:mapView annotationView:annotationView didChangeDragState:newState fromOldState:oldState];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [trueDelegate mapView:mapView didSelectAnnotationView:view];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [trueDelegate mapView:mapView didDeselectAnnotationView:view];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;
    BOOL overlayIsDirectionsOverlay = [overlay isKindOfClass:[MTDDirectionsOverlay class]];

    // first check if the delegate provides a custom overlay view
    if ([trueDelegate respondsToSelector:@selector(mapView:viewForOverlay:)]) {
        MKOverlayView *delegateResult = [trueDelegate mapView:mapView viewForOverlay:overlay];

        if (delegateResult != nil) {
            if (overlayIsDirectionsOverlay) {
                MTDLogInfo(@"MKMapViewDelegate provided a custom overlay view for MTDDirectionsOverlay, make sure this is really what you want.");
            }

            return delegateResult;
        }
    }

    // otherwise provide a default overlay for directions
    if (overlayIsDirectionsOverlay) {
        return [self mtd_viewForDirectionsOverlay:overlay];
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didAddOverlayViews:)]) {
        [trueDelegate mapView:mapView didAddOverlayViews:overlayViews];
    }
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didChangeUserTrackingMode:animated:)]) {
        [trueDelegate mapView:mapView didChangeUserTrackingMode:mode animated:animated];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    // we set ourself as the delegate
    [super setDelegate:self];

    _directionsDisplayType = MTDDirectionsDisplayTypeNone;
    _directionsEdgePadding = UIEdgeInsetsMake(40.f, 15.f, 15.f, 15.f);
    _mtd_proxy = [[MTDMapViewProxy alloc] initWithMapView:self];

    // we need this GestureRecognizer to be able to select alternative routes
    _mtd_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mtd_handleMapTap:)];
    _mtd_tapGestureRecognizer.enabled = NO;
    _mtd_tapGestureRecognizer.delegate = _mtd_proxy;

    // we require all gesture recognizer except other single-tap gesture recognizers to fail
    NSMutableArray *mapViewGestureRecognizers = [NSMutableArray arrayWithArray:self.gestureRecognizers];

    for (UIView *view in [self subviews]) {
        [mapViewGestureRecognizers addObjectsFromArray:[view gestureRecognizers]];
    }

    MTDAssert(mapViewGestureRecognizers.count > 0, @"Wasn't able to find gesture recognizers of MapView");

    for (UIGestureRecognizer *gesture in mapViewGestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *systemTap = (UITapGestureRecognizer *)gesture;

            if (systemTap.numberOfTapsRequired > 1) {
                [_mtd_tapGestureRecognizer requireGestureRecognizerToFail:systemTap];
            }
        } else {
            [_mtd_tapGestureRecognizer requireGestureRecognizerToFail:gesture];
        }
    }

    [self addGestureRecognizer:_mtd_tapGestureRecognizer];

    // Watermark
    {
        CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent(), 5., 0, 0, ^(__unused CFRunLoopTimerRef t) {
            if (!_mtd_wm_) {
                [self removeOverlays:self.overlays];
            }
        });
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
    }
}

- (void)mtd_handleMapTap:(UITapGestureRecognizer *)tap {
    if ((tap.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
        // Check if the directionsOverlay got tapped
        if (self.directionsOverlayView != nil) {
            // Get view frame rect in the mapView's coordinate system
            CGRect viewFrameInMapView = [self.directionsOverlayView.superview convertRect:self.directionsOverlayView.frame toView:self];
            // Get touch point in the mapView's coordinate system
            CGPoint point = [tap locationInView:self];

            // we outset the frame of the overlay to also handle touches that are a bit outside
            viewFrameInMapView = CGRectInset(viewFrameInMapView, -50.f, -50.f);

            // Check if the touch is within the view bounds
            if (CGRectContainsPoint(viewFrameInMapView, point)) {
                MTDRoute *selectedRoute = [self.directionsOverlayView mtd_routeTouchedByPoint:[tap locationInView:self.directionsOverlayView]];

                // ask delegate if we should activate the route
                if ([self.mtd_proxy askDelegateForSelectionEnabledStateOfRoute:selectedRoute ofOverlay:self.directionsOverlay]) {
                    [self activateRoute:selectedRoute];
                }
            }
        }
    }
}

- (void)mtd_updateUIForDirectionsDisplayType:(MTDDirectionsDisplayType) __unused displayType {
    if (_directionsOverlay != nil) {
        [self removeOverlay:_directionsOverlay];
        _directionsOverlayView = nil;
        [self addOverlay:_directionsOverlay];
    }
}

- (MKOverlayView *)mtd_viewForDirectionsOverlay:(id<MKOverlay>)overlay {
    // don't display anything if display type is set to none
    if (self.directionsDisplayType == MTDDirectionsDisplayTypeNone) {
        return nil;
    }

    if (![overlay isKindOfClass:[MTDDirectionsOverlay class]] || self.directionsOverlay == nil) {
        return nil;
    }

    MTDDirectionsOverlay *directionsOverlay = overlay;
    CGFloat overlayLineWidthFactor = [self.mtd_proxy askDelegateForLineWidthFactorOfOverlay:directionsOverlay];
    Class directionsOverlayClass = MTDOverriddenClass([MTDDirectionsOverlayView class]);

    if (directionsOverlayClass != Nil) {
        self.directionsOverlayView = [[directionsOverlayClass alloc] initWithOverlay:directionsOverlay];
        self.directionsOverlayView.drawManeuvers = (self.directionsDisplayType == MTDDirectionsDisplayTypeDetailedManeuvers);

        for (MTDRoute *route in directionsOverlay.routes) {
            UIColor *overlayColor = [self.mtd_proxy askDelegateForColorOfRoute:route ofOverlay:self.directionsOverlay];

            // If we always set the color it breaks UIAppearance because it deactivates the proxy color if we
            // call the setter, even if we don't accept nil there.
            if (overlayColor != nil) {
                [self.directionsOverlayView setOverlayColor:overlayColor forRoute:route];
            }
            // same goes for the line width factor
            if (overlayLineWidthFactor > 0.f) {
                self.directionsOverlayView.overlayLineWidthFactor = overlayLineWidthFactor;
            }
        }
    }
    
    return self.directionsOverlayView;
}

@end
