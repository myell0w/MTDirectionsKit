#import "MTDMapView.h"
#import "MTDAddress.h"
#import "MTDWaypoint.h"
#import "MTDManeuver.h"
#import "MTDDistance.h"
#import "MTDDirectionsDelegate.h"
#import "MTDDirectionsRequest.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDDirectionsOverlay.h"
#import "MTDRoute.h"
#import "MTDDirectionsOverlayView.h"
#import "MTDDirectionsOverlayView+MTDirectionsPrivateAPI.h"
#import "MTDMapViewDelegateProxy.h"
#import "MTDFunctions.h"
#import "MTDManeuverInfoView.h"


#define kMTCircleMoveDuration       0.3


@interface MTDMapView () <MKMapViewDelegate> {
    // flags for methods implemented in the delegate
    struct {
        unsigned int willStartLoadingDirections:1;
        unsigned int didFinishLoadingOverlay:1;
        unsigned int didFailLoadingOverlay:1;
        unsigned int colorForOverlay:1;
        unsigned int lineWidthFactorForOverlay:1;
	} _directionsDelegateFlags;
}

@property (nonatomic, strong, readwrite) MTDDirectionsOverlayView *directionsOverlayView; // re-defined as read/write


@property (nonatomic, assign) NSUInteger activeManeuverIndex;
@property (nonatomic, strong) UIImageView *circleView;
@property (nonatomic, strong) MTDManeuverInfoView *maneuverInfoView;

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

////////////////////////////////////////////////////////////////////////
#pragma mark - Maneuvers
////////////////////////////////////////////////////////////////////////

- (BOOL)showNextManeuver {
    if (self.directionsDisplayType != MTDDirectionsDisplayTypeDetailedManeuvers) {
        // this call updates the UI to show first maneuver
        self.directionsDisplayType = MTDDirectionsDisplayTypeDetailedManeuvers;
        return YES;
    }
    
    NSUInteger activeManeuverIndex = self.activeManeuverIndex;
    
    if (activeManeuverIndex >= self.directionsOverlay.maneuvers.count - 1) {
        return NO;
    }
    
    activeManeuverIndex++;
    self.activeManeuverIndex = activeManeuverIndex;
    [self mtd_showManeuverStartingFromIndex:activeManeuverIndex];
    
    return YES;
}

