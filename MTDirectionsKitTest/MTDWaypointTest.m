#import "MTDWaypointTest.h"

@implementation MTDWaypointTest

////////////////////////////////////////////////////////////////////////
#pragma mark - SenTestCase
////////////////////////////////////////////////////////////////////////

- (void)setUp {
    [super setUp];
    
    waypoint1 = [MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(51.459596, -0.973277)];
    waypoint2 = [MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(51.459596, -0.973277)];
}

- (void)tearDown {
    waypoint1 = nil;
    waypoint2 = nil;
    
    [super tearDown];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDWaypointTest
////////////////////////////////////////////////////////////////////////

- (void)testEquals {
    STAssertTrue([waypoint1 isEqual:waypoint2], @"Waypoints should be equal.");
}

- (void)testHash {
    STAssertEquals(waypoint1.hash, waypoint2.hash, @"Hashes should be equal.");
}

@end
