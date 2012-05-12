#import "MTDMapView.h"
#import "MTDWaypoint.h"
#import "MTDDirectionsRequest.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsOverlayView.h"
#import "MTDFunctions.h"


@interface MTDMapView () <MKMapViewDelegate>

@property (nonatomic, strong, readwrite) MTDDirectionsOverlayView *directionsOverlayView; // re-defined as read/write
@property (nonatomic, unsafe_unretained) id<MKMapViewDelegate> trueDelegate;
@property (nonatomic, strong) MTDDirectionsRequest *request;

- (void)setup;

- (void)updateUIForDirectionsDisplayType:(MTDDirectionsDisplayType)displayType;
- (void)setRegionFromWaypoints:(NSArray *)waypoints edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animated;

- (MKOverlayView *)viewForDirectionsOverlay:(id<MKOverlay>)overlay;

@end


@implementation MTDMapView

@synthesize directionsOverlay = _directionsOverlay;
@synthesize directionsOverlayView = _directionsOverlayView;
@synthesize directionsDisplayType = _directionsDisplayType;
@synthesize trueDelegate = _trueDelegate;
@synthesize request = _request;

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
#pragma mark - Directions
////////////////////////////////////////////////////////////////////////

- (void)loadDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
                        to:(CLLocationCoordinate2D)toCoordinate
                 routeType:(MTDDirectionsRouteType)routeType
      zoomToShowDirections:(BOOL)zoomToShowDirections {
    __block __typeof__(self) blockSelf = self;
    
    [self.request cancel];
    
    if (CLLocationCoordinate2DIsValid(fromCoordinate) && CLLocationCoordinate2DIsValid(toCoordinate)) {
        self.request = [MTDDirectionsRequest requestFrom:fromCoordinate
                                                     to:toCoordinate
                                              routeType:routeType
                                             completion:^(MTDDirectionsOverlay *overlay) {
                                                 blockSelf.directionsDisplayType = MTDDirectionsDisplayTypeOverview;
                                                 blockSelf.directionsOverlay = overlay;
                                                 
                                                 // If we found at least one waypoint (start and end are always contained)
                                                 // zoom the mapView to show the whole direction
                                                 if (zoomToShowDirections && overlay.waypoints.count > 2) {
                                                     [blockSelf setRegionToShowDirectionsAnimated:YES];
                                                 }
                                             }];
        
        [self.request start];
    }
}

- (void)cancelLoadOfDirections {
    [self.request cancel];
    self.request = nil;
}

- (void)removeDirectionsOverlay {
    self.directionsOverlay = nil;
    self.directionsOverlayView = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Region
////////////////////////////////////////////////////////////////////////

- (void)setRegionToShowDirectionsAnimated:(BOOL)animated {
    [self setRegionFromWaypoints:self.directionsOverlay.waypoints edgePadding:UIEdgeInsetsZero animated:animated];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Properties
////////////////////////////////////////////////////////////////////////

- (void)setDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay {
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

- (void)setDirectionsDisplayType:(MTDDirectionsDisplayType)directionsDisplayType {
    if (directionsDisplayType != _directionsDisplayType) {
        // we first update the UI to have access to the old display type here
        [self updateUIForDirectionsDisplayType:directionsDisplayType];
        
        _directionsDisplayType = directionsDisplayType;
    }
}

- (void)setDelegate:(id<MKMapViewDelegate>)delegate {
    _trueDelegate = delegate;
}

- (id<MKMapViewDelegate>)delegate {
    return _trueDelegate;
}

- (CLLocationCoordinate2D)fromCoordinate {
    if (self.directionsOverlay != nil) {
        return self.directionsOverlay.fromCoordinate;
    }
    
    return MTDInvalidCLLocationCoordinate2D;
}

- (CLLocationCoordinate2D)toCoordinate {
    if (self.directionsOverlay != nil) {
        return self.directionsOverlay.toCoordinate;
    }
    
    return MTDInvalidCLLocationCoordinate2D;
}

- (CLLocationDistance)distance {
    return self.directionsOverlay.distance;
}

- (MTDDirectionsRouteType)routeType {
    return self.directionsOverlay.routeType;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Inter-App
////////////////////////////////////////////////////////////////////////

- (void)openDirectionsInMapApp {
    if (self.directionsOverlay != nil) {
        MTDDirectionsOpenInMapsApp(self.fromCoordinate, self.toCoordinate, self.directionsOverlay.routeType);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate Proxies
////////////////////////////////////////////////////////////////////////

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [self.trueDelegate mapView:mapView regionWillChangeAnimated:animated];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if ([self.trueDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [self.trueDelegate mapView:mapView regionDidChangeAnimated:animated];
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
    if ([overlay isKindOfClass:[MTDDirectionsOverlay class]]) {
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
    
    _directionsDisplayType = MTDDirectionsDisplayTypeOverview;
}

- (void)setRegionFromWaypoints:(NSArray *)waypoints edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animated {
    if (waypoints != nil) {
        CLLocationDegrees maxX = -DBL_MAX;
        CLLocationDegrees maxY = -DBL_MAX;
        CLLocationDegrees minX = DBL_MAX;
        CLLocationDegrees minY = DBL_MAX;
        
        for (NSUInteger i=0; i<waypoints.count; i++) {
            MTDWaypoint *currentLocation = [waypoints objectAtIndex:i];
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

- (void)updateUIForDirectionsDisplayType:(MTDDirectionsDisplayType)displayType {
    MTDDirectionsDisplayType oldDisplayType = self.directionsDisplayType;
    
    if (oldDisplayType != displayType) {
        [self.directionsOverlayView setNeedsDisplayInMapRect:MKMapRectWorld];
        
        switch (displayType) {    
            case MTDDirectionsDisplayTypeOverview: {
                break;
            }
                
            case MTDDirectionsDisplayTypeNone: 
            default: {
                NSArray *overlays = self.overlays;
                
                // re-draw overlays
                [self removeOverlays:overlays];
                [self addOverlays:overlays];
                break;
            }
        }
    }
}

- (MKOverlayView *)viewForDirectionsOverlay:(id<MKOverlay>)overlay {
    // don't display anything if display type is set to none
    if (self.directionsDisplayType == MTDDirectionsDisplayTypeNone) {
        return nil;
    }
    
    if (![overlay isKindOfClass:[MTDDirectionsOverlay class]] || self.directionsOverlay == nil) {
        return nil;
    }
    
    self.directionsOverlayView = [[MTDDirectionsOverlayView alloc] initWithOverlay:self.directionsOverlay];
    
    return self.directionsOverlayView;
}


@end
