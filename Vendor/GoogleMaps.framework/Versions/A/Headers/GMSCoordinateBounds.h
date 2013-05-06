//
//  GMSCoordinateBounds.h
//  Google Maps SDK for iOS
//
//  Copyright 2013 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GMSProjection.h>

@class GMSPath;

/**
 * GMSCoordinateBounds represents a rectangular bounding box on the Earth's
 * surface. Is is immutable and can't be modified after construction.
 */
@interface GMSCoordinateBounds : NSObject

@property (readonly) CLLocationCoordinate2D northEast;

@property (readonly) CLLocationCoordinate2D southWest;

/**
 * Inits the northEast and southWest bounds corresponding
 * to the rectangular region defined by the two corners.
 *
 * It is ambiguous whether the longitude of the box
 * extends from |coord1| to |coord2| or vice-versa;
 * the box is constructed as the smaller of the two variants, eliminating the
 * ambiguity.
 */
- (id)initWithCoordinate:(CLLocationCoordinate2D)coord1
              coordinate:(CLLocationCoordinate2D)coord2;

/**
 * Inits bounds that encompass |region|.
 */
- (id)initWithRegion:(GMSVisibleRegion)region;

/**
 * Inits bounds that encompass |path|.
 */
- (id)initWithPath:(GMSPath *)path;

/**
 * Allocates and returns a new GMSCoordinateBounds, representing
 * the current bounds extended to include the passed-in coordinate.
 */
- (GMSCoordinateBounds *)includingCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * Allocates and returns a new GMSCoordinateBounds, representing
 * the current bounds extended to include the entire other bounds.
 */
- (GMSCoordinateBounds *)includingBounds:(GMSCoordinateBounds *)other;

/**
 * Returns YES if |coordinate| is contained within the bounds.
 */
- (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * Returns YES if |other| overlaps with this bounds.
 */
- (BOOL)intersectsBounds:(GMSCoordinateBounds *)other;

/**
 * Returns NO if this bounds does not contain any points.
 * For example, [[GMSCoordinateBounds alloc] init].valid == NO.
 * When an invalid bounds is expanded with valid coordinates via
 * includingCoordinate: or includingBounds:, the resulting bounds will be valid
 * but contain only the new coordinates.
 */
@property (readonly, getter=isValid) BOOL valid;

@end
