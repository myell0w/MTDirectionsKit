#import "MTDMapViewProxy.h"
#import "MTDDirectionsDelegate.h"
#import "MTDMapView.h"
#import "MTDDirectionsOverlay.h"
#import "MTDWaypoint.h"
#import "MTDWaypoint+MTDirectionsPrivateAPI.h"
#import "MTDDirectionsRequest.h"
#import "MTDFunctions.h"


@interface MTDMapViewProxy () {
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

/** The location manager used to request user location if needed */
@property (nonatomic, strong) CLLocationManager *mtd_locationManager;
/** The completion block executed after we found a location */
@property (nonatomic, copy) dispatch_block_t mtd_locationCompletion;

/** The request object for retreiving directions from the specified API */
@property (nonatomic, strong, setter = mtd_setRequest:) MTDDirectionsRequest *mtd_request;

@end


@implementation MTDMapViewProxy

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithMapView:(id<MTDMapView>)mapView {
    if ((self = [super init])) {
        _mapView = mapView;
    }

    return self;
}

- (void)dealloc {
    _directionsDelegate = nil;
    _mtd_locationManager.delegate = nil;
    _mtd_locationCompletion = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Directions
////////////////////////////////////////////////////////////////////////

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

        [self stopUpdatingLocationCallingCompletion:NO];

        if (allGoals == nil) {
            // we have references to [MTDWaypoint waypointForCurrentLocation] within our goals, but no valid userLocation yet
            // so we first need to request the location using CLLocationManager and once we have a valid location we can load
            // the exact same directions again
            [self startUpdatingLocationWithCompletion:^{
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

        __mtd_weak __typeof__(self) weakSelf = self;
        self.mtd_request = [MTDDirectionsRequest requestDirectionsAPI:MTDDirectionsGetActiveAPI()
                                                                 from:MTDFirstObjectOfArray(allGoals)
                                                                   to:[allGoals lastObject]
                                                    intermediateGoals:allGoals.count > 2 ? [allGoals subarrayWithRange:NSMakeRange(1, allGoals.count - 2)] : nil
                                                            routeType:routeType
                                                              options:options
                                                           completion:^(MTDDirectionsOverlay *overlay, NSError *error) {
                                                               __strong __typeof__(self) strongSelf = weakSelf;
                                                               __strong __typeof__(strongSelf.mapView) mapView = strongSelf.mapView;

                                                               if (overlay != nil && strongSelf != nil) {
                                                                   overlay = [strongSelf notifyDelegateDidFinishLoadingOverlay:overlay];

                                                                   mapView.directionsDisplayType = MTDDirectionsDisplayTypeOverview;
                                                                   mapView.directionsOverlay = overlay;

                                                                   if (zoomToShowDirections) {
                                                                       [mapView setRegionToShowDirectionsAnimated:YES];
                                                                   }
                                                               } else {
                                                                   [strongSelf notifyDelegateDidFailLoadingOverlayWithError:error];
                                                               }
                                                           }];

        [self notifyDelegateWillStartLoadingDirectionsFrom:from to:to routeType:routeType];
        [self.mtd_request start];
    }
}

- (void)cancelLoadOfDirections {
    [self.mtd_request cancel];
    self.mtd_request = nil;

    [self stopUpdatingLocationCallingCompletion:NO];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Location handling
////////////////////////////////////////////////////////////////////////

- (void)startUpdatingLocationWithCompletion:(dispatch_block_t)completion {
    if ([CLLocationManager locationServicesEnabled]) {

#if !TARGET_IPHONE_SIMULATOR
        if ([[CLLocationManager class] respondsToSelector:@selector(authorizationStatus)] &&
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
#endif

            // this introduces a temporary strong-reference cycle (a.k.a retain cycle) that will vanish once the locationManager succeeds or fails
            self.mtd_locationCompletion = completion;

            self.mtd_locationManager = [CLLocationManager new];
            self.mtd_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.mtd_locationManager.delegate = self;

            [self.mtd_locationManager startUpdatingLocation];
            MTDLogVerbose(@"Location manager was started to get a location for [MTDWaypoint waypointForCurrentLocation]");

#if !TARGET_IPHONE_SIMULATOR
        }
#endif

    } else {
        MTDLogWarning(@"Wanted to request location, but either location Services are not enabled or we are not authorized to request location");
    }
}

- (void)stopUpdatingLocationCallingCompletion:(BOOL)callingCompletion {
    if (callingCompletion) {
        self.mtd_locationCompletion();
    }

    self.mtd_locationCompletion = nil;
    self.mtd_locationManager.delegate = nil;
    [self.mtd_locationManager stopUpdatingLocation];
    self.mtd_locationManager = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate Helper
////////////////////////////////////////////////////////////////////////

- (void)notifyDelegateWillStartLoadingDirectionsFrom:(MTDWaypoint *)from
                                                  to:(MTDWaypoint *)to
                                           routeType:(MTDDirectionsRouteType)routeType {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.willStartLoadingDirections) {
        [delegate mapView:self.mapView willStartLoadingDirectionsFrom:from to:to routeType:routeType];
    }

    // post corresponding notification
    NSDictionary *userInfo = (@{MTDDirectionsNotificationKeyFrom: from,
                              MTDDirectionsNotificationKeyTo: to,
                              MTDDirectionsNotificationKeyRouteType: @(routeType)});

    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewWillStartLoadingDirections
                                                                 object:self.mapView
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (MTDDirectionsOverlay *)notifyDelegateDidFinishLoadingOverlay:(MTDDirectionsOverlay *)overlay {
    MTDDirectionsOverlay *overlayToReturn = overlay;
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.didFinishLoadingOverlay) {
        overlayToReturn = [delegate mapView:self.mapView didFinishLoadingDirectionsOverlay:overlay];
    }

    // post corresponding notification
    NSDictionary *userInfo = @{MTDDirectionsNotificationKeyOverlay: overlay};
    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidFinishLoadingDirectionsOverlay
                                                                 object:self.mapView
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    // sanity check if delegate returned a valid overlay
    if ([overlayToReturn isKindOfClass:[MTDDirectionsOverlay class]]) {
        return overlayToReturn;
    } else {
        return overlay;
    }
}

- (void)notifyDelegateDidFailLoadingOverlayWithError:(NSError *)error {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.didFailLoadingOverlay) {
        [delegate mapView:self.mapView didFailLoadingDirectionsOverlayWithError:error];
    }

    // post corresponding notification
    NSDictionary *userInfo = @{MTDDirectionsNotificationKeyError: error};
    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidFailLoadingDirectionsOverlay
                                                                 object:self.mapView
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (BOOL)askDelegateForSelectionEnabledStateOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (route == nil || overlay == nil) {
        return NO;
    }

    if (_directionsDelegateFlags.shouldActivateRouteOfOverlay) {
        return [delegate mapView:self.mapView shouldActivateRoute:route ofDirectionsOverlay:overlay];
    } else {
        return YES;
    }
}

- (void)notifyDelegateDidActivateRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.didActivateRouteOfOverlay) {
        [delegate mapView:self.mapView didActivateRoute:route ofDirectionsOverlay:overlay];
    }

    // post corresponding notification
    NSDictionary *userInfo = @{MTDDirectionsNotificationKeyOverlay: overlay, MTDDirectionsNotificationKeyRoute: route};
    NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidActivateRouteOfDirectionsOverlay
                                                                 object:self.mapView
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (UIColor *)askDelegateForColorOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.colorForRoute) {
        UIColor *color = [delegate mapView:self.mapView colorForRoute:route ofDirectionsOverlay:overlay];

        // sanity check if delegate returned valid color
        if ([color isKindOfClass:[UIColor class]]) {
            return color;
        }
    }

