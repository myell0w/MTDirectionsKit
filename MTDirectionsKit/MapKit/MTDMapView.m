#import "MTDMapView.h"
#import "MTDWaypoint.h"
#import "MTDDistance.h"
#import "MTDDirectionsDelegate.h"
#import "MTDDirectionsRequest.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDirectionsOverlayView.h"
#import "MTDFunctions.h"


@interface MTDMapView () <MKMapViewDelegate> {
    // flags for methods implemented in the delegate
    struct {
        unsigned int willStartLoadingOverlayCoordinates:1;
        unsigned int willStartLoadingOverlayAddresses:1;
        unsigned int didFinishLoadingOverlay:1;
        unsigned int didFailLoadingOverlay:1;
        unsigned int colorForOverlay:1;
	} _directionsDelegateFlags;
}

@property (nonatomic, strong, readwrite) MTDDirectionsOverlayView *directionsOverlayView; // re-defined as read/write
@property (nonatomic, mtd_weak) id<MKMapViewDelegate> trueDelegate;
@property (nonatomic, strong) MTDDirectionsRequest *request;

- (void)setup;

- (void)updateUIForDirectionsDisplayType:(MTDDirectionsDisplayType)displayType;
- (void)setRegionFromWaypoints:(NSArray *)waypoints edgePadding:(UIEdgeInsets)edgePadding animated:(BOOL)animated;

- (MKOverlayView *)viewForDirectionsOverlay:(id<MKOverlay>)overlay;

// Crippled
- (void)_mtd_cr_:(NSTimer *)timer;

@end


@implementation MTDMapView

@synthesize directionsDelegate = _directionsDelegate;
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

- (void)dealloc {
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
    __mtd_weak MTDMapView *weakSelf = self;
    
    [self.request cancel];
    
    if (CLLocationCoordinate2DIsValid(fromCoordinate) && CLLocationCoordinate2DIsValid(toCoordinate)) {
        self.request = [MTDDirectionsRequest requestFrom:fromCoordinate
                                                      to:toCoordinate
                                               routeType:routeType
                                              completion:^(MTDDirectionsOverlay *overlay, NSError *error) {
                                                  __strong MTDMapView *strongSelf = weakSelf;
                                                  
                                                  if (overlay != nil) {
                                                      if (_directionsDelegateFlags.didFinishLoadingOverlay) {
                                                          overlay = [self.directionsDelegate mapView:strongSelf didFinishLoadingDirectionsOverlay:overlay];
                                                      }
                                                      
                                                      strongSelf.directionsDisplayType = MTDDirectionsDisplayTypeOverview;
                                                      strongSelf.directionsOverlay = overlay;
                                                      
                                                      if (zoomToShowDirections) {
                                                          [strongSelf setRegionToShowDirectionsAnimated:YES];
                                                      } else {
                                                          [strongSelf setNeedsLayout];
                                                      }
                                                  } else {
                                                      if (_directionsDelegateFlags.didFailLoadingOverlay) {
                                                          [self.directionsDelegate mapView:strongSelf didFailLoadingDirectionsOverlayWithError:error];
                                                      }
                                                  }
                                              }];
        
        if (_directionsDelegateFlags.willStartLoadingOverlayCoordinates) {
            [self.directionsDelegate mapView:self willStartLoadingDirectionsFrom:fromCoordinate to:toCoordinate routeType:routeType];
        }
        
        [self.request start];
    }
}

