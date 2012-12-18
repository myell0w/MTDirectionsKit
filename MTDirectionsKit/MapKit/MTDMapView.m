#import "MTDMapView.h"
#import "MTDAddress.h"
#import "MTDWaypoint.h"
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
#import "MTDMapViewDelegateProxy.h"
#import "MTDFunctions.h"
#import "MTDCustomization.h"
#import "MTDInterApp.h"


@interface MTDMapView () <MKMapViewDelegate> {
    // flags for methods implemented in the delegate
    struct {
        unsigned int willStartLoadingDirections:1;
        unsigned int didFinishLoadingOverlay:1;
        unsigned int didFailLoadingOverlay:1;
        unsigned int didActivateRouteOfOverlay:1;
        unsigned int colorForOverlay:1;
        unsigned int lineWidthFactorForOverlay:1;
	} _directionsDelegateFlags;
}

@property (nonatomic, strong, readwrite) MTDDirectionsOverlayView *directionsOverlayView; // re-defined as read/write

/** The delegate that was set by the user, we forward all delegate calls */
@property (nonatomic, mtd_weak, setter = mtd_setTrueDelegate:) id<MKMapViewDelegate> mtd_trueDelegate;
/** The request object for retreiving directions from the specified API */
@property (nonatomic, strong, setter = mtd_setRequest:) MTDDirectionsRequest *mtd_request;

/** the delegate proxy for CLLocationManagerDelegate and UIGestureRecognizerDelegate */
@property (nonatomic, strong) MTDMapViewDelegateProxy *mtd_delegateProxy;
/** The location manager used to request user location if needed */
@property (nonatomic, strong) CLLocationManager *mtd_locationManager;
/** The completion block executed after we found a location */
@property (nonatomic, copy) dispatch_block_t mtd_locationCompletion;
/** Gesture recognizer to change active route */
@property (nonatomic, strong) UITapGestureRecognizer *mtd_tapGestureRecognizer;

@end


@implementation MTDMapView

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
    _mtd_delegateProxy.mapView = nil;
    _mtd_tapGestureRecognizer.delegate = nil;
    _mtd_locationManager.delegate = nil;
    _directionsDelegate = nil;
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
               optimizeRoute:NO
                   routeType:routeType
        zoomToShowDirections:zoomToShowDirections];
}

- (void)loadDirectionsFromAddress:(NSString *)fromAddress
                        toAddress:(NSString *)toAddress
                        routeType:(MTDDirectionsRouteType)routeType
             zoomToShowDirections:(BOOL)zoomToShowDirections {
    [self loadDirectionsFrom:[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:fromAddress]]
                          to:[MTDWaypoint waypointWithAddress:[MTDAddress addressWithAddressString:toAddress]]
           intermediateGoals:nil
               optimizeRoute:NO
                   routeType:routeType
        zoomToShowDirections:zoomToShowDirections];
}

- (void)loadDirectionsFrom:(MTDWaypoint *)from
                        to:(MTDWaypoint *)to
         intermediateGoals:(NSArray *)intermediateGoals
             optimizeRoute:(BOOL)optimizeRoute
                 routeType:(MTDDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections {

    [self mtd_loadDirectionsFrom:from
                              to:to
                       routeType:routeType
            zoomToShowDirections:zoomToShowDirections
               intermediateGoals:intermediateGoals
                         options:optimizeRoute ? MTDDirectionsRequestOptionOptimize : MTDDirectionsRequestOptionNone];
}

- (void)loadAlternativeDirectionsFrom:(MTDWaypoint *)from
                                   to:(MTDWaypoint *)to
                            routeType:(MTDDirectionsRouteType)routeType
                 zoomToShowDirections:(BOOL)zoomToShowDirections {

    [self mtd_loadDirectionsFrom:from
                              to:to
                       routeType:routeType
            zoomToShowDirections:zoomToShowDirections
               intermediateGoals:nil
                         options:MTDDirectionsRequestOptionAlternativeRoutes];
}

- (void)cancelLoadOfDirections {
    [self.mtd_request cancel];
    self.mtd_request = nil;

    [self mtd_stopUpdatingLocationCallingCompletion:NO];
}

- (void)removeDirectionsOverlay {
    [self removeOverlay:_directionsOverlay];

    _directionsOverlay = nil;
    _directionsOverlayView = nil;
}

- (void)activateRoute:(MTDRoute *)route {
    MTDRoute *activeRouteBefore = self.directionsOverlay.activeRoute;
    [self.directionsOverlay mtd_activateRoute:route];
    MTDRoute *activeRouteAfter = self.directionsOverlay.activeRoute;

    if (activeRouteBefore != activeRouteAfter) {
        [self mtd_notifyDelegateDidActivateRoute:activeRouteAfter ofOverlay:self.directionsOverlay];
        [self.directionsOverlayView setNeedsDisplayInMapRect:MKMapRectWorld];
    }
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
    if (directionsDelegate != _directionsDelegate) {
        _directionsDelegate = directionsDelegate;

        // update delegate flags
        _directionsDelegateFlags.willStartLoadingDirections = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:willStartLoadingDirectionsFrom:to:routeType:)];
        _directionsDelegateFlags.didFinishLoadingOverlay = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:didFinishLoadingDirectionsOverlay:)];
        _directionsDelegateFlags.didFailLoadingOverlay = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:didFailLoadingDirectionsOverlayWithError:)];
        _directionsDelegateFlags.didActivateRouteOfOverlay = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:didActivateRoute:ofDirectionsOverlay:)];
        _directionsDelegateFlags.colorForOverlay = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:colorForDirectionsOverlay:)];
        _directionsDelegateFlags.lineWidthFactorForOverlay = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:lineWidthFactorForDirectionsOverlay:)];
    }
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

