#import "MTDGMSMapView.h"
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
#import "MTDRoute+MTDGoogleMapsSDK.h"
#import "MTDGMSDirectionsOverlayView.h"
#import "MTDDirectionsOverlayView+MTDirectionsPrivateAPI.h"
#import "MTDMapViewDelegateProxy.h"
#import "MTDFunctions.h"
#import "MTDCustomization.h"
#import "MTDInterApp.h"


@interface GMSMapView (MTDGoogleMapsSDK)

// the not exposed, but designated initializer of GMSMapView. we declare it here to keep the compiler silent
- (id)initWithFrame:(CGRect)frame camera:(GMSCameraPosition *)camera;

@end

@interface MTDGMSMapView () <GMSMapViewDelegate> {
    // flags for methods implemented in the delegate
    struct {
        unsigned int willStartLoadingDirections:1;
        unsigned int didFinishLoadingOverlay:1;
        unsigned int didFailLoadingOverlay:1;
        unsigned int shouldActivateRouteOfOverlay:1;
        unsigned int didActivateRouteOfOverlay:1;
        unsigned int colorForRoute:1;
        unsigned int lineWidthFactorForOverlay:1;
        unsigned int didUpdateUserLocationWithDistance:1;
	} _directionsDelegateFlags;
}

@property (nonatomic, strong) NSMutableDictionary *directionsOverlayViews;

/** The delegate that was set by the user, we forward all delegate calls */
@property (nonatomic, mtd_weak, setter = mtd_setTrueDelegate:) id<GMSMapViewDelegate> mtd_trueDelegate;
/** The request object for retreiving directions from the specified API */
@property (nonatomic, strong, setter = mtd_setRequest:) MTDDirectionsRequest *mtd_request;

/** the delegate proxy for CLLocationManagerDelegate and UIGestureRecognizerDelegate */
@property (nonatomic, strong) MTDMapViewDelegateProxy *mtd_delegateProxy;
/** The location manager used to request user location if needed */
@property (nonatomic, strong) CLLocationManager *mtd_locationManager;
/** The completion block executed after we found a location */
@property (nonatomic, copy) dispatch_block_t mtd_locationCompletion;

@end


@implementation MTDGMSMapView