- (BOOL)showPreviousManeuver {
    NSUInteger activeManeuverIndex = self.activeManeuverIndex;
    
    if (activeManeuverIndex == 0) {
        return NO;
    }
    
    activeManeuverIndex--;
    self.activeManeuverIndex = activeManeuverIndex;
    [self mtd_showManeuverStartingFromIndex:activeManeuverIndex];
    
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Region
////////////////////////////////////////////////////////////////////////

- (void)setRegionToShowDirectionsAnimated:(BOOL)animated {
    [self setVisibleMapRect:self.directionsOverlay.boundingMapRect edgePadding:UIEdgeInsetsZero animated:animated];
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
        _directionsDelegateFlags.willStartLoadingDirections = (unsigned int)[_directionsDelegate respondsToSelector:@selector(mapView:willStartLoadingDirectionsFrom:to:routeType:)];
        _directionsDelegateFlags.didFinishLoadingOverlay = (unsigned int)[_directionsDelegate respondsToSelector:@selector(mapView:didFinishLoadingDirectionsOverlay:)];
        _directionsDelegateFlags.didFailLoadingOverlay = (unsigned int)[_directionsDelegate respondsToSelector:@selector(mapView:didFailLoadingDirectionsOverlayWithError:)];
        _directionsDelegateFlags.colorForOverlay = (unsigned int)[_directionsDelegate respondsToSelector:@selector(mapView:colorForDirectionsOverlay:)];
        _directionsDelegateFlags.lineWidthFactorForOverlay = (unsigned int)[_directionsDelegate respondsToSelector:@selector(mapView:lineWidthFactorForDirectionsOverlay:)];
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

- (UIImageView *)circleView {
    if (_circleView == nil) {
        _circleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MTDirectionsKit.bundle/DirectionsCircleShiny"]];
        [self addSubview:_circleView];
    }
    
    [self bringSubviewToFront:_circleView];
    
    return _circleView;
}

- (MTDManeuverInfoView *)maneuverInfoView {
    if (_maneuverInfoView == nil) {
        _maneuverInfoView = [MTDManeuverInfoView infoViewForMapView:self];
        [self addSubview:_maneuverInfoView];
    }
    
    [self bringSubviewToFront:_maneuverInfoView];
    
    return _maneuverInfoView;
}

- (CLLocationCoordinate2D)fromCoordinate {
    if (self.directionsOverlay != nil) {
        return self.directionsOverlay.fromCoordinate;
    }

    return kCLLocationCoordinate2DInvalid;
}

- (CLLocationCoordinate2D)toCoordinate {
    if (self.directionsOverlay != nil) {
        return self.directionsOverlay.toCoordinate;
    }

    return kCLLocationCoordinate2DInvalid;
}

- (double)distanceInMeter {
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

- (BOOL)openDirectionsInMapApp {
    if (self.directionsOverlay != nil) {
        return MTDDirectionsOpenInMapsApp(self.directionsOverlay.activeRoute.from,
                                          self.directionsOverlay.activeRoute.to,
                                          self.directionsOverlay.routeType);
    }

    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate Proxies
////////////////////////////////////////////////////////////////////////

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [self.mtd_trueDelegate mapView:mapView regionWillChangeAnimated:animated];
    }
    
    self.circleView.alpha = 0.f;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [self.mtd_trueDelegate mapView:mapView regionDidChangeAnimated:animated];
    }
    
    if (self.activeManeuverIndex != NSNotFound && self.directionsDisplayType == MTDDirectionsDisplayTypeDetailedManeuvers) {
        MTDManeuver *activeManeuver = [self.directionsOverlay.maneuvers objectAtIndex:self.activeManeuverIndex];
        CGPoint circlePoint = [self convertCoordinate:activeManeuver.coordinate toPointToView:self];
        
        self.circleView.alpha = 1.f;
        self.circleView.center = circlePoint;
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]) {
        [self.mtd_trueDelegate mapViewWillStartLoadingMap:mapView];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [self.mtd_trueDelegate mapViewDidFinishLoadingMap:mapView];
    }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapViewDidFailLoadingMap:withError:)]) {
        [self.mtd_trueDelegate mapViewDidFailLoadingMap:mapView withError:error];
    }
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [self.mtd_trueDelegate mapViewWillStartLocatingUser:mapView];
    }
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [self.mtd_trueDelegate mapViewDidStopLocatingUser:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)]) {
        [self.mtd_trueDelegate mapView:mapView didUpdateUserLocation:userLocation];
    }

    self.mtd_delegateProxy.lastKnownUserCoordinate = userLocation.coordinate;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]) {
        [self.mtd_trueDelegate mapView:mapView didFailToLocateUserWithError:error];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        return [self.mtd_trueDelegate mapView:mapView viewForAnnotation:annotation];
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [self.mtd_trueDelegate mapView:mapView didAddAnnotationViews:views];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
        [self.mtd_trueDelegate mapView:mapView annotationView:view calloutAccessoryControlTapped:control];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)]) {
        [self.mtd_trueDelegate mapView:mapView annotationView:annotationView didChangeDragState:newState fromOldState:oldState];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [self.mtd_trueDelegate mapView:mapView didSelectAnnotationView:view];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [self.mtd_trueDelegate mapView:mapView didDeselectAnnotationView:view];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    // first check if the delegate provides a custom annotation
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:viewForOverlay:)]) {
        MKOverlayView *delegateResult = [self.mtd_trueDelegate mapView:mapView viewForOverlay:overlay];

        if (delegateResult != nil) {
            return delegateResult;
        }
    }

    // otherwise provide a default overlay for directions
    if ([overlay isKindOfClass:[MTDDirectionsOverlay class]]) {
        return [self mtd_viewForDirectionsOverlay:overlay];
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    if ([self.mtd_trueDelegate respondsToSelector:@selector(mapView:didAddOverlayViews:)]) {
        [self.mtd_trueDelegate mapView:mapView didAddOverlayViews:overlayViews];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    // we set ourself as the delegate
    [super setDelegate:self];

    _directionsDisplayType = MTDDirectionsDisplayTypeNone;
    _activeManeuverIndex = NSNotFound;
    _mtd_delegateProxy = [[MTDMapViewDelegateProxy alloc] initWithMapView:self];

    // we need this GestureRecognizer to be able to select alternative routes
    _mtd_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mtd_handleMapTap:)];
    _mtd_tapGestureRecognizer.enabled = NO;
    _mtd_tapGestureRecognizer.delegate = _mtd_delegateProxy;

    // we require all gesture recognizer except other single-tap gesture recognizers to fail
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
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
                [self.directionsOverlayView mtd_handleTapAtPoint:[tap locationInView:self.directionsOverlayView]];
            }
        }
    }
}

