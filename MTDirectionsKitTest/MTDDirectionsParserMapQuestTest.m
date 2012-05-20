#import "MTDDirectionsParserMapQuestTest.h"
#import "MTDDirectionsOverlay.h"
#import "MTDDistance.h"

@implementation MTDDirectionsParserMapQuestTest

- (void)testParsing {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"guessing_vienna.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    STAssertNotNil(data, @"Couldn't read guessing_vienna.xml");
    
    MTDDirectionsParserMapQuest *parser = [[MTDDirectionsParserMapQuest alloc] initWithFromCoordinate:CLLocationCoordinate2DMake(47.0616,16.3236)
                                                                                         toCoordinate:CLLocationCoordinate2DMake(48.209,16.354)
                                                                                            routeType:MTDDirectionsRouteTypeShortestDriving 
                                                                                                 data:data];
    
    
    [parser parseWithCompletion:^(MTDDirectionsOverlay *overlay, NSError *error) {
        STAssertNil(error,@"There was an error parsing guessing_vienna.xml");
        
        STAssertEquals(overlay.timeInSeconds, 7915., @"Error parsing time");
        STAssertEqualObjects(overlay.formattedTime, @"2:11:55", @"Error formatting time");
        STAssertTrue(overlay.waypoints.count == 248, @"Error parsing waypoints");
        STAssertEqualsWithAccuracy([overlay.distance distanceInMeasurementSystem:MTDMeasurementSystemMetric], 150.8663, 0.001, @"Error parsing distance");
    }];
}

@end
