//
//  MTDMapViewDelegateProxy.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsRouteType.h"
#import "MTDDirectionsRequestOption.h"


@protocol MTDMapViewProxyPrivate;
@protocol MTDDirectionsDelegate;
@class MTDWaypoint;
@class MTDDirectionsOverlay;
@class MTDRoute;


/**
 Since we subclass MKMapView we don't want to interfere with it's delegate-behaviour. MKMapView is known
 to at least respond to the protocol UIGestureRecognizerDelegate (not public), so we use an instance of
 MTDMapViewProxy as our delegate. 
 
 Furthermore this class implements common functionality that is used in MTDMapView as well as MTDGMSMapView.
 */
@interface MTDMapViewProxy : NSObject <UIGestureRecognizerDelegate, CLLocationManagerDelegate>

/** The MapView to call back */
@property (nonatomic, mtd_weak) id<MTDMapViewProxyPrivate> mapView;

/** The receiver's directionsDelegate */
@property (nonatomic, mtd_weak) id<MTDDirectionsDelegate> directionsDelegate;

/**
 Creates an instance of the delegate proxy that doesn‘t retain the mapView to not create a retain cycle.
 
 @param mapView the mapView to call back
 @return an instance of MTDMapViewDelegateProxy
 */
- (id)initWithMapView:(id<MTDMapViewProxyPrivate>)mapView;


/******************************************
 @name Delegate Helper
 ******************************************/

- (void)mtd_notifyDelegateWillStartLoadingDirectionsFrom:(MTDWaypoint *)from to:(MTDWaypoint *)to routeType:(MTDDirectionsRouteType)routeType;
- (MTDDirectionsOverlay *)mtd_notifyDelegateDidFinishLoadingOverlay:(MTDDirectionsOverlay *)overlay;
- (void)mtd_notifyDelegateDidFailLoadingOverlayWithError:(NSError *)error;
- (BOOL)mtd_askDelegateForSelectionEnabledStateOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay;
- (void)mtd_notifyDelegateDidActivateRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay;
- (UIColor *)mtd_askDelegateForColorOfRoute:(MTDRoute *)route ofOverlay:(MTDDirectionsOverlay *)overlay;
- (CGFloat)mtd_askDelegateForLineWidthFactorOfOverlay:(MTDDirectionsOverlay *)overlay;
- (void)mtd_notifyDelegateDidUpdateUserLocation:(MKUserLocation *)userLocation;

@end