    // nil doesn't get set as overlay color
    return nil;
}

- (CGFloat)askDelegateForLineWidthFactorOfOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.lineWidthFactorForOverlay) {
        CGFloat lineWidthFactor = [delegate mapView:self.mapView lineWidthFactorForDirectionsOverlay:overlay];
        return lineWidthFactor;
    }

    // doesn't get set as line width
    return -1.f;
}

- (void)notifyDelegateDidUpdateUserLocation:(CLLocation *)location {
    __strong __typeof__(self.mapView) mapView = self.mapView;

    // is also nil if directionsOverlay == nil. If the location manager fires instantly we crash otherwise.
    if (mapView.directionsOverlay.activeRoute != nil) {
        id<MTDDirectionsDelegate> delegate = self.directionsDelegate;
        CGFloat distance = [mapView distanceBetweenActiveRouteAndCoordinate:location.coordinate];

        if (distance != FLT_MAX) {
            if (_directionsDelegateFlags.didUpdateUserLocationWithDistance) {
                [delegate mapView:mapView
            didUpdateUserLocation:location
            distanceToActiveRoute:distance
              ofDirectionsOverlay:mapView.directionsOverlay];
            }

            // post corresponding notification
            NSDictionary *userInfo = (@{
                                      MTDDirectionsNotificationKeyUserLocation: location,
                                      MTDDirectionsNotificationKeyDistanceToActiveRoute: @(distance),
                                      MTDDirectionsNotificationKeyOverlay: mapView.directionsOverlay,
                                      MTDDirectionsNotificationKeyRoute: mapView.directionsOverlay.activeRoute
                                      });
            NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidUpdateUserLocationWithDistanceToActiveRoute
                                                                         object:mapView
                                                                       userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate
////////////////////////////////////////////////////////////////////////

- (void)locationManager:(__unused CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(__unused CLLocation *)oldLocation {
    MTDLogVerbose(@"Location manager found a location for [MTDWaypoint waypointForCurrentLocation]");

    [MTDWaypoint mtd_updateCurrentLocationCoordinate:newLocation.coordinate];
    [self stopUpdatingLocationCallingCompletion:YES];
}

- (void)locationManager:(__unused CLLocationManager *)manager didFailWithError:(NSError *)error {
    MTDLogVerbose(@"Location manager failed while finding a location for [MTDWaypoint waypointForCurrentLocation]");

    [self stopUpdatingLocationCallingCompletion:NO];
    [self notifyDelegateDidFailLoadingOverlayWithError:error];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate
////////////////////////////////////////////////////////////////////////

- (BOOL)gestureRecognizer:(__unused UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *otherTapGestureRecognizer = (UITapGestureRecognizer *)otherGestureRecognizer;

        return otherTapGestureRecognizer.numberOfTapsRequired == 1;
    } else {
        return YES;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

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

@end