- (CLLocationDistance)distanceInMeter {
    return [self.directionsOverlay.distance distanceInMeter];
}

- (NSTimeInterval)timeInSeconds {
    return self.directionsOverlay.timeInSeconds;
}

- (MTDDirectionsRouteType)routeType {
    return self.directionsOverlay.routeType;
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

    self.mtd_delegateProxy.lastKnownUserCoordinate = userLocation.coordinate;
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
    _mtd_delegateProxy = [[MTDMapViewDelegateProxy alloc] initWithMapView:self];

    // we need this GestureRecognizer to be able to select alternative routes
    _mtd_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mtd_handleMapTap:)];
    _mtd_tapGestureRecognizer.enabled = NO;
    _mtd_tapGestureRecognizer.delegate = _mtd_delegateProxy;

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
                MTDRoute *activeRouteBefore = self.directionsOverlay.activeRoute;

                [self.directionsOverlayView mtd_handleTapAtPoint:[tap locationInView:self.directionsOverlayView]];

                MTDRoute *activeRouteAfter = self.directionsOverlay.activeRoute;

                if (activeRouteBefore != activeRouteAfter) {
                    [self mtd_notifyDelegateDidActivateRoute:activeRouteAfter ofOverlay:self.directionsOverlay];
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

    UIColor *overlayColor = [self mtd_askDelegateForColorOfOverlay:self.directionsOverlay];
    CGFloat overlayLineWidthFactor = [self mtd_askDelegateForLineWidthFactorOfOverlay:self.directionsOverlay];
    Class directionsOverlayClass = MTDOverriddenClass([MTDDirectionsOverlayView class]);

    if (directionsOverlayClass != Nil) {
        self.directionsOverlayView = [[directionsOverlayClass alloc] initWithOverlay:self.directionsOverlay];
        self.directionsOverlayView.drawManeuvers = (self.directionsDisplayType == MTDDirectionsDisplayTypeDetailedManeuvers);

        // If we always set the color it breaks UIAppearance because it deactivates the proxy color if we
        // call the setter, even if we don't accept nil there.
        if (overlayColor != nil) {
            self.directionsOverlayView.overlayColor = overlayColor;
        }
        // same goes for the line width factor
        if (overlayLineWidthFactor > 0.f) {
            self.directionsOverlayView.overlayLineWidthFactor = overlayLineWidthFactor;
        }
    }

    return self.directionsOverlayView;
}