@synthesize directionsOverlay = _directionsOverlay;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame camera:(GMSCameraPosition *)camera {
    if ((self = [super initWithFrame:frame camera:camera])) {
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (void)loadDirectionsFrom:(MTDWaypoint *)from
                        to:(MTDWaypoint *)to
         intermediateGoals:(NSArray *)intermediateGoals
             optimizeRoute:(BOOL)optimizeRoute
                 routeType:(MTDDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections {

    [self loadDirectionsFrom:from
                          to:to
           intermediateGoals:intermediateGoals
                   routeType:routeType
                     options:optimizeRoute ? MTDDirectionsRequestOptionOptimizeRoute : MTDDirectionsRequestOptionNone
        zoomToShowDirections:zoomToShowDirections];
}

#pragma clang diagnostic pop

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

    BOOL alternativeRoutes = (options & _MTDDirectionsRequestOptionAlternativeRoutes) == _MTDDirectionsRequestOptionAlternativeRoutes;

    if (alternativeRoutes) {
        MTDAssert(intermediateGoals.count == 0, @"Intermediate goals mustn't be specified when requesting alternative routes.");
    }

    [self.mtd_request cancel];

    if (from.valid && to.valid) {
        NSArray *allGoals = [self mtd_allGoalsWithFrom:from to:to intermediateGoals:intermediateGoals];

        [self mtd_stopUpdatingLocationCallingCompletion:NO];

        if (allGoals == nil) {
            // we have references to [MTDWaypoint waypointForCurrentLocation] within our goals, but no valid userLocation yet
            // so we first need to request the location using CLLocationManager and once we have a valid location we can load
            // the exact same directions again
            [self mtd_startUpdatingLocationWithCompletion:^{
                [self loadDirectionsFrom:from
                                      to:to
                       intermediateGoals:intermediateGoals
                               routeType:routeType
                                 options:options
                    zoomToShowDirections:zoomToShowDirections];
            }];

            // do not request directions yet
            return;
        }

        __mtd_weak MTDGMSMapView *weakSelf = self;
        self.mtd_request = [MTDDirectionsRequest requestDirectionsAPI:MTDDirectionsGetActiveAPI()
                                                                 from:MTDFirstObjectOfArray(allGoals)
                                                                   to:[allGoals lastObject]
                                                    intermediateGoals:allGoals.count > 2 ? [allGoals subarrayWithRange:NSMakeRange(1, allGoals.count - 2)] : nil
                                                            routeType:routeType
                                                              options:options
                                                           completion:^(MTDDirectionsOverlay *overlay, NSError *error) {
                                                               __strong MTDGMSMapView *strongSelf = weakSelf;

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

- (void)cancelLoadOfDirections {
    [self.mtd_request cancel];
    self.mtd_request = nil;

    [self mtd_stopUpdatingLocationCallingCompletion:NO];
}

- (void)removeDirectionsOverlay {
    for (MTDGMSDirectionsOverlayView *overlayView in [_directionsOverlayViews allValues]) {
        overlayView.map = nil;
    }

    _directionsOverlay = nil;
    _directionsOverlayViews = nil;
}

- (MTDGMSDirectionsOverlayView *)directionsOverlayViewForRoute:(MTDRoute *)route {
    return self.directionsOverlayViews[route];
}

- (void)activateRoute:(MTDRoute *)route {
    // TODO: GoogleMapsSDK
    MTDRoute *activeRouteBefore = self.directionsOverlay.activeRoute;

    if (route != nil && route != activeRouteBefore) {
        [self.directionsOverlay mtd_activateRoute:route];
        MTDRoute *activeRouteAfter = self.directionsOverlay.activeRoute;

        if (activeRouteBefore != activeRouteAfter) {
            [self mtd_notifyDelegateDidActivateRoute:activeRouteAfter ofOverlay:self.directionsOverlay];

            // Update colors depending on active state
            for (MTDRoute *r in self.directionsOverlay.routes) {
                UIColor *color = [self mtd_askDelegateForColorOfRoute:r ofOverlay:self.directionsOverlay];
                MTDGMSDirectionsOverlayView *overlayView = [self directionsOverlayViewForRoute:r];

                overlayView.strokeColor = color;
            }
        }
    }
}

- (CGFloat)distanceBetweenActiveRouteAndCoordinate:(CLLocationCoordinate2D)coordinate {
    // TODO: GoogleMapsSDK
    //    MTDAssert(CLLocationCoordinate2DIsValid(coordinate), @"We can't measure distance to invalid coordinates");
    //
    //    MTDRoute *activeRoute = self.directionsOverlay.activeRoute;
    //
    //    if (activeRoute == nil || !CLLocationCoordinate2DIsValid(coordinate)) {
    //        return FLT_MAX;
    //    }
    //
    //    CGPoint point = [self convertCoordinate:coordinate toPointToView:self.directionsOverlayView];
    //    CGFloat distance = [self.directionsOverlayView distanceBetweenPoint:point route:self.directionsOverlay.activeRoute];
    //
    //    return distance;
    return 0.f;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Region
////////////////////////////////////////////////////////////////////////

- (void)setRegionToShowDirectionsAnimated:(BOOL)animated {
    GMSPath *path = self.directionsOverlay.activeRoute.path;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:self.directionsEdgePadding];

    if (animated) {
        [self animateWithCameraUpdate:update];
    } else {
        [self moveCamera:update];
    }
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
            [self mtd_addOverlay:directionsOverlay];
        }
    }
}

- (void)setDirectionsDisplayType:(MTDDirectionsDisplayType)directionsDisplayType {
    if (directionsDisplayType != _directionsDisplayType) {
        _directionsDisplayType = directionsDisplayType;
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
        _directionsDelegateFlags.shouldActivateRouteOfOverlay = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:shouldActivateRoute:ofDirectionsOverlay:)];
        _directionsDelegateFlags.didActivateRouteOfOverlay = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:didActivateRoute:ofDirectionsOverlay:)];
        _directionsDelegateFlags.colorForRoute = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:colorForRoute:ofDirectionsOverlay:)];
        _directionsDelegateFlags.lineWidthFactorForOverlay = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:lineWidthFactorForDirectionsOverlay:)];
        _directionsDelegateFlags.didUpdateUserLocationWithDistance = (unsigned int)[directionsDelegate respondsToSelector:@selector(mapView:didUpdateUserLocation:distanceToActiveRoute:ofDirectionsOverlay:)];
    }
}

