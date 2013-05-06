#import "MTDMapViewProxy.h"
#import "MTDMapViewProxyPrivate.h"
#import "MTDDirectionsDelegate.h"
#import "MTDMapView.h"
#import "MTDDirectionsOverlay.h"
#import "MTDWaypoint.h"
#import "MTDWaypoint+MTDirectionsPrivateAPI.h"


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

@end


@implementation MTDMapViewProxy 

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithMapView:(id<MTDMapViewProxyPrivate>)mapView {
    if ((self = [super init])) {
        _mapView = mapView;
    }

    return self;
}

- (void)dealloc {
    _directionsDelegate = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDMapViewProxy
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


////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate
////////////////////////////////////////////////////////////////////////

- (void)locationManager:(__unused CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(__unused CLLocation *)oldLocation {
    id<MTDMapViewProxyPrivate> mapView = self.mapView;
    
    MTDLogVerbose(@"Location manager found a location for [MTDWaypoint waypointForCurrentLocation]");

    [MTDWaypoint mtd_updateCurrentLocationCoordinate:newLocation.coordinate];
    [mapView mtd_stopUpdatingLocationCallingCompletion:YES];
}

- (void)locationManager:(__unused CLLocationManager *)manager didFailWithError:(NSError *)error {
    id<MTDMapViewProxyPrivate> mapView = self.mapView;
    
    MTDLogVerbose(@"Location manager failed while finding a location for [MTDWaypoint waypointForCurrentLocation]");

    [mapView mtd_stopUpdatingLocationCallingCompletion:NO];
    [self mtd_notifyDelegateDidFailLoadingOverlayWithError:error];
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
#pragma mark - Private Delegate Helper
////////////////////////////////////////////////////////////////////////

- (void)mtd_notifyDelegateWillStartLoadingDirectionsFrom:(MTDWaypoint *)from
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

- (MTDDirectionsOverlay *)mtd_notifyDelegateDidFinishLoadingOverlay:(MTDDirectionsOverlay *)overlay {
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

- (void)mtd_notifyDelegateDidFailLoadingOverlayWithError:(NSError *)error {
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

- (BOOL)mtd_askDelegateForSelectionEnabledStateOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
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

- (void)mtd_notifyDelegateDidActivateRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
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

- (UIColor *)mtd_askDelegateForColorOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay {
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

- (CGFloat)mtd_askDelegateForLineWidthFactorOfOverlay:(MTDDirectionsOverlay *)overlay {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;

    if (_directionsDelegateFlags.lineWidthFactorForOverlay) {
        CGFloat lineWidthFactor = [delegate mapView:self.mapView lineWidthFactorForDirectionsOverlay:overlay];
        return lineWidthFactor;
    }

    // doesn't get set as line width
    return -1.f;
}

- (void)mtd_notifyDelegateDidUpdateUserLocation:(MKUserLocation *)userLocation {
    id<MTDDirectionsDelegate> delegate = self.directionsDelegate;
    CGFloat distance = 0.f; // TODO [self distanceBetweenActiveRouteAndCoordinate:userLocation.coordinate];

    if (distance != FLT_MAX) {
        if (_directionsDelegateFlags.didUpdateUserLocationWithDistance) {
            [delegate mapView:self.mapView
        didUpdateUserLocation:userLocation
        distanceToActiveRoute:distance
          ofDirectionsOverlay:self.mapView.directionsOverlay];
        }

        // post corresponding notification
        NSDictionary *userInfo = (@{
                                  MTDDirectionsNotificationKeyUserLocation: userLocation,
                                  MTDDirectionsNotificationKeyDistanceToActiveRoute: @(distance),
                                  MTDDirectionsNotificationKeyOverlay: self.mapView.directionsOverlay,
                                  MTDDirectionsNotificationKeyRoute: self.mapView.directionsOverlay.activeRoute
                                  });
        NSNotification *notification = [NSNotification notificationWithName:MTDMapViewDidUpdateUserLocationWithDistanceToActiveRoute
                                                                     object:self.mapView
                                                                   userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

@end
