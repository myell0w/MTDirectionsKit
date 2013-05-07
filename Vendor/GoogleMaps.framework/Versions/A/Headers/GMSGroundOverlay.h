//
//  GMSGroundOverlay.h
//  Google Maps SDK for iOS
//
//  Copyright 2013 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <GoogleMaps/GMSOverlay.h>

/**
 * GMSGroundOverlay specifies the available options for a ground overlay that
 * exists on the Earth's surface. Unlike a marker, the position of a ground
 * overlay is specified explicitly and it does not face the camera.
 */
@interface GMSGroundOverlay : GMSOverlay

/**
 * The position of this ground overlay, or more specifically, the physical
 * position of its anchor.
 */
@property (nonatomic, assign) CLLocationCoordinate2D position;

/**
 * As groundAnchor on GMSMarker. Specifies where the ground overlay is anchored
 * to the earth in relation to its position.
 */
@property (nonatomic, assign) CGPoint anchor;

/** Icon to render on the earth. Unlike for GMSMarker, this is required. */
@property (nonatomic, strong) UIImage *icon;

/**
 * The zoom level at which this ground overlay is displayed at 1:1. Will be
 * clamped to ensure that it is at least 1.
 */
@property (nonatomic, assign) CGFloat zoomLevel;

/**
 * Bearing of this ground overlay, in degrees. The default value, zero, points
 * this ground overlay up/down along the normal Y axis of the earth.
 */
@property (nonatomic, assign) CLLocationDirection bearing;

/**
 * Convenience constructor for GMSGroundOverlay for a particular position and
 * icon. Other properties will have default values.
 */
+ (instancetype)groundOverlayWithPosition:(CLLocationCoordinate2D)position
                                     icon:(UIImage *)icon;

@end

/**
 * The default position of the ground anchor of a GMSGroundOverlay: the center
 * point of the icon.
 */
FOUNDATION_EXTERN const CGPoint kGMSGroundOverlayDefaultAnchor;

/** The default zoom level this ground overlay is displayed at. */
FOUNDATION_EXTERN const CGFloat kGMSGroundOverlayDefaultZoom;