- (void)setDelegate:(id<GMSMapViewDelegate>)delegate {
    if (delegate != _mtd_trueDelegate) {
        _mtd_trueDelegate = delegate;

        // if we haven't set a directionsDelegate and our delegate conforms to the protocol
        // MTDDirectionsDelegate, then we automatically set our directionsDelegate
        if (self.directionsDelegate == nil && [delegate conformsToProtocol:@protocol(MTDDirectionsDelegate)]) {
            self.directionsDelegate = (id<MTDDirectionsDelegate>)delegate;
        }
    }
}

- (id<GMSMapViewDelegate>)delegate {
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
#pragma mark - GMSMapViewDelegate Proxies
////////////////////////////////////////////////////////////////////////


/**
 * Called after the camera position has changed. During an animation, this
 * delegate might not be notified of intermediate camera positions. However, it
 * will always be called eventually with the final position of an the animation.
 */
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didChangeCameraPosition:)]) {
        [trueDelegate mapView:mapView didChangeCameraPosition:position];
    }
}

/**
 * Called after a tap gesture at a particular coordinate, but only if a marker
 * was not tapped.  This is called before deselecting any currently selected
 * marker (the implicit action for tapping on the map).
 */
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didTapAtCoordinate:)]) {
        [trueDelegate mapView:mapView didTapAtCoordinate:coordinate];
    }
}

/**
 * Called after a long-press gesture at a particular coordinate.
 *
 * @param mapView The map view that was pressed.
 * @param coordinate The location that was pressed.
 */
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didLongPressAtCoordinate:)]) {
        [trueDelegate mapView:mapView didLongPressAtCoordinate:coordinate];
    }
}

/**
 * Called after a marker has been tapped.
 *
 * @param mapView The map view that was pressed.
 * @param marker The marker that was pressed.
 * @return YES if this delegate handled the tap event, which prevents the map
 *         from performing its default selection behavior, and NO if the map
 *         should continue with its default selection behavior.
 */
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didTapMarker:)]) {
        return [trueDelegate mapView:mapView didTapMarker:marker];
    }

    return NO;
}

/**
 * Called after a marker's info window has been tapped.
 */
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didTapInfoWindowOfMarker:)]) {
        [trueDelegate mapView:mapView didTapInfoWindowOfMarker:marker];
    }
}

/**
 * Called after an overlay has been tapped.
 * This method is not called for taps on markers.
 *
 * @param mapView The map view that was pressed.
 * @param overlay The overlay that was pressed.
 */
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;
    __block MTDRoute *routeToActivate = nil;

    [self.directionsOverlayViews enumerateKeysAndObjectsUsingBlock:^(MTDRoute *route, MTDGMSDirectionsOverlayView *overlayView, BOOL *stop) {
        if (overlay == overlayView) {
            routeToActivate = route;
            *stop = YES;
        }
    }];

    [self activateRoute:routeToActivate];

    if ([trueDelegate respondsToSelector:@selector(mapView:didTapOverlay:)]) {
        [trueDelegate mapView:mapView didTapOverlay:overlay];
    }
}