- (void)mtd_loadDirectionsFrom:(MTDWaypoint *)from
                            to:(MTDWaypoint *)to
                     routeType:(MTDDirectionsRouteType)routeType
          zoomToShowDirections:(BOOL)zoomToShowDirections
             intermediateGoals:(NSArray *)intermediateGoals
                       options:(NSUInteger)options {

    BOOL alternativeRoutes = (options & MTDDirectionsRequestOptionAlternativeRoutes) == MTDDirectionsRequestOptionAlternativeRoutes;

    if (alternativeRoutes) {
        MTDAssert(intermediateGoals.count == 0, @"Intermediate goals mustn't be specified when requesting alternative routes.");
    }

    __mtd_weak MTDMapView *weakSelf = self;

    [self.mtd_request cancel];

    if (from.valid && to.valid) {
        NSArray *allGoals = [self mtd_goalsByReplacingWaypointForCurrentLocationForFrom:from to:to intermediateGoals:intermediateGoals];

        [self mtd_stopUpdatingLocationCallingCompletion:NO];

        if (allGoals == nil) {
            // we have references to [MTDWaypoint waypointForCurrentLocation] within our goals, but no valid userLocation yet
            // so we first need to request the location using CLLocationManager and once we have a valid location we can load
            // the exact same directions again
            [self mtd_startUpdatingLocationWithCompletion:^{
                [self mtd_loadDirectionsFrom:from
                                          to:to
                                   routeType:routeType
                        zoomToShowDirections:zoomToShowDirections
                           intermediateGoals:intermediateGoals
                                     options:options];
            }];

            // do not request directions yet
            return;
        }

        self.mtd_request = [MTDDirectionsRequest requestDirectionsAPI:MTDDirectionsGetActiveAPI()
                                                                 from:MTDFirstObjectOfArray(allGoals)
                                                                   to:[allGoals lastObject]
                                                    intermediateGoals:allGoals.count > 2 ? [allGoals subarrayWithRange:NSMakeRange(1, allGoals.count - 2)] : nil
                                                            routeType:routeType
                                                              options:options
                                                           completion:^(MTDDirectionsOverlay *overlay, NSError *error) {
                                                               __strong MTDMapView *strongSelf = weakSelf;

                                                               if (overlay != nil && strongSelf != nil) {
                                                                   overlay = [strongSelf mtd_notifyDelegateDidFinishLoadingOverlay:overlay];

                                                                   strongSelf.directionsDisplayType = MTDDirectionsDisplayTypeOverview;
                                                                   strongSelf.directionsOverlay = overlay;

                                                                   if (zoomToShowDirections) {
                                                                       [strongSelf setRegionToShowDirectionsAnimated:YES];
                                                                   }
                                                               } else {
                                                                   [strongSelf mtd_notifyDelegateDidFailLoadingOverlayWithError:error];
                                                               }
                                                           }];

        [self mtd_notifyDelegateWillStartLoadingDirectionsFrom:from to:to routeType:routeType];
        [self.mtd_request start];
    }
}

- (NSArray *)mtd_goalsByReplacingWaypointForCurrentLocationForFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to intermediateGoals:(NSArray *)intermediateGoals {
    NSMutableArray *allGoals = [NSMutableArray arrayWithObject:from];

    if (intermediateGoals.count > 0) {
        [allGoals addObjectsFromArray:intermediateGoals];
    }

    [allGoals addObject:to];

    NSIndexSet *indexesOfWaypointsForCurrentLocation = [allGoals indexesOfObjectsPassingTest:^BOOL(MTDWaypoint *waypoint, __unused NSUInteger idx, __unused BOOL *stop) {
        return waypoint == [MTDWaypoint waypointForCurrentLocation];
    }];

    if (indexesOfWaypointsForCurrentLocation.count > 0) {
        // if we already have a valid user location replace the references to waypointForCurrentLocation with the actual location
        if (CLLocationCoordinate2DIsValid(self.mtd_delegateProxy.lastKnownUserCoordinate)) {
            MTDLogVerbose(@"We already have a valid current location, no need to start CLLocationManager");

            NSMutableArray *validWaypoints = [NSMutableArray arrayWithCapacity:indexesOfWaypointsForCurrentLocation.count];

            for (NSUInteger idx = 0; idx < indexesOfWaypointsForCurrentLocation.count; idx++) {
                MTDWaypoint *waypoint = [MTDWaypoint waypointWithCoordinate:self.mtd_delegateProxy.lastKnownUserCoordinate];
                [validWaypoints addObject:waypoint];
            }

            [allGoals replaceObjectsAtIndexes:indexesOfWaypointsForCurrentLocation
                                  withObjects:validWaypoints];
        }

        // we have no valid user location, so we indicate that we need to get one first by returning nil
        else {
            return nil;
        }
    }

    return allGoals;
}

