//
//  MTDMapView.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDMapViewProtocol.h"
#import "MTDDirectionsDefines.h"
#import "MTDDirectionsRequestOption.h"
#import "MTDWeak.h"
#import <GoogleMaps/GoogleMaps.h>


@class MTDDistance;
@class MTDWaypoint;
@class MTDDirectionsOverlay;
@class MTDGMSDirectionsOverlayView;
@class MTDRoute;
@protocol MTDDirectionsDelegate;


/**
 An MTDMapView instance provides functionality to show directions directly on top of the MapView inside your App.
 MTDMapView is a subclass of MKMapView and therefore uses Apple's standard way of displaying map data, which we all
 know and love. Up until iOS 5 this means that Google Maps is used as a backend for the map data, starting with iOS 6
 Apple Maps are used.
 
 Sample usage:
 
 MTDMapView *_mapView = [[MTDMapView alloc] initWithFrame:self.view.bounds];
 _mapView.directionsDelegate = self;
 
 [_mapView loadDirectionsFrom:CLLocationCoordinate2DMake(51.38713, -1.0316)
                           to:CLLocationCoordinate2DMake(51.4554, -0.9742)
                    routeType:MTDDirectionsRouteTypeFastestDriving
         zoomToShowDirections:YES];
 
 */
@interface MTDGMSMapView : GMSMapView <MTDMapView>

/******************************************
 @name Lifecycle
 ******************************************/

/**
 Creates and returns an instance of MTDGMSMapView.
 
 @param frame The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
 @param camera Controls the camera, which defines how the map is oriented

 @return an instance of MTDGMSMapView
 */
+ (instancetype)mapWithFrame:(CGRect)frame camera:(GMSCameraPosition *)camera;

/******************************************
 @name Delegate
 ******************************************/

/** The receiver's directionsDelegate */
@property (nonatomic, mtd_weak) id<MTDDirectionsDelegate> directionsDelegate;

/******************************************
 @name Directions
 ******************************************/

/** the starting coordinate of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationCoordinate2D fromCoordinate;
/** the end coordinate of the directions of the currently displayed overlay */
@property (nonatomic, readonly) CLLocationCoordinate2D toCoordinate;

/** the total distance of the directions of the currenty displayed overlay in meters */
@property (nonatomic, readonly) CLLocationDistance distanceInMeter;
/** the total estimated time of the directions */
@property (nonatomic, readonly) NSTimeInterval timeInSeconds;


/**
 The padding that will be used when zooming the map to the displayed directions.
 If not specified, a default padding of 125.f will be used.
 */
@property (nonatomic, assign) CGFloat directionsEdgePadding;


/**
 Returns the corresponding directions overlay view for the given route
 
 @param route the route which overlay view we are interested in
 @return the overlay view of the given route or nil
 */
- (MTDGMSDirectionsOverlayView *)directionsOverlayViewForRoute:(MTDRoute *)route;

@end
