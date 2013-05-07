//
//  GMSMarker.h
//  Google Maps SDK for iOS
//
//  Copyright 2012 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <GoogleMaps/GMSOverlay.h>

@class UIImage;

/**
 * A marker is an icon placed at a particular point on the map's surface. A
 * marker's icon is drawn oriented against the device's screen rather than the
 * map's surface; i.e., it will not necessarily change orientation due to map
 * rotations, tilting, or zooming.
 */
@interface GMSMarker : GMSOverlay

/** Marker position. */
@property (nonatomic, assign) CLLocationCoordinate2D position;

/** Snippet text, shown beneath the title in the info window when selected. */
@property (nonatomic, copy) NSString *snippet;

/** Marker icon to render. If left nil, uses a default SDK place marker. */
@property (nonatomic, strong) UIImage *icon;

/**
 * The ground anchor specifies the point in the icon image that is anchored to
 * the marker's position on the Earth's surface. This point is specified within
 * the continuous space [0.0, 1.0] x [0.0, 1.0], where (0,0) is the top-left
 * corner of the image, and (1,1) is the bottom-right corner.
 */
@property (nonatomic, assign) CGPoint groundAnchor;

/**
 * The info window anchor specifies the point in the icon image at which to
 * anchor the info window, which will be displayed directly above this point.
 * This point is specified within the same space as groundAnchor.
 */
@property (nonatomic, assign) CGPoint infoWindowAnchor;

/** Whether this marker will be animated when it is placed on a GMSMapView. */
@property (nonatomic, assign, getter=isAnimated) BOOL animated;

/**
 * Marker data. You can use this property to associate an arbitrary object with
 * this marker. Google Maps SDK for iOS neither reads nor writes this property.
 *
 * Note that userData should not hold any strong references to any Maps
 * objects, otherwise a loop may be created (preventing ARC from releasing
 * objects).
 */
@property (nonatomic, strong) id userData;

/** Convenience constructor for a default marker. */
+ (instancetype)markerWithPosition:(CLLocationCoordinate2D)position;

/** Creates a tinted version of the default marker image for use as an icon. */
+ (UIImage *)markerImageWithColor:(UIColor *)color;

@end

/**
 * The default position of the ground anchor of a GMSMarker: the center bottom
 * point of the marker icon.
 */
FOUNDATION_EXTERN const CGPoint kGMSMarkerDefaultGroundAnchor;

/**
 * The default position of the info window anchor of a GMSMarker: the center top
 * point of the marker icon.
 */
FOUNDATION_EXTERN const CGPoint kGMSMarkerDefaultInfoWindowAnchor;
