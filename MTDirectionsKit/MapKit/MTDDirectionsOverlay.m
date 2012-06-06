#import "MTDDirectionsOverlay.h"
#import "MTDWaypoint.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDDirectionsDefines.h"


@interface MTDDirectionsOverlay ()

/** 
 Internally we use a MKPolyline to represent the overlay since MKPolyline
 cannot be subclassed sanely and we don't want to reinvent the wheel
 */
@property (nonatomic, strong) MKPolyline *polyline;

// Re-defining properties as readwrite
@property (nonatomic, strong, readwrite) NSArray *waypoints;
@property (nonatomic, strong, readwrite) MTDDistance *distance;
@property (nonatomic, assign, readwrite) NSTimeInterval timeInSeconds;
@property (nonatomic, assign, readwrite) MTDDirectionsRouteType routeType;

@end


@implementation MTDDirectionsOverlay

@synthesize polyline = _polyline;
@synthesize waypoints = _waypoints;
@synthesize distance = _distance;
@synthesize timeInSeconds = _timeInSeconds;
@synthesize routeType = _routeType;
@synthesize fromAddress = _fromAddress;         // This property gets set via KVO to not pollute the public API
@synthesize toAddress = _toAddress;             // This property gets set via KVO to not pollute the public API
@synthesize additionalInfo = _additionalInfo;   // This property gets set via KVO to not pollute the public API

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDDirectionsOverlay *)overlayWithWaypoints:(NSArray *)waypoints 
                                      distance:(MTDDistance *)distance
                                 timeInSeconds:(NSTimeInterval)timeInSeconds
                                     routeType:(MTDDirectionsRouteType)routeType {
    MTDDirectionsOverlay *overlay = nil;
    
    if (waypoints.count > 0) {
        overlay = [[MTDDirectionsOverlay alloc] init];
        
        MKMapPoint *points = malloc(sizeof(CLLocationCoordinate2D) * waypoints.count);
        NSUInteger pointIndex = 0;
        
        for (NSUInteger i = 0; i < waypoints.count; i++) {
            MTDWaypoint *waypoint = [waypoints objectAtIndex:i];
            
            if (CLLocationCoordinate2DIsValid(waypoint.coordinate)) {
                MKMapPoint point = MKMapPointForCoordinate(waypoint.coordinate);
            
                points[pointIndex++] = point;
            } 
        }
        
        overlay.polyline = [MKPolyline polylineWithPoints:points count:pointIndex];
        overlay.waypoints = waypoints;
        overlay.distance = distance;
        overlay.timeInSeconds = timeInSeconds;
        overlay.routeType = routeType;
        
        free(points);
    } 

    return overlay;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MKOverlay
////////////////////////////////////////////////////////////////////////

- (CLLocationCoordinate2D)coordinate {
    return self.polyline.coordinate;
}

- (MKMapRect)boundingMapRect {
    return self.polyline.boundingMapRect;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [self.polyline intersectsMapRect:mapRect];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDDirectionsOverlay
////////////////////////////////////////////////////////////////////////

- (MKMapPoint *)points {
    return self.polyline.points;
}

- (NSUInteger)pointCount {
    return self.polyline.pointCount;
}

- (CLLocationCoordinate2D)fromCoordinate {
    if (self.waypoints.count > 0) {
        MTDWaypoint *firstWaypoint = [self.waypoints objectAtIndex:0];
        return firstWaypoint.coordinate;
    }
    
    return MTDInvalidCLLocationCoordinate2D;
}

- (CLLocationCoordinate2D)toCoordinate {
    if (self.waypoints.count > 0) {
        MTDWaypoint *lastWaypoint = [self.waypoints lastObject];
        return lastWaypoint.coordinate;
    }
    
    return MTDInvalidCLLocationCoordinate2D;
}

- (NSString *)formattedTime {
    return [self formattedTimeWithFormat:nil];
}

- (NSString *)formattedTimeWithFormat:(NSString *)format {
    if (format != nil) {
        return MTDGetFormattedTimeWithFormat(self.timeInSeconds, format);
    } else {
        return MTDGetFormattedTime(self.timeInSeconds);
    }
}

@end