- (void)loadDirectionsFromAddress:(NSString *)fromAddress
                        toAddress:(NSString *)toAddress
                        routeType:(MTDDirectionsRouteType)routeType
             zoomToShowDirections:(BOOL)zoomToShowDirections {
    __mtd_weak MTDMapView *weakSelf = self;
    
    [self.request cancel];
    
    if (fromAddress.length > 0 && toAddress.length > 0) {
        self.request = [MTDDirectionsRequest requestFromAddress:fromAddress
                                                      toAddress:toAddress
                                                      routeType:routeType
                                                     completion:^(MTDDirectionsOverlay *overlay, NSError *error) {
                                                         __strong MTDMapView *strongSelf = weakSelf;
                                                         
                                                         if (overlay != nil) {
                                                             if (_directionsDelegateFlags.didFinishLoadingOverlay) {
                                                                 overlay = [self.directionsDelegate mapView:strongSelf didFinishLoadingDirectionsOverlay:overlay];
                                                             }
                                                             
                                                             strongSelf.directionsDisplayType = MTDDirectionsDisplayTypeOverview;
                                                             strongSelf.directionsOverlay = overlay;
                                                             
                                                             if (zoomToShowDirections) {
                                                                 [strongSelf setRegionToShowDirectionsAnimated:YES];
                                                             }
                                                         } else {
                                                             if (_directionsDelegateFlags.didFailLoadingOverlay) {
                                                                 [self.directionsDelegate mapView:strongSelf didFailLoadingDirectionsOverlayWithError:error];
                                                             }
                                                         }
                                                     }];
        
        if (_directionsDelegateFlags.willStartLoadingOverlayAddresses) {
            [self.directionsDelegate mapView:self willStartLoadingDirectionsFromAddress:fromAddress toAddress:toAddress routeType:routeType];
        }
        
        [self.request start];
    }
}

- (void)cancelLoadOfDirections {
    [self.request cancel];
    self.request = nil;
}

- (void)removeDirectionsOverlay {
    [self removeOverlay:_directionsOverlay];
    
    _directionsOverlay = nil;
    _directionsOverlayView = nil;
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
            [self removeDirectionsOverlay];
        }
        
         _directionsOverlay = directionsOverlay;
        
        // add new overlay
        if (directionsOverlay != nil) {
            [self addOverlay:directionsOverlay];
        }
    }
}

- (void)setDirectionsDisplayType:(MTDDirectionsDisplayType)directionsDisplayType {
    if (directionsDisplayType != _directionsDisplayType) {
        // we first update the UI to have access to the old display type here
        [self updateUIForDirectionsDisplayType:directionsDisplayType];
        
        _directionsDisplayType = directionsDisplayType;
    }
}

- (void)setDirectionsDelegate:(id<MTDDirectionsDelegate>)directionsDelegate {
    if (directionsDelegate != _directionsDelegate) {
        _directionsDelegate = directionsDelegate;
        
        // update delegate flags
        _directionsDelegateFlags.willStartLoadingOverlayCoordinates = [_directionsDelegate respondsToSelector:@selector(mapView:willStartLoadingDirectionsFrom:to:routeType:)];
        _directionsDelegateFlags.willStartLoadingOverlayAddresses = [_directionsDelegate respondsToSelector:@selector(mapView:willStartLoadingDirectionsFromAddress:toAddress:routeType:)];
        _directionsDelegateFlags.didFinishLoadingOverlay = [_directionsDelegate respondsToSelector:@selector(mapView:didFinishLoadingDirectionsOverlay:)];
        _directionsDelegateFlags.didFailLoadingOverlay = [_directionsDelegate respondsToSelector:@selector(mapView:didFailLoadingDirectionsOverlayWithError:)];
        _directionsDelegateFlags.colorForOverlay = [_directionsDelegate respondsToSelector:@selector(mapView:colorForDirectionsOverlay:)];
    }
}

- (void)setDelegate:(id<MKMapViewDelegate>)delegate {
    if (delegate != _trueDelegate) {
        _trueDelegate = delegate;
        
        // if we haven't set a directionsDelegate and our delegate conforms to the protocol
        // MTDDirectionsDelegate, then we automatically set our directionsDelegate
        if (self.directionsDelegate == nil && [delegate conformsToProtocol:@protocol(MTDDirectionsDelegate)]) {
            self.directionsDelegate = (id<MTDDirectionsDelegate>)delegate;
        }
    }
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

- (double)distance {
    return [self.directionsOverlay.distance distanceInCurrentMeasurementSystem];
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
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
    
    // Crippled
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(_mtd_cr_:)
                                   userInfo:nil
                                    repeats:YES];    
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
    
    if (_directionsDelegateFlags.colorForOverlay) {
        self.directionsOverlayView.overlayColor = [self.directionsDelegate mapView:self colorForDirectionsOverlay:self.directionsOverlay];
    }
    
    return self.directionsOverlayView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Crippled
////////////////////////////////////////////////////////////////////////

- (void)_mtd_cr_:(NSTimer *)timer {
    if (!_mtd_cr_) {
        [self removeOverlays:self.overlays];
    }
}

@end