/**
 * Called when a marker is about to become selected, and provides an optional
 * custom info window to use for that marker if this method returns a UIView.
 * If you change this view after this method is called, those changes will not
 * necessarily be reflected in the rendered version.
 *
 * The returned UIView must not have bounds greater than 500 points on either
 * dimension.  As there is only one info window shown at any time, the returned
 * view may be reused between other info windows.
 *
 * @return The custom info window for the specified marker, or nil for default
 */
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:markerInfoWindow:)]) {
        [trueDelegate mapView:mapView markerInfoWindow:marker];
    }

    return nil;
}

//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
//    id<MKMapViewDelegate> trueDelegate = self.mtd_trueDelegate;
//    BOOL overlayIsDirectionsOverlay = [overlay isKindOfClass:[MTDDirectionsOverlay class]];
//
//    // first check if the delegate provides a custom overlay view
//    if ([trueDelegate respondsToSelector:@selector(mapView:viewForOverlay:)]) {
//        MKOverlayView *delegateResult = [trueDelegate mapView:mapView viewForOverlay:overlay];
//
//        if (delegateResult != nil) {
//            if (overlayIsDirectionsOverlay) {
//                MTDLogInfo(@"MKMapViewDelegate provided a custom overlay view for MTDDirectionsOverlay, make sure this is really what you want.");
//            }
//
//            return delegateResult;
//        }
//    }
//
//    // otherwise provide a default overlay for directions
//    if (overlayIsDirectionsOverlay) {
//        return [self mtd_viewForDirectionsOverlay:overlay];
//    }
//
//    return nil;
//}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    // we set ourself as the delegate
    [super setDelegate:self];

    _directionsDisplayType = MTDDirectionsDisplayTypeNone;
    _directionsEdgePadding = 35.f;
    // TODO: GoogleMapsSDK
    //_mtd_delegateProxy = [[MTDMapViewDelegateProxy alloc] initWithMapView:self];
}

- (void)mtd_addOverlay:(MTDDirectionsOverlay *)overlay {
    self.directionsOverlayViews = [NSMutableDictionary dictionaryWithCapacity:overlay.routes.count];

    for (MTDRoute *route in overlay.routes) {
        MTDGMSDirectionsOverlayView *overlayView = [self mtd_viewForRoute:route];

        self.directionsOverlayViews[route] = overlayView;
        overlayView.map = self;
    }
}

// TODO: GoogleMapsSDK
//- (void)mtd_handleMapTap:(UITapGestureRecognizer *)tap {
//    if ((tap.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
//        // Check if the directionsOverlay got tapped
//        if (self.directionsOverlayView != nil) {
//            // Get view frame rect in the mapView's coordinate system
//            CGRect viewFrameInMapView = [self.directionsOverlayView.superview convertRect:self.directionsOverlayView.frame toView:self];
//            // Get touch point in the mapView's coordinate system
//            CGPoint point = [tap locationInView:self];
//
//            // we outset the frame of the overlay to also handle touches that are a bit outside
//            viewFrameInMapView = CGRectInset(viewFrameInMapView, -50.f, -50.f);
//
//            // Check if the touch is within the view bounds
//            if (CGRectContainsPoint(viewFrameInMapView, point)) {
//                MTDRoute *selectedRoute = [self.directionsOverlayView mtd_routeTouchedByPoint:[tap locationInView:self.directionsOverlayView]];
//
//                // ask delegate if we should activate the route
//                if ([self mtd_askDelegateForSelectionEnabledStateOfRoute:selectedRoute ofOverlay:self.directionsOverlay]) {
//                    [self activateRoute:selectedRoute];
//                }
//            }
//        }
//    }
//}

- (void)mtd_updateUIForDirectionsDisplayType:(MTDDirectionsDisplayType) __unused displayType {
    // TODO: GoogleMapsSDK
    //    _directionsOverlayView.map = nil;
    //
    //    if (displayType != MTDDirectionsDisplayTypeNone) {
    //        _directionsOverlayView.map = nil;
    //    }
}

