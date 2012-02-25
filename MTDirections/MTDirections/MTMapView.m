#import "MTMapView.h"
#import "MTWaypoint.h"
#import "MTManeuver.h"
#import "MTDirectionsRequest.h"
#import "MTDirectionsOverlay.h"
#import "MTDirectionsOverlayView.h"
#import "MTManeuverInfoView.h"


#define kMTCircleMoveDuration       0.3


@interface MTMapView () <MKMapViewDelegate>

@property (nonatomic, unsafe_unretained) id<MKMapViewDelegate> trueDelegate;
@property (nonatomic, strong) MTDirectionsRequest *request;
@property (nonatomic, assign) NSUInteger activeManeuverIndex;
@property (nonatomic, strong) UIImageView *circleView;
@property (nonatomic, strong) MTManeuverInfoView *maneuverInfoView;

- (void)setup;

- (void)updateUIForDirectionsDisplayType:(MTDirectionsDisplayType)displayType;
- (void)showManeuverStartingFromIndex:(NSUInteger)maneuverStartIndex;
- (void)setRegionFromWaypoints:(NSArray *)waypoints edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animated;

- (MKOverlayView *)viewForDirectionsOverlay:(id<MKOverlay>)overlay;

@end

@implementation MTMapView

@synthesize directionsOverlay = _directionsOverlay;
@synthesize directionsOverlayView = _directionsOverlayView;
@synthesize directionsDisplayType = _directionsDisplayType;
@synthesize trueDelegate = _trueDelegate;
@synthesize request = _request;
@synthesize activeManeuverIndex = _activeManeuverIndex;
@synthesize circleView = _circleView;
@synthesize maneuverInfoView = _maneuverInfoView;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Region
////////////////////////////////////////////////////////////////////////

