//
//  MTDMapViewDelegateProxy.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDMapView;


/**
 Since we subclass MKMapView we don't want to interfere with it's delegate-behavious. MKMapView is known
 to at least respond to the protocol UIGestureRecognizerDelegate (not public), so we use an instance of
 MTDMapViewDelegateProxy as our delegate.
 */
@interface MTDMapViewDelegateProxy : NSObject <UIGestureRecognizerDelegate, CLLocationManagerDelegate>

/** The MapView to call back, when a delegate call happens */
@property (nonatomic, mtd_weak) MTDMapView *mapView;
/** The last known location */
@property (nonatomic, assign) CLLocationCoordinate2D lastKnownUserCoordinate;

/**
 Creates an instance of the delegate proxy that doesn‘t retain the mapView to not create a retain cycle.
 
 @param mapView the mapView to call back
 @return an instance of MTDMapViewDelegateProxy
 */
- (id)initWithMapView:(MTDMapView *)mapView;

@end
