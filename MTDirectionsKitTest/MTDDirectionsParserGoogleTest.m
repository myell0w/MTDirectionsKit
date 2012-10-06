#import "MTDDirectionsParserGoogleTest.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDistance.h"
#import "MTDWaypoint.h"
#import "MTDAddress.h"
#import "MTDRoute.h"


@implementation MTDDirectionsParserGoogleTest

- (void)testDirectRoute {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"google_guessing_vienna.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read google_guessing_vienna.xml");

    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MTDDirectionsParserGoogle *parser = [[MTDDirectionsParserGoogle alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.0616,16.3236)]
                                                                                         to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.209,16.354)]
                                                                          intermediateGoals:nil
                                                                                  routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                       data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing google_guessing_vienna.xml");

            STAssertEqualObjects(overlay.fromAddress.fullAddress, @"Güssing, Austria", @"Error parsing fromAddress");
            STAssertEqualObjects(overlay.toAddress.fullAddress, @"Vienna, Austria", @"Error parsing toAddress");

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

- (void)testIntermediateGoals {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"google_intermediate_optimized.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read google_intermediate_optimized.xml");

    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CLLocationCoordinate2D from = CLLocationCoordinate2DMake(51.4554, -0.9742);              // Reading
        CLLocationCoordinate2D to = CLLocationCoordinate2DMake(51.38713, -1.0316);               // NSConference
        CLLocationCoordinate2D intermediateGoal1 = CLLocationCoordinate2DMake(51.3765, -1.003);  // Beech Hill
        CLLocationCoordinate2D intermediateGoal2 = CLLocationCoordinate2DMake(51.4388, -0.9409); // University Shinfield
        MTDDirectionsParserGoogle *parser = [[MTDDirectionsParserGoogle alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:from]
                                                                                         to:[MTDWaypoint waypointWithCoordinate:to]
                                                                          intermediateGoals:[NSArray arrayWithObjects:
                                                                                             [MTDWaypoint waypointWithCoordinate:intermediateGoal1],
                                                                                             [MTDWaypoint waypointWithCoordinate:intermediateGoal2],
                                                                                             nil]
                                                                                  routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                       data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing mapquest_guessing_vienna.xml");

            MTDAddress *fromAddress = overlay.fromAddress;
            MTDAddress *toAddress = overlay.toAddress;

            STAssertEqualObjects(fromAddress.fullAddress, @"57 St Mary's Butts, Reading RG1, Vereinigtes Königreich", @"error parsing fromAddress");
            STAssertEqualObjects(toAddress.fullAddress, @"New Rd, Reading, Berkshire RG7, Vereinigtes Königreich", @"error parsing toAddress");

            STAssertEquals(overlay.timeInSeconds, 1946., @"Error parsing time");
            STAssertEqualObjects(overlay.formattedTime, @"32:26", @"Error formatting time");
            STAssertTrue(overlay.waypoints.count == 1002, @"Error parsing waypoints");
            STAssertEqualsWithAccuracy([overlay.distance distanceInMeasurementSystem:MTDMeasurementSystemMetric], 20.2, 0.001, @"Error parsing distance");

            NSArray *intermediateGoals = overlay.intermediateGoals;

            STAssertTrue(intermediateGoals.count == 2, @"Error parsing number of intermediate goals");

            MTDWaypoint *ig1 = [intermediateGoals objectAtIndex:0];
            MTDWaypoint *ig2 = [intermediateGoals objectAtIndex:1];

            STAssertEqualObjects(ig1.address.fullAddress, @"Reading, Wokingham RG6 6PU, Vereinigtes Königreich", @"Wrong address of intermediate goal");
            STAssertEqualsWithAccuracy(ig1.coordinate.latitude, 51.4388, 0.000001, @"Wrong coordinate of intermediate goal");
            STAssertEqualsWithAccuracy(ig1.coordinate.longitude, -0.9409, 0.000001, @"Wrong coordinate of intermediate goal");

            STAssertEqualObjects(ig2.address.fullAddress, @"Wood Ln, Reading, Berkshire RG7, Vereinigtes Königreich", @"Wrong address of intermediate goal");
            STAssertEqualsWithAccuracy(ig2.coordinate.latitude, 51.3765, 0.000001, @"Wrong coordinate of intermediate goal");
            STAssertEqualsWithAccuracy(ig2.coordinate.longitude, -1.003, 0.000001, @"Wrong coordinate of intermediate goal");

            testFinished = YES;
        }];
    });

    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)testAlternatives {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"google_alternatives.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read google_alternatives.xml");

    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CLLocationCoordinate2D from = CLLocationCoordinate2DMake(40.339885, -75.926577);         // Reading USA
        CLLocationCoordinate2D to = CLLocationCoordinate2DMake(38.895114, -77.036369);           // Washington D.C.

        MTDDirectionsParserGoogle *parser = [[MTDDirectionsParserGoogle alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:from]
                                                                                         to:[MTDWaypoint waypointWithCoordinate:to]
                                                                          intermediateGoals:nil
                                                                                  routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                       data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing mapquest_guessing_vienna.xml");

            // Check alternative routes
            STAssertTrue(overlay.routes.count == 3, @"Error parsing alternative routes");

            // Check fastest and shortest route
            STAssertTrue(overlay.fastestRoute.timeInSeconds == 10042., @"Fastest route not working");
            STAssertEqualsWithAccuracy([overlay.shortestRoute.distance distanceInMeasurementSystem:MTDMeasurementSystemMetric], 224.181, 0.001, @"Shortest route not working");

            // Check best route
            STAssertEquals(overlay.timeInSeconds, 10042., @"Error parsing time");
            STAssertEqualObjects(overlay.formattedTime, @"2:47:22", @"Error formatting time");
            STAssertTrue(overlay.waypoints.count == 3481, @"Error parsing waypoints");
            STAssertEqualsWithAccuracy([overlay.distance distanceInMeasurementSystem:MTDMeasurementSystemMetric], 233.687, 0.001, @"Error parsing distance");

            for (MTDRoute *route in overlay.routes) {
                // Check Addresses
                MTDAddress *fromAddress = route.from.address;
                MTDAddress *toAddress = route.to.address;

                STAssertEqualObjects(fromAddress.fullAddress, @"275-299 Church St, Reading, Pennsylvania 19601, Vereinigte Staaten", @"error parsing fromAddress");
                STAssertEqualObjects(toAddress.fullAddress, @"Ellipse Rd NW, Washington, District of Columbia 20502, Vereinigte Staaten", @"error parsing toAddress");

                // Check copyright
                NSString *copyright = [route.additionalInfo objectForKey:MTDAdditionalInfoCopyrightsKey];
                STAssertEqualObjects(copyright, @"Kartendaten ©2012 Google", @"Error parsing copyright");
            }
            
            testFinished = YES;
        }];
    });
    
    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

@end