- (void)setRegionToShowDirectionsAnimated:(BOOL)animated {
    [self setRegionFromWaypoints:self.directionsOverlay.waypoints edgePadding:UIEdgeInsetsZero animated:animated];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Directions
////////////////////////////////////////////////////////////////////////

- (void)loadDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
                        to:(CLLocationCoordinate2D)toCoordinate
                 routeType:(MTDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections {
    __block __typeof__(self) blockSelf = self;
    
    [self.request cancel];
    self.request = [MTDirectionsRequest requestFrom:fromCoordinate
                                                 to:toCoordinate
                                          routeType:routeType
                                         completion:^(MTDirectionsOverlay *overlay) {
                                             blockSelf.directionsDisplayType = MTDirectionsDisplayTypeOverview;
                                             blockSelf.directionsOverlay = overlay;
                                             
                                             // If we found at least one waypoint (start and end are always contained)
                                             // zoom the mapView to show the whole direction
                                             if (zoomToShowDirections && overlay.waypoints.count > 2) {
                                                 [blockSelf setRegionToShowDirectionsAnimated:YES];
                                             }
                                         }];
    
    [self.request start];
}

- (void)cancelLoadOfDirections {
    [self.request cancel];
    self.request = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Maneuvers
////////////////////////////////////////////////////////////////////////

- (BOOL)showNextManeuver {
    if (self.directionsDisplayType != MTDirectionsDisplayTypeDetailedManeuvers) {
        // this call updates the UI to show first maneuver
        self.directionsDisplayType = MTDirectionsDisplayTypeDetailedManeuvers;
        return YES;
    }
    
    NSUInteger activeManeuverIndex = self.activeManeuverIndex;
    
    if (activeManeuverIndex >= self.directionsOverlay.maneuvers.count - 1) {
        return NO;
    }

    activeManeuverIndex++;
    self.activeManeuverIndex = activeManeuverIndex;
    [self showManeuverStartingFromIndex:activeManeuverIndex];
    
    return YES;
}

- (BOOL)showPreviousManeuver {
    NSUInteger activeManeuverIndex = self.activeManeuverIndex;
    
    if (activeManeuverIndex == 0) {
        return NO;
    }
    
    activeManeuverIndex--;
    self.activeManeuverIndex = activeManeuverIndex;
    [self showManeuverStartingFromIndex:activeManeuverIndex];
    
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
////////////////////////////////////////////////////////////////////////

- (void)setDirectionsOverlay:(MTDirectionsOverlay *)directionsOverlay {
    if (directionsOverlay != _directionsOverlay) {    
        // remove old overlay and annotations
        if (_directionsOverlay != nil) {
            [self removeOverlay:_directionsOverlay];
        }
        
        // add new overlay
        if (directionsOverlay != nil) {
            [self addOverlay:directionsOverlay];
        }
        
        _directionsOverlay = directionsOverlay;
    }
}

- (void)setDirectionsDisplayType:(MTDirectionsDisplayType)directionsDisplayType {
    if (directionsDisplayType != _directionsDisplayType) {
        // we first update the UI to have access to the old display type here
        [self updateUIForDirectionsDisplayType:directionsDisplayType];
        
        self.directionsOverlayView.drawManeuvers = (self.directionsDisplayType == MTDirectionsDisplayTypeDetailedManeuvers);
        _directionsDisplayType = directionsDisplayType;
    }
}

- (void)setDelegate:(id<MKMapViewDelegate>)delegate {
    _trueDelegate = delegate;
}

- (id<MKMapViewDelegate>)delegate {
    return _trueDelegate;
}

- (UIImageView *)circleView {
    if (_circleView == nil) {
        _circleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MTDirections.bundle/DirectionsCircleShiny"]];
        [self addSubview:_circleView];
    }
    
    [self bringSubviewToFront:_circleView];
    
    return _circleView;
}

- (MTManeuverInfoView *)maneuverInfoView {
    if (_maneuverInfoView == nil) {
        _maneuverInfoView = [MTManeuverInfoView infoViewForMapView:self];
        [self addSubview:_maneuverInfoView];
    }
    
    [self bringSubviewToFront:_maneuverInfoView];
    
    return _maneuverInfoView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate Proxies
////////////////////////////////////////////////////////////////////////

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [self.trueDelegate mapView:mapView regionWillChangeAnimated:animated];
    }
    
    self.circleView.alpha = 0.f;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [self.trueDelegate mapView:mapView regionDidChangeAnimated:animated];
    }
    
    if (self.activeManeuverIndex != NSNotFound && self.directionsDisplayType == MTDirectionsDisplayTypeDetailedManeuvers) {
        MTManeuver *activeManeuver = [self.directionsOverlay.maneuvers objectAtIndex:self.activeManeuverIndex];
        CGPoint circlePoint = [self convertCoordinate:activeManeuver.coordinate toPointToView:self];
        
        self.circleView.alpha = 1.f;
        self.circleView.center = circlePoint;
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    if ([self.trueDelegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)]) {
        [self.trueDelegate mapViewWillStartLoadingMap:mapView];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if ([self.trueDelegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)]) {
        [self.trueDelegate mapViewDidFinishLoadingMap:mapView];
    }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    if ([self.trueDelegate respondsToSelector:@selector(mapViewDidFailLoadingMap:withError:)]) {
        [self.trueDelegate mapViewDidFailLoadingMap:mapView withError:error];
    }
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView {
    if ([self.trueDelegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)]) {
        [self.trueDelegate mapViewWillStartLocatingUser:mapView];
    }
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView {
    if ([self.trueDelegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)]) {
        [self.trueDelegate mapViewDidStopLocatingUser:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)]) {
        [self.trueDelegate mapView:mapView didUpdateUserLocation:userLocation];
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)]) {
        [self.trueDelegate mapView:mapView didFailToLocateUserWithError:error];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        return [self.trueDelegate mapView:mapView viewForAnnotation:annotation];
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [self.trueDelegate mapView:mapView didAddAnnotationViews:views];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
        [self.trueDelegate mapView:mapView annotationView:view calloutAccessoryControlTapped:control];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)]) {
        [self.trueDelegate mapView:mapView annotationView:annotationView didChangeDragState:newState fromOldState:oldState];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [self.trueDelegate mapView:mapView didSelectAnnotationView:view];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)]) {
        [self.trueDelegate mapView:mapView didDeselectAnnotationView:view];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    // first check if the delegate provides a custom annotation
    if ([self.trueDelegate respondsToSelector:@selector(mapView:viewForOverlay:)]) {
        MKOverlayView *delegateResult = [self.trueDelegate mapView:mapView viewForOverlay:overlay];
        
        if (delegateResult != nil) {
            return delegateResult;
        }
    } 
    
    // otherwise provide a default overlay for directions
    if ([overlay isKindOfClass:[MTDirectionsOverlay class]]) {
        return [self viewForDirectionsOverlay:overlay];
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:didAddOverlayViews:)]) {
        [self.trueDelegate mapView:mapView didAddOverlayViews:overlayViews];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)setup {
    // we set ourself as the delegate
    [super setDelegate:self];
    
    _directionsDisplayType = MTDirectionsDisplayTypeOverview;
    _activeManeuverIndex = NSNotFound;
}

