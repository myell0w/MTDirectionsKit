//
//  GMSMapView.h
//  Google Maps SDK for iOS
//
//  Copyright 2012 Google Inc.
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://developers.google.com/maps/terms
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import <GoogleMaps/GMSMapLayer.h>
#import <GoogleMaps/GMSUISettings.h>

@class GMSCameraPosition;
@class GMSCameraUpdate;
@class GMSMapLayer;
@class GMSMapView;
@class GMSOverlay;
@class GMSMarker;
@class GMSProjection;

/** Delegate for events on GMSMapView. */
@protocol GMSMapViewDelegate <NSObject>

@optional

/**
 * Called after the camera position has changed. During an animation, this
 * delegate might not be notified of intermediate camera positions. However, it
 * will always be called eventually with the final position of an the animation.
 */
- (void)mapView:(GMSMapView *)mapView
    didChangeCameraPosition:(GMSCameraPosition *)position;

/**
 * Called after a tap gesture at a particular coordinate, but only if a marker
 * was not tapped.  This is called before deselecting any currently selected
 * marker (the implicit action for tapping on the map).
 */
- (void)mapView:(GMSMapView *)mapView
    didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * Called after a long-press gesture at a particular coordinate.
 *
 * @param mapView The map view that was pressed.
 * @param coordinate The location that was pressed.
 */
- (void)mapView:(GMSMapView *)mapView
    didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * Called after a marker has been tapped.
 *
 * @param mapView The map view that was pressed.
 * @param marker The marker that was pressed.
 * @return YES if this delegate handled the tap event, which prevents the map
 *         from performing its default selection behavior, and NO if the map
 *         should continue with its default selection behavior.
 */
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker;

/**
 * Called after a marker's info window has been tapped.
 */
- (void)mapView:(GMSMapView *)mapView
    didTapInfoWindowOfMarker:(GMSMarker *)marker;

/**
 * Called after an overlay has been tapped.
 * This method is not called for taps on markers.
 *
 * @param mapView The map view that was pressed.
 * @param overlay The overlay that was pressed.
 */
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay;

/**
 * Called when a marker is about to become selected, and provides an optional
 * custom info window to use for that marker if this method returns a UIView.
 * If you change this view after this method is called, those changes will not
 * necessarily be reflected in the rendered version.
 *
 * The returned UIView must not have bounds greater than 500 points on either
 * dimension.  As there is only one info window shown at any time, the returned
 * view may be reused between other info windows.
 *
 * @return The custom info window for the specified marker, or nil for default
 */
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker;

@end

/**
 * Display types for GMSMapView.
 */
typedef enum {
  /** Basic maps.  The default. */
  kGMSTypeNormal = 1,

  /** Satellite maps with no labels. */
  kGMSTypeSatellite,

  /** Terrain maps. */
  kGMSTypeTerrain,

  /** Satellite maps with a transparent label overview. */
  kGMSTypeHybrid,

} GMSMapViewType;

/**
 * This is the main class of the Google Maps SDK for iOS and is the entry point
 * for all methods related to the map.
 *
 * The map should be instantiated via the convenience constructor
 * [GMSMapView mapWithFrame:camera:]. It may also be created with the default
 * [[GMSMapView alloc] initWithFrame:] method (wherein its camera will be set to
 * a default location).
 *
 * GMSMapView can only be read and modified from the main thread, similar to all
 * UIKit objects. Calling these methods from another thread will result in an
 * exception or undefined behavior.
 */
@interface GMSMapView : UIView

/** GMSMapView delegate. */
@property (nonatomic, weak) id<GMSMapViewDelegate> delegate;

/**
 * Controls the camera, which defines how the map is oriented. Modification of
 * this property is instantaneous.
 */
@property (nonatomic, strong) GMSCameraPosition *camera;

/**
 * Returns a GMSProjection object that you can use to convert between screen
 * coordinates and latitude/longitude coordinates.
 *
 * This is a snapshot of the current projection, and will not automatically
 * update when the camera moves. It represents either the projection of the last
 * drawn GMSMapView frame, or; where the camera has been explicitly set or the
 * map just created, the upcoming frame. It will never be nil.
 */
@property (nonatomic, readonly) GMSProjection *projection;

/**
 * Controls whether the My Location dot and accuracy circle is enabled.
 * Defaults to NO.
 */
@property (nonatomic, assign, getter=isMyLocationEnabled) BOOL myLocationEnabled;

/**
 * If My Location is enabled, reveals where the user location dot is being
 * drawn. If it is disabled, or it is enabled but no location data is available,
 * this will be nil.  This property is observable using KVO.
 */
@property (nonatomic, strong, readonly) CLLocation *myLocation;

/**
 * The marker that is selected.  Setting this property selects a particular
 * marker, showing an info window on it.  If this property is non-nil, setting
 * it to nil deselects the marker, hiding the info window.  This property is
 * observable using KVO.
 */
@property (nonatomic, strong) GMSMarker *selectedMarker;

/**
 * Controls whether the map is drawing traffic data, if available.  This is
 * subject to the availability of traffic data.  Defaults to NO.
 */
@property (nonatomic, assign, getter=isTrafficEnabled) BOOL trafficEnabled;

/**
 * Controls the type of map tiles that should be displayed.  Defaults to
 * kGMSTypeNormal.
 */
@property (nonatomic, assign) GMSMapViewType mapType;

/**
 * Gets the GMSUISettings object, which controls user interface settings for the
 * map.
 */
@property (nonatomic, readonly) GMSUISettings *settings;

/** Accessor for the custom CALayer type used for the layer. */
@property(nonatomic, readonly, retain) GMSMapLayer *layer;

/**
 * Builds and returns a GMSMapView, with a frame and camera target.
 */
+ (GMSMapView *)mapWithFrame:(CGRect)frame camera:(GMSCameraPosition *)camera;

/**
 * Tells this map to power up its renderer.  This is optional- GMSMapView will
 * automatically invoke this method when added to a window.  It is safe to call
 * this method more than once.
 */
- (void)startRendering;

/**
 * Tells this map to power down its renderer, releasing its resources.  This is
 * optional- GMSMapView will automatically invoke this method when removed from
 * a window.  It is safe to call this method more than once.
 */
- (void)stopRendering;

/**
 * Clears all markup that has been added to the map, including markers,
 * polylines and ground overlays.  This will not clear the visible location dot
 * or reset the current mapType.
 */
- (void)clear;

/**
 * Changes the camera according to |update|.
 * The camera change is instantaneous (with no animation).
 */
- (void)moveCamera:(GMSCameraUpdate *)update;

@end