- (void)mtd_updateUIForDirectionsDisplayType:(MTDDirectionsDisplayType) __unused displayType {
    if (_directionsOverlay != nil) {
        [self removeOverlay:_directionsOverlay];
        _directionsOverlayView = nil;
        [self addOverlay:_directionsOverlay];

        switch (displayType) {
            case MTDDirectionsDisplayTypeOverview: {
                self.activeManeuverIndex = NSNotFound;
                break;
            }

            case MTDDirectionsDisplayTypeDetailedManeuvers: {
                self.activeManeuverIndex = 0;
                [self mtd_showManeuverStartingFromIndex:0];
                break;
            }

            case MTDDirectionsDisplayTypeNone:
            default: {
                self.activeManeuverIndex = NSNotFound;
                break;
            }
        }
    }
}

// TODO: Implement method
- (void)mtd_showManeuverStartingFromIndex:(NSUInteger)maneuverStartIndex {
    NSUInteger maneuverEndIndex = maneuverStartIndex + 1;
    
    if (maneuverEndIndex < self.directionsOverlay.maneuvers.count) {
        MTDManeuver *startManeuver = [self.directionsOverlay.maneuvers objectAtIndex:maneuverStartIndex];
        // MTDManeuver *endManeuver = [self.directionsOverlay.maneuvers objectAtIndex:maneuverEndIndex];
        // NSArray *waypoints = @[startManeuver.waypoint, endManeuver.waypoint];
        CGPoint circlePoint = [self convertCoordinate:startManeuver.coordinate toPointToView:self];
        
        self.maneuverInfoView.infoText = [NSString stringWithFormat:@"Distanz: %f", startManeuver.distance];
        
        [UIView animateWithDuration:kMTCircleMoveDuration
                         animations:^{
                             self.circleView.center = circlePoint;
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 /*[self setRegionFromWaypoints:waypoints
                                                  edgePadding:UIEdgeInsetsMake(10.f,10.f,10.f,10.f)
                                                     animated:YES];*/
                             }
                         }];
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

    self.directionsOverlayView = [[MTDDirectionsOverlayView alloc] initWithOverlay:self.directionsOverlay];
    self.directionsOverlayView.drawManeuvers = (self.directionsDisplayType == MTDDirectionsDisplayTypeDetailedManeuvers);
    self.directionsOverlayView.overlayColor = [self mtd_askDelegateForColorOfOverlay:self.directionsOverlay];
    self.directionsOverlayView.overlayLineWidthFactor = [self mtd_askDelegateForLineWidthFactorOfOverlay:self.directionsOverlay];

    return self.directionsOverlayView;
}

/**
 Internal helper method that performs the work needed to load directions, depending on the set parameter.

 @param alternativeDirections this flag determines whether alternative directions are used or not
 */
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
    if (_directionsDelegateFlags.willStartLoadingDirections) {
        [self.directionsDelegate mapView:self willStartLoadingDirectionsFrom:from to:to routeType:routeType];
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

    if (_directionsDelegateFlags.didFinishLoadingOverlay) {
        overlayToReturn = [self.directionsDelegate mapView:self didFinishLoadingDirectionsOverlay:overlay];
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
    if (_directionsDelegateFlags.didFailLoadingOverlay) {
        [self.directionsDelegate mapView:self didFailLoadingDirectionsOverlayWithError:error];
    }

    // post corresponding notification
    NSDictionary *userInfo = @{MTDDirectionsNotificationKeyError: error};
    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidFailLoadingDirectionsOverlay
                                                                 object:self
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (UIColor *)mtd_askDelegateForColorOfOverlay:(MTDDirectionsOverlay *)overlay {
    if (_directionsDelegateFlags.colorForOverlay) {
        UIColor *color = [self.directionsDelegate mapView:self colorForDirectionsOverlay:overlay];
        
        // sanity check if delegate returned valid color
        if ([color isKindOfClass:[UIColor class]]) {
            return color;
        }
    }
    
    // nil doesn't get set as overlay color
    return nil;
}

- (CGFloat)mtd_askDelegateForLineWidthFactorOfOverlay:(MTDDirectionsOverlay *)overlay {
    if (_directionsDelegateFlags.lineWidthFactorForOverlay) {
        CGFloat lineWidthFactor = [self.directionsDelegate mapView:self lineWidthFactorForDirectionsOverlay:overlay];
        return lineWidthFactor;
    }

    // doesn't get set as line width
    return -1.f;
}

@end
