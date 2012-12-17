#import "MTDRoute.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"


@interface MTDRoute ()

/** 
 Internally we use a MKPolyline to represent the overlay since MKPolyline
 cannot be subclassed sanely and we don't want to reinvent the wheel.
 */
@property (nonatomic, strong, setter = mtd_setPolyline:) MKPolyline *mtd_polyline;

// Re-defining properties as readwrite
@property (nonatomic, copy, readwrite) NSArray *waypoints;
@property (nonatomic, copy, readwrite) NSArray *maneuvers;
@property (nonatomic, strong, readwrite) MTDDistance *distance;
@property (nonatomic, assign, readwrite) NSTimeInterval timeInSeconds;
@property (nonatomic, copy, readwrite) NSDictionary *additionalInfo;

@end


@implementation MTDRoute

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithWaypoints:(NSArray *)waypoints
              maneuvers:(NSArray *)maneuvers
               distance:(MTDDistance *)distance
          timeInSeconds:(NSTimeInterval)timeInSeconds
                   name:(NSString *)name
              routeType:(MTDDirectionsRouteType)routeType
         additionalInfo:(NSDictionary *)additionalInfo {
    MTDAssert(waypoints.count > 0, @"There must be waypoints on a route");

    if (waypoints.count == 0) {
        return nil;
    }
    
    if ((self = [super init])) {         
        MKMapPoint *points = malloc(sizeof(MKMapPoint) * waypoints.count);
        NSUInteger pointIndex = 0;
        
        for (NSUInteger i = 0; i < waypoints.count; i++) {
            MTDWaypoint *waypoint = waypoints[i];
            
            if (CLLocationCoordinate2DIsValid(waypoint.coordinate)) {
                MKMapPoint point = MKMapPointForCoordinate(waypoint.coordinate);
                
                points[pointIndex++] = point;
            } 
        }
        
        _mtd_polyline = [MKPolyline polylineWithPoints:points count:pointIndex];
        _waypoints = [waypoints copy];
        _maneuvers = [maneuvers copy];
        _distance = distance;
        _timeInSeconds = timeInSeconds;
        _name = name;
        _routeType = routeType;
        _additionalInfo = [additionalInfo copy];
        
        free(points);
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return [NSString stringWithFormat:@"<MTDRoute from=%@ to=%@, # of waypoints: %d, # of maneuvers: %d, distance: %@>",
            self.from,
            self.to,
            self.waypoints.count,
            self.maneuvers.count,
            self.distance];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MTDRoute class]]) {
        return NO;
    }
    
    MTDRoute *route = (MTDRoute *)object;
    
    return self.waypoints == route.waypoints || [self.waypoints isEqualToArray:route.waypoints];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDRoute
////////////////////////////////////////////////////////////////////////

- (MTDWaypoint *)from {
    return MTDFirstObjectOfArray(self.waypoints);
}

- (MTDWaypoint *)to {
    return [self.waypoints lastObject];
}

- (MKMapPoint *)points {
    return self.mtd_polyline.points;
}

- (NSUInteger)pointCount {
    return self.mtd_polyline.pointCount;
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