- (void)setRegionFromWaypoints:(NSArray *)waypoints edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animated {
    if (waypoints != nil) {
        CLLocationDegrees maxX = -DBL_MAX;
        CLLocationDegrees maxY = -DBL_MAX;
        CLLocationDegrees minX = DBL_MAX;
        CLLocationDegrees minY = DBL_MAX;
        
        for (NSUInteger i=0; i<waypoints.count; i++) {
            MTWaypoint *currentLocation = [waypoints objectAtIndex:i];
            MKMapPoint mapPoint = MKMapPointForCoordinate(currentLocation.coordinate);
            
            if (mapPoint.x > maxX) {
                maxX = mapPoint.x;
            }
            if (mapPoint.x < minX) {
                minX = mapPoint.x;
            }
            if (mapPoint.y > maxY) {
                maxY = mapPoint.y;
            }
            if (mapPoint.y < minY) {
                minY = mapPoint.y;
            }
        }
        
        MKMapRect mapRect = MKMapRectMake(minX,minY,maxX-minX,maxY-minY);
        [self setVisibleMapRect:mapRect edgePadding:edgePadding animated:animated];
    }
}

- (void)updateUIForDirectionsDisplayType:(MTDirectionsDisplayType)displayType {
    MTDirectionsDisplayType oldDisplayType = self.directionsDisplayType;
    
    if (oldDisplayType != displayType) {
        [self.directionsOverlayView setNeedsDisplayInMapRect:MKMapRectWorld];
        
        switch (displayType) {    
            case MTDirectionsDisplayTypeOverview: {
                self.activeManeuverIndex = NSNotFound;
                break;
            }
                
            case MTDirectionsDisplayTypeDetailedManeuvers: {
                self.activeManeuverIndex = 0;
                [self showManeuverStartingFromIndex:0];
                break;
            }
                
            case MTDirectionsDisplayTypeNone: 
            default: {
                self.activeManeuverIndex = NSNotFound;
                
                NSArray *overlays = self.overlays;
                
                // re-draw overlays
                [self removeOverlays:overlays];
                [self addOverlays:overlays];
                break;
            }
        }
    }
}

- (void)showManeuverStartingFromIndex:(NSUInteger)maneuverStartIndex {
    NSUInteger maneuverEndIndex = maneuverStartIndex + 1;
    
    if (maneuverEndIndex < self.directionsOverlay.maneuvers.count) {
        MTManeuver *startManeuver = [self.directionsOverlay.maneuvers objectAtIndex:maneuverStartIndex];
        MTManeuver *endManeuver = [self.directionsOverlay.maneuvers objectAtIndex:maneuverEndIndex];
        NSArray *waypoints = [NSArray arrayWithObjects:startManeuver.waypoint, endManeuver.waypoint, nil];
        CGPoint circlePoint = [self convertCoordinate:startManeuver.coordinate toPointToView:self];
        
        self.maneuverInfoView.infoText = [NSString stringWithFormat:@"Distanz: %f", startManeuver.distance];
        
        [UIView animateWithDuration:kMTCircleMoveDuration
                         animations:^{
                             self.circleView.center = circlePoint;
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 [self setRegionFromWaypoints:waypoints 
                                                  edgePadding:UIEdgeInsetsMake(10.f,10.f,10.f,10.f)
                                                     animated:YES];
                             }
                         }];
    }
}

- (MKOverlayView *)viewForDirectionsOverlay:(id<MKOverlay>)overlay {
    // don't display anything if display type is set to none
    if (self.directionsDisplayType == MTDirectionsDisplayTypeNone) {
        return nil;
    }
    
    if (![overlay isKindOfClass:[MTDirectionsOverlay class]] || self.directionsOverlay == nil) {
        return nil;
    }
    
    self.directionsOverlayView = [[MTDirectionsOverlayView alloc] initWithOverlay:self.directionsOverlay];
    self.directionsOverlayView.drawManeuvers = (self.directionsDisplayType == MTDirectionsDisplayTypeDetailedManeuvers);
    
    return self.directionsOverlayView;
}


@end