- (MTDGMSDirectionsOverlayView *)mtd_viewForRoute:(MTDRoute *)route {
    // don't display anything if display type is set to none
    if (self.directionsDisplayType == MTDDirectionsDisplayTypeNone) {
        return nil;
    }

    if (![route isKindOfClass:[MTDRoute class]] || self.directionsOverlay == nil) {
        return nil;
    }

    CGFloat overlayLineWidthFactor = [self mtd_askDelegateForLineWidthFactorOfOverlay:self.directionsOverlay];
    // TODO: GoogleMapsSDK
    // Class directionsOverlayClass = MTDOverriddenClass([MTDDirectionsOverlayView class]);

    MTDGMSDirectionsOverlayView *overlayView = [[MTDGMSDirectionsOverlayView alloc] initWithDirectionsOverlay:self.directionsOverlay route:route];
    UIColor *overlayColor = [self mtd_askDelegateForColorOfRoute:route ofOverlay:self.directionsOverlay];

    // If we always set the color it breaks UIAppearance because it deactivates the proxy color if we
    // call the setter, even if we don't accept nil there.
    if (overlayColor != nil) {
        overlayView.strokeColor = overlayColor;
    }
    // same goes for the line width factor
    if (overlayLineWidthFactor > 0.f) {
        overlayView.overlayLineWidthFactor = overlayLineWidthFactor;
    }

    return overlayView;
}

// returns nil if there are reference to [MTDWaypoint waypointForCurrentLocation] and we have no valid user location yet
- (NSArray *)mtd_allGoalsWithFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to intermediateGoals:(NSArray *)intermediateGoals {
    NSMutableArray *allGoals = [NSMutableArray arrayWithObject:from];

    if (intermediateGoals.count > 0) {
        [allGoals addObjectsFromArray:intermediateGoals];
    }

    [allGoals addObject:to];

    NSIndexSet *indexesOfWaypointsForCurrentLocation = [allGoals indexesOfObjectsPassingTest:^BOOL(MTDWaypoint *waypoint, __unused NSUInteger idx, __unused BOOL *stop) {
        return [waypoint isWaypointForCurrentLocation];
    }];

    // check if we have references to the current location in the array but no valid user location.
    // in this case we indicate that we need to get one first by returning nil
    if (indexesOfWaypointsForCurrentLocation.count > 0) {
        if (![MTDWaypoint waypointForCurrentLocation].hasValidCoordinate) {
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
                              MTDDirectionsNotificationKeyRouteType: @(routeType)});

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

- (BOOL)mtd_askDelegateForSelectionEnabledStateOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (route == nil || overlay == nil) {
        return NO;
    }

    if (_directionsDelegateFlags.shouldActivateRouteOfOverlay) {
        return [delegate mapView:self shouldActivateRoute:route ofDirectionsOverlay:overlay];
    } else {
        return YES;
    }
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

- (UIColor *)mtd_askDelegateForColorOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.colorForRoute) {
        UIColor *color = [delegate mapView:self colorForRoute:route ofDirectionsOverlay:overlay];

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

- (void)mtd_notifyDelegateDidUpdateUserLocation:(MKUserLocation *)userLocation {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;
    CGFloat distance = [self distanceBetweenActiveRouteAndCoordinate:userLocation.coordinate];

    if (distance != FLT_MAX) {
        if (_directionsDelegateFlags.didUpdateUserLocationWithDistance) {
            [delegate mapView:self didUpdateUserLocation:userLocation distanceToActiveRoute:distance ofDirectionsOverlay:self.directionsOverlay];
        }

        // post corresponding notification
        NSDictionary *userInfo = (@{
                                  MTDDirectionsNotificationKeyUserLocation: userLocation,
                                  MTDDirectionsNotificationKeyDistanceToActiveRoute: @(distance),
                                  MTDDirectionsNotificationKeyOverlay: self.directionsOverlay,
                                  MTDDirectionsNotificationKeyRoute: self.directionsOverlay.activeRoute
                                  });
        NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidUpdateUserLocationWithDistanceToActiveRoute
                                                                     object:self
                                                                   userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

@end
