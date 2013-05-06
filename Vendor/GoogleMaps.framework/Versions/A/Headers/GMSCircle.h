//
//  GMSCircle.h
//  Google Maps SDK for iOS
//
//  Copyright 2013 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <GoogleMaps/GMSOverlay.h>

#import <Foundation/Foundation.h>

/**
 * A circle on the earth's surface (spherical cap).
 */
@interface GMSCircle : GMSOverlay

/**
 * Position on the map.
 * The position is related to where the overlay is situated on the map,
 * but the exact meaning depends on the particular overlay.
 * Setting the position moves the overlay on the map to the new position.
 */
@property (nonatomic, assign) CLLocationCoordinate2D position;

/**
 * Radius of the circle in meters.
 * It must be positive.
 */
@property (nonatomic, assign) CGFloat radius;

/**
 * The width of the circle's outline, in screen points.
 * Defaults to 1.
 * The width does not scale when the map is zoomed.
 * Setting strokeWidth to 0 results in no stroke.
 */
@property (nonatomic, assign) CGFloat strokeWidth;

/**
 * The color of the circle's outline.
 * The default value is black.
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 * The interior of the circle is painted with fillColor.
 * The default value is nil resulting in no fill.
 */
@property (nonatomic, strong) UIColor *fillColor;

/**
 * Convenience constructor for GMSCircle for a particular position and radius.
 * Other properties will have default values.
 */
+ (instancetype)circleWithPosition:(CLLocationCoordinate2D)position
                            radius:(CGFloat)radius;

@end
