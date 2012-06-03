#import "MTDDirectionsParserGoogleTest.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDistance.h"
#import "MTDWaypoint.h"


@implementation MTDDirectionsParserGoogleTest

- (void)testParsing {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"google_guessing_vienna.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    STAssertNotNil(data, @"Couldn't read google_guessing_vienna.xml");
    
    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MTDDirectionsParserGoogle *parser = [[MTDDirectionsParserGoogle alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.0616,16.3236)]
                                                                                         to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.209,16.354)]
                                                                                  routeType:MTDDirectionsRouteTypeShortestDriving 
                                                                                       data:data];
        
        
        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing google_guessing_vienna.xml");
            
            STAssertEquals(overlay.timeInSeconds, 7079., @"Error parsing time");
            STAssertEqualObjects(overlay.formattedTime, @"1:57:59", @"Error formatting time");
            STAssertTrue(overlay.waypoints.count == 3287, @"Error parsing waypoints");
            STAssertEqualsWithAccuracy([overlay.distance distanceInMeasurementSystem:MTDMeasurementSystemMetric], 163.383, 0.001, @"Error parsing distance");
            
            testFinished = YES;
        }];
    });
    
    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

@end
