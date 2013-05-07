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
#import "MTDMapViewProxy.h"
#import "MTDFunctions.h"
#import "MTDCustomization.h"
#import "MTDInterApp.h"
#import "MTDAssert.h"


static char myLocationContext;


@interface GMSMapView (MTDGoogleMapsSDK)

// the designated initializer of GMSMapView is not exposed. we declare it here to keep the compiler silent
- (id)initWithFrame:(CGRect)frame camera:(GMSCameraPosition *)camera;

@end


@interface MTDGMSMapView () <GMSMapViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *directionsOverlayViews;

/** The delegate that was set by the user, we forward all delegate calls */
@property (nonatomic, mtd_weak, setter = mtd_setTrueDelegate:) id<GMSMapViewDelegate> mtd_trueDelegate;

/** the delegate proxy for CLLocationManagerDelegate and UIGestureRecognizerDelegate */
@property (nonatomic, strong) MTDMapViewProxy *mtd_proxy;

@end


@implementation MTDGMSMapView

@synthesize directionsOverlay = _directionsOverlay;
@synthesize directionsDisplayType = _directionsDisplayType;

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
    _mtd_proxy.mapView = nil;
    _mtd_proxy = nil;
    self.delegate = nil;
    [self cancelLoadOfDirections];
    [self removeObserver:self forKeyPath:MTDKey(myLocation)];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &myLocationContext) {
        CLLocation *location = change[NSKeyValueChangeNewKey];
        
        [MTDWaypoint mtd_updateCurrentLocationCoordinate:location.coordinate];
        [self.mtd_proxy notifyDelegateDidUpdateUserLocation:location];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
    MTDRoute *activeRouteBefore = self.directionsOverlay.activeRoute;

    if (route != nil && route != activeRouteBefore) {
        [self.directionsOverlay mtd_activateRoute:route];
        MTDRoute *activeRouteAfter = self.directionsOverlay.activeRoute;

        if (activeRouteBefore != activeRouteAfter) {
            [self.mtd_proxy notifyDelegateDidActivateRoute:activeRouteAfter ofOverlay:self.directionsOverlay];
            [self mtd_updateRouteAppearance];
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
    return FLT_MAX;
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
    self.mtd_proxy.directionsDelegate = directionsDelegate;
}

- (id<MTDDirectionsDelegate>)directionsDelegate {
    return self.mtd_proxy.directionsDelegate;
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

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didChangeCameraPosition:)]) {
        [trueDelegate mapView:mapView didChangeCameraPosition:position];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    CGPoint point = [mapView.projection pointForCoordinate:coordinate];
    MTDRoute *selectedRoute = [self mtd_routeTouchedByPoint:point];

    // ask delegate if we should activate the route
    if ([self.mtd_proxy askDelegateForSelectionEnabledStateOfRoute:selectedRoute ofOverlay:self.directionsOverlay]) {
        [self activateRoute:selectedRoute];
    }

    if ([trueDelegate respondsToSelector:@selector(mapView:didTapAtCoordinate:)]) {
        [trueDelegate mapView:mapView didTapAtCoordinate:coordinate];
    }
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didLongPressAtCoordinate:)]) {
        [trueDelegate mapView:mapView didLongPressAtCoordinate:coordinate];
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didTapMarker:)]) {
        return [trueDelegate mapView:mapView didTapMarker:marker];
    }

    return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didTapInfoWindowOfMarker:)]) {
        [trueDelegate mapView:mapView didTapInfoWindowOfMarker:marker];
    }
}

// we don't use this method to detect the tapped route because it isn't accurate enough, we use mapView:didTapAtCoordinate: instead
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:didTapOverlay:)]) {
        [trueDelegate mapView:mapView didTapOverlay:overlay];
    }
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    id<GMSMapViewDelegate> trueDelegate = self.mtd_trueDelegate;

    if ([trueDelegate respondsToSelector:@selector(mapView:markerInfoWindow:)]) {
        [trueDelegate mapView:mapView markerInfoWindow:marker];
    }

    return nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)mtd_setup {
    // we set ourself as the delegate
    [super setDelegate:self];

    _directionsDisplayType = MTDDirectionsDisplayTypeNone;
    _directionsEdgePadding = 125.f;
    _mtd_proxy = [[MTDMapViewProxy alloc] initWithMapView:self];

    [self addObserver:self forKeyPath:MTDKey(myLocation) options:NSKeyValueObservingOptionNew context:&myLocationContext];
}