- (void)mtd_startUpdatingLocationWithCompletion:(dispatch_block_t)completion {
    if ([CLLocationManager locationServicesEnabled]) {

#if !TARGET_IPHONE_SIMULATOR
        if ([[CLLocationManager class] respondsToSelector:@selector(authorizationStatus)] &&
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
#endif

            // this introduces a temporary strong-reference cycle (a.k.a retain cycle) that will vanish once the locationManager succeeds or fails
            self.mtd_locationCompletion = completion;

            self.mtd_locationManager = [CLLocationManager new];
            self.mtd_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.mtd_locationManager.delegate = self.mtd_delegateProxy;

            [self.mtd_locationManager startUpdatingLocation];
            MTDLogVerbose(@"Location manager was started to get a location for [MTDWaypoint waypointForCurrentLocation]");

#if !TARGET_IPHONE_SIMULATOR
        }
#endif

    } else {
        MTDLogWarning(@"Wanted to request location, but either location Services are not enabled or we are not authorized to request location");
    }
}

- (void)mtd_stopUpdatingLocationCallingCompletion:(BOOL)callingCompletion {
    if (callingCompletion) {
        self.mtd_locationCompletion();
    }

    self.mtd_locationCompletion = nil;
    self.mtd_locationManager.delegate = nil;
    [self.mtd_locationManager stopUpdatingLocation];
    self.mtd_locationManager = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private Delegate Helper
////////////////////////////////////////////////////////////////////////

- (void)mtd_notifyDelegateWillStartLoadingDirectionsFrom:(MTDWaypoint *)from
                                                      to:(MTDWaypoint *)to
                                               routeType:(MTDDirectionsRouteType)routeType {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.willStartLoadingDirections) {
        [delegate mapView:self willStartLoadingDirectionsFrom:from to:to routeType:routeType];
    }

    // post corresponding notification
    NSDictionary *userInfo = (@{MTDDirectionsNotificationKeyFrom: from,
                              MTDDirectionsNotificationKeyTo: to,
                              MTDDirectionsNotificationKeyRouteType:@(routeType)});

    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewWillStartLoadingDirections
                                                                 object:self
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (MTDDirectionsOverlay *)mtd_notifyDelegateDidFinishLoadingOverlay:(MTDDirectionsOverlay *)overlay {
    MTDDirectionsOverlay *overlayToReturn = overlay;
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.didFinishLoadingOverlay) {
        overlayToReturn = [delegate mapView:self didFinishLoadingDirectionsOverlay:overlay];
    }

    // post corresponding notification
    NSDictionary *userInfo = @{MTDDirectionsNotificationKeyOverlay: overlay};
    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidFinishLoadingDirectionsOverlay
                                                                 object:self
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    // sanity check if delegate returned a valid overlay
    if ([overlayToReturn isKindOfClass:[MTDDirectionsOverlay class]]) {
        return overlayToReturn;
    } else {
        return overlay;
    }
}

- (void)mtd_notifyDelegateDidFailLoadingOverlayWithError:(NSError *)error {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.didFailLoadingOverlay) {
        [delegate mapView:self didFailLoadingDirectionsOverlayWithError:error];
    }

    // post corresponding notification
    NSDictionary *userInfo = @{MTDDirectionsNotificationKeyError: error};
    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidFailLoadingDirectionsOverlay
                                                                 object:self
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)mtd_notifyDelegateDidActivateRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.didActivateRouteOfOverlay) {
        [delegate mapView:self didActivateRoute:route ofDirectionsOverlay:overlay];
    }

    // post corresponding notification
    NSDictionary *userInfo = @{MTDDirectionsNotificationKeyOverlay: overlay, MTDDirectionsNotificationKeyRoute: route};
    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidActivateRouteOfDirectionsOverlay
                                                                 object:self
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (UIColor *)mtd_askDelegateForColorOfOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.colorForOverlay) {
        UIColor *color = [delegate mapView:self colorForDirectionsOverlay:overlay];
        
        // sanity check if delegate returned valid color
        if ([color isKindOfClass:[UIColor class]]) {
            return color;
        }
    }
    
    // nil doesn't get set as overlay color
    return nil;
}

- (CGFloat)mtd_askDelegateForLineWidthFactorOfOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;
    
    if (_directionsDelegateFlags.lineWidthFactorForOverlay) {
        CGFloat lineWidthFactor = [delegate mapView:self lineWidthFactorForDirectionsOverlay:overlay];
        return lineWidthFactor;
    }
    
    // doesn't get set as line width
    return -1.f;
}

@end
