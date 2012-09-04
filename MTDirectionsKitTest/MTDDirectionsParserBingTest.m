//
//  MTDDirectionsParserBingTest.m
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDDirectionsParserBingTest.h"
#import "MTDirectionsParserBing.h"
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
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.0616,16.3236)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.209,16.354)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_walking.xml");


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
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.0616,16.3236)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.209,16.354)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_driving.xml");


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
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.0616,16.3236)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.209,16.354)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_transit.xml");


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
        MTDDirectionsParserBing *parser = [[MTDDirectionsParserBing alloc] initWithFrom:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(47.0616,16.3236)]
                                                                                     to:[MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(48.209,16.354)]
                                                                      intermediateGoals:nil
                                                                              routeType:MTDDirectionsRouteTypeShortestDriving
                                                                                   data:data];


        [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
            STAssertNil(error,@"There was an error parsing bing_driving_path.xml");


            testFinished = YES;
        }];
    });

    while (!testFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

@end
