#import "MTDDirectionsParserBingTest.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDistance.h"
#import "MTDWaypoint.h"
#import "MTDAddress.h"
#import "MTDRoute.h"


@implementation MTDDirectionsParserBingTest

- (void)testWalking {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"bing_walking.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read bing_walking.xml");

    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.85791,2.295273)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.860118,2.340455)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_walking.xml");

            STAssertTrue(overlay.routes.count == 1, @"Wrong number of routes");
            STAssertEquals([overlay.distance distanceInMeter], 3854., @"Error parsing distance");
            STAssertEquals(overlay.timeInSeconds, 2775., @"Error parsing time");
            STAssertEqualObjects(overlay.formattedTime, @"46:15", @"Error formatting time");
            STAssertTrue(overlay.waypoints.count == 2, @"Wrong number of waypoints");

            MTDAddress *fromAddress = overlay.fromAddress;
            MTDAddress *toAddress = overlay.toAddress;

            STAssertEqualObjects(fromAddress.street, @"Eiffel Tower", @"fromAddress: error parsing street");
            STAssertEqualObjects(fromAddress.city, @"Paris", @"fromAddress: error parsing city");
            STAssertEqualObjects(fromAddress.state, @"IdF", @"fromAddress: error parsing state");
            STAssertEqualObjects(fromAddress.county, @"Paris", @"fromAddress: error parsing county");
            STAssertEqualObjects(fromAddress.country, @"France", @"fromAddress: error parsing country");
            STAssertEqualObjects(toAddress.street, @"Louvre", @"toAddress: error parsing street");
            STAssertEqualObjects(toAddress.city, @"Paris", @"toAddress: error parsing city");
            STAssertEqualObjects(toAddress.state, @"IdF", @"toAddress: error parsing state");
            STAssertEqualObjects(toAddress.county, @"Paris", @"toAddress: error parsing county");
            STAssertEqualObjects(toAddress.country, @"France", @"toAddress: error parsing country");

            testFinished = YES;
        }];
    });

    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)testDriving {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"bing_driving.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read bing_driving.xml");

    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.825321,-122.292407)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.603559,-122.329436)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_driving.xml");

            STAssertTrue(overlay.routes.count == 1, @"Wrong number of routes");
            STAssertEquals([overlay.distance distanceInMeter], 26273., @"Error parsing distance");
            STAssertEquals(overlay.timeInSeconds, 1094., @"Error parsing time");
            STAssertEqualObjects(overlay.formattedTime, @"18:14", @"Error formatting time");
            STAssertTrue(overlay.waypoints.count == 2, @"Wrong number of waypoints");

            MTDAddress *fromAddress = overlay.fromAddress;
            MTDAddress *toAddress = overlay.toAddress;

            STAssertEqualObjects(fromAddress.city, @"Lynnwood", @"fromAddress: error parsing city");
            STAssertEqualObjects(fromAddress.state, @"WA", @"fromAddress: error parsing state");
            STAssertEqualObjects(fromAddress.county, @"Snohomish Co.", @"fromAddress: error parsing county");
            STAssertEqualObjects(fromAddress.country, @"United States", @"fromAddress: error parsing country");
            STAssertEqualObjects(toAddress.city, @"Seattle", @"toAddress: error parsing city");
            STAssertEqualObjects(toAddress.state, @"WA", @"toAddress: error parsing state");
            STAssertEqualObjects(toAddress.county, @"King Co.", @"toAddress: error parsing county");
            STAssertEqualObjects(toAddress.country, @"United States", @"toAddress: error parsing country");

            testFinished = YES;
        }];
    });

    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)testTransit {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"bing_transit.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read bing_transit.xml");

    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(37.807561,-122.475024)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(37.80551,-122.41784)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_transit.xml");

            STAssertTrue(overlay.routes.count == 1, @"Wrong number of routes");
            STAssertEquals([overlay.distance distanceInMeter], 2363., @"Error parsing distance");
            STAssertEquals(overlay.timeInSeconds, 3416., @"Error parsing time");
            STAssertEqualObjects(overlay.formattedTime, @"56:56", @"Error formatting time");
            STAssertTrue(overlay.waypoints.count == 2, @"Wrong number of waypoints");

            MTDAddress *fromAddress = overlay.fromAddress;
            MTDAddress *toAddress = overlay.toAddress;

            STAssertEqualObjects(fromAddress.state, @"CA", @"fromAddress: error parsing state");
            STAssertEqualObjects(fromAddress.country, @"United States", @"fromAddress: error parsing country");
            // STAssertEqualObjects(toAddress.city, @"Fisherman's Wharf", @"toAddress: error parsing city");
            STAssertEqualObjects(toAddress.state, @"CA", @"toAddress: error parsing state");
            STAssertEqualObjects(toAddress.county, @"San Francisco Co.", @"toAddress: error parsing county");
            STAssertEqualObjects(toAddress.country, @"United States", @"toAddress: error parsing country");

            testFinished = YES;
        }];
    });

    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)testDrivingPath {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"bing_driving_path.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read bing_driving_path.xml");

    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(44.979063,-93.264908)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(44.943829,-93.093325)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_driving_path.xml");

            STAssertTrue(overlay.routes.count == 1, @"Wrong number of routes");
            STAssertEquals([overlay.distance distanceInMeter], 15211., @"Error parsing distance");
            STAssertEquals(overlay.timeInSeconds, 1084., @"Error parsing time");
            STAssertEqualObjects(overlay.formattedTime, @"18:04", @"Error formatting time");
            STAssertTrue(overlay.waypoints.count == 69, @"Wrong number of waypoints %d", overlay.waypoints.count);

            MTDAddress *fromAddress = overlay.fromAddress;
            MTDAddress *toAddress = overlay.toAddress;

            STAssertEqualObjects(fromAddress.city, @"Minneapolis", @"fromAddress: error parsing city");
            STAssertEqualObjects(fromAddress.state, @"MN", @"fromAddress: error parsing state");
            STAssertEqualObjects(fromAddress.county, @"Hennepin Co.", @"fromAddress: error parsing county");
            STAssertEqualObjects(fromAddress.country, @"United States", @"fromAddress: error parsing country");
            STAssertEqualObjects(toAddress.city, @"St Paul", @"toAddress: error parsing city");
            STAssertEqualObjects(toAddress.state, @"MN", @"toAddress: error parsing state");
            STAssertEqualObjects(toAddress.county, @"Ramsey Co.", @"toAddress: error parsing county");
            STAssertEqualObjects(toAddress.country, @"United States", @"toAddress: error parsing country");
            
            testFinished = YES;
        }];
    });
    
    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)testAlternatives {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"bing_alternatives.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read bing_alternatives.xml");

    __block BOOL testFinished = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.059298,16.324089)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.20255,16.368801)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_alternatives.xml");

            STAssertTrue(overlay.routes.count == 2, @"Wrong number of routes");

            STAssertEquals([overlay.distance distanceInMeter], 156629., @"Error parsing distance");
            STAssertEquals(overlay.timeInSeconds, 6507., @"Error parsing time");
            STAssertEqualObjects(overlay.formattedTime, @"1:48:27", @"Error formatting time");
            STAssertTrue(overlay.waypoints.count == 711, @"Wrong number of waypoints");

            MTDRoute *slowerRoute = overlay.routes[0];

            STAssertEquals([slowerRoute.distance distanceInMeter], 180481., @"Error parsing distance");
            STAssertEquals(slowerRoute.timeInSeconds, 7630., @"Error parsing time");
            STAssertEqualObjects(slowerRoute.formattedTime, @"2:07:10", @"Error formatting time");
            STAssertTrue(slowerRoute.waypoints.count == 875, @"Wrong number of waypoints");

            MTDAddress *fromAddress = overlay.fromAddress;
            MTDAddress *toAddress = overlay.toAddress;

            STAssertEqualObjects(fromAddress.city, @"Güssing", @"fromAddress: error parsing city");
            STAssertEqualObjects(fromAddress.state, @"Burgenland", @"fromAddress: error parsing state");
            STAssertEqualObjects(fromAddress.country, @"Austria", @"fromAddress: error parsing country");
            STAssertEqualObjects(toAddress.city, @"Vienna", @"toAddress: error parsing city");
            STAssertEqualObjects(toAddress.state, @"Vienna", @"toAddress: error parsing state");
            STAssertEqualObjects(toAddress.country, @"Austria", @"toAddress: error parsing country");

            testFinished = YES;
        }];
    });

    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

@end
