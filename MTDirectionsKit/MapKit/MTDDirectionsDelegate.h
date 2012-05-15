//
//  MTDDirectionsDelegate.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import <Foundation/Foundation.h>


@class MTDMapView;
@class MTDDirectionsOverlay;


/**
 The MTDDirectionsDelegate protocol defines a set of optional methods that you can implement to receive
 information updates about MTDirectionsKit-related stuff.
 */
@protocol MTDDirectionsDelegate <NSObject>

@optional

/**
 Tells the delegate that the mapView will start loading directions
 
 @param mapView the mapView that will start loading the directions
 @param fromCoordinate the starting point of the directions
 @param toCoordinate the end point of the directions
 @param routeType the type of the route requested, e.g. pedestrian, cycling, fastest driving
 */
- (void)mapView:(MTDMapView *)mapView
willStartLoadingDirectionsFrom:(CLLocationCoordinate2D)fromCoordinate
             to:(CLLocationCoordinate2D)toCoordinate
      routeType:(MTDDirectionsRouteType)routeType;

/**
 Tells the delegate that the mapView will start loading directions
 
 @param mapView the mapView that will start loading the directions
 @param fromCoordinate the starting point of the directions
 @param toCoordinate the end point of the directions
 @param routeType the type of the route requested, e.g. pedestrian, cycling, fastest driving
 */
- (void)mapView:(MTDMapView *)mapView
willStartLoadingDirectionsFromAddress:(NSString *)fromAddress
      toAddress:(NSString *)toAddress
      routeType:(MTDDirectionsRouteType)routeType;

/**
 Tells the delegate that the specified directionsOverlay was loaded on the specified mapView.
 This method allows the delegate to intercept MTDirectionsKit and change the directionsOverlay
 by returning a different overlay than the one received as parameter
 
 @param mapView the mapView that began loading the directions
 @param directionsOverlay the overlay that was loaded
 @return the directionsOverlay that gets displayed on the mapView
 */
- (MTDDirectionsOverlay *)mapView:(MTDMapView *)mapView didFinishLoadingDirectionsOverlay:(MTDDirectionsOverlay *)directionsOverlay;

/**
 Tells the delegate that the mapView specified wasn't able to load the directions requested
 
 @param mapView the mapView that began loading the directions
 @param error the error that occured
 */
- (void)mapView:(MTDMapView *)mapView didFailLoadingDirectionsOverlayWithError:(NSError *)error;

@end
