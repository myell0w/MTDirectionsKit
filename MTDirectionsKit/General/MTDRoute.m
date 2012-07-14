#import "MTDRoute.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"


@interface MTDRoute ()

/** 
 Internally we use a MKPolyline to represent the overlay since MKPolyline
 cannot be subclassed sanely and we don't want to reinvent the wheel.
 */
@property (nonatomic, strong) MKPolyline *polyline;

// Re-defining properties as readwrite
@property (nonatomic, strong, readwrite) NSArray *waypoints;
@property (nonatomic, strong, readwrite) MTDDistance *distance;
@property (nonatomic, assign, readwrite) NSTimeInterval timeInSeconds;
@property (nonatomic, copy, readwrite) NSDictionary *additionalInfo;

@end


@implementation MTDRoute

@synthesize polyline = _polyline;
@synthesize waypoints = _waypoints;
@synthesize distance = _distance;
@synthesize timeInSeconds = _timeInSeconds;
@synthesize additionalInfo = _additionalInfo;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDRoute *)routeWithWaypoints:(NSArray *)waypoints
                        distance:(MTDDistance *)distance
                   timeInSeconds:(NSTimeInterval)timeInSeconds
                  additionalInfo:(NSDictionary *)additionalInfo {
    MTDRoute *route = nil;
    
    if (waypoints.count > 0) {
        route = [[MTDRoute alloc] init];
        
        MKMapPoint *points = malloc(sizeof(MKMapPoint) * waypoints.count);
        NSUInteger pointIndex = 0;
        
        for (NSUInteger i = 0; i < waypoints.count; i++) {
            MTDWaypoint *waypoint = [waypoints objectAtIndex:i];
            
            if (CLLocationCoordinate2DIsValid(waypoint.coordinate)) {
                MKMapPoint point = MKMapPointForCoordinate(waypoint.coordinate);
                
                points[pointIndex++] = point;
            } 
        }
        
        route.polyline = [MKPolyline polylineWithPoints:points count:pointIndex];
        route.waypoints = waypoints;
        route.distance = distance;
        route.timeInSeconds = timeInSeconds;
        route.additionalInfo = additionalInfo;
        
        free(points);
    } 
    
    return route;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    return [NSString stringWithFormat:@"<MTDRoute from=%@ to=%@>", self.from, self.to];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[MTDRoute class]]) {
        return NO;
    }

    MTDRoute *route = (MTDRoute *)object;

    return [self.waypoints isEqualToArray:route.waypoints];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDRoute
////////////////////////////////////////////////////////////////////////

- (MTDWaypoint *)from {
    if (self.waypoints.count > 0) {
        return [self.waypoints objectAtIndex:0];
    }

    return nil;
}

- (MTDWaypoint *)to {
    return [self.waypoints lastObject];
}

- (MKMapPoint *)points {
    return self.polyline.points;
}

- (NSUInteger)pointCount {
    return self.polyline.pointCount;
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