- (void)mtd_addOverlay:(MTDDirectionsOverlay *)overlay {
    self.directionsOverlayViews = [NSMutableDictionary dictionaryWithCapacity:overlay.routes.count];

    for (MTDRoute *route in overlay.routes) {
        MTDGMSDirectionsOverlayView *overlayView = [self mtd_viewForRoute:route];

        self.directionsOverlayViews[route] = overlayView;
        overlayView.map = self;
    }

    [self mtd_updateRouteAppearance];
}

- (void)mtd_updateUIForDirectionsDisplayType:(MTDDirectionsDisplayType)displayType {
    for (MTDGMSDirectionsOverlayView *overlayView in [self.directionsOverlayViews allValues]) {
        overlayView.map = nil;

        if (displayType != MTDDirectionsDisplayTypeNone) {
            overlayView.map = self;
        }
    }
}

- (MTDGMSDirectionsOverlayView *)mtd_viewForRoute:(MTDRoute *)route {
    // don't display anything if display type is set to none
    if (self.directionsDisplayType == MTDDirectionsDisplayTypeNone) {
        return nil;
    }

    if (![route isKindOfClass:[MTDRoute class]] || self.directionsOverlay == nil) {
        return nil;
    }

    MTDGMSDirectionsOverlayView *overlayView = nil;
    CGFloat overlayLineWidthFactor = [self.mtd_proxy askDelegateForLineWidthFactorOfOverlay:self.directionsOverlay];
    Class directionsOverlayClass = MTDOverriddenClass([MTDGMSDirectionsOverlayView class]);

    if (directionsOverlayClass != Nil) {
        overlayView = [[directionsOverlayClass alloc] initWithDirectionsOverlay:self.directionsOverlay route:route];
        UIColor *overlayColor = [self.mtd_proxy askDelegateForColorOfRoute:route ofOverlay:self.directionsOverlay];

        // If we always set the color it breaks UIAppearance because it deactivates the proxy color if we
        // call the setter, even if we don't accept nil there.
        if (overlayColor != nil) {
            overlayView.overlayColor = overlayColor;
        }
        // same goes for the line width factor
        if (overlayLineWidthFactor > 0.f) {
            overlayView.overlayLineWidthFactor = overlayLineWidthFactor;
        }
    }

    return overlayView;
}

- (void)mtd_updateRouteAppearance {
    UIColor *previousColor = nil;
    BOOL allColorsSame = YES;

    // first detect if the delegate returns the same color for each route
    // if it does we apply a default alpha to the color for non-active routes
    for (MTDRoute *route in self.directionsOverlay.routes) {
        UIColor *color = [self.mtd_proxy askDelegateForColorOfRoute:route ofOverlay:self.directionsOverlay];

        if (previousColor != nil && previousColor != color) {
            allColorsSame = NO;
        }

        MTDGMSDirectionsOverlayView *overlayView = [self directionsOverlayViewForRoute:route];
        overlayView.overlayColor = color;

        previousColor = color;
    }

    // if all colors are the same apply a color with an alpha channel to the non-active routes
    if (allColorsSame && self.directionsOverlay.routes.count > 1) {
        UIColor *nonActiveColor = [previousColor colorWithAlphaComponent:0.65f];

        for (MTDRoute *route in self.directionsOverlay.routes) {
            MTDGMSDirectionsOverlayView *overlayView = [self directionsOverlayViewForRoute:route];

            if (self.directionsOverlay.activeRoute != route) {
                overlayView.overlayColor = nonActiveColor;
            }
        }
    }
}

// returns the first route that get's hit by the touch at the given point
- (MTDRoute *)mtd_routeTouchedByPoint:(CGPoint)point {
    MTDRoute *nearestRoute = nil;
    CGFloat minimumDistance = 25.f;

    for (MTDRoute *route in self.directionsOverlay.routes) {
        MTDGMSDirectionsOverlayView *overlayView = [self directionsOverlayViewForRoute:route];
        CGFloat distance = [overlayView distanceBetweenPoint:point route:route];

        if (distance < minimumDistance) {
            minimumDistance = distance;
            nearestRoute = route;
        }
    }

    return nearestRoute;
}

@end
