#import "MTDWaypointTest.h"


@implementation MTDWaypointTest

////////////////////////////////////////////////////////////////////////
#pragma mark - SenTestCase
////////////////////////////////////////////////////////////////////////

- (void)setUp {
    [super setUp];
    
    waypoint1 = [MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(51.459596, -0.973277)];
    waypoint2 = [MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(51.459596, -0.973277)];
    waypoint3 = [MTDWaypoint waypointWithCoordinate:CLLocationCoordinate2DMake(51.45959, -0.973277)];
    waypoint4 = [MTDWaypoint waypointWithAddress:[[MTDAddress alloc] initWithAddressString:@"Güssing"]];
    waypoint5 = [MTDWaypoint waypointWithAddress:[[MTDAddress alloc] initWithAddressString:@"Güssing"]];
    waypoint6 = [MTDWaypoint waypointWithAddress:[[MTDAddress alloc] initWithAddressString:@"Wien"]];
}

- (void)tearDown {
    waypoint1 = nil;
    waypoint2 = nil;
    waypoint3 = nil;
    waypoint4 = nil;
    waypoint5 = nil;
    waypoint6 = nil;
    
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

- (void)testEqualsAddress {
    STAssertTrue([waypoint4 isEqual:waypoint5], @"Waypoints should be equal.");
}

- (void)testHashAddress {
    STAssertEquals(waypoint4.hash, waypoint5.hash, @"Hashes should be equal.");
}

- (void)testNotEquals {
    STAssertFalse([waypoint1 isEqual:waypoint3], @"Waypoints should not be equal.");
    STAssertFalse([waypoint2 isEqual:waypoint3], @"Waypoints should not be equal.");
    STAssertFalse([waypoint1 isEqual:waypoint4], @"Waypoints should not be equal.");
    STAssertFalse([waypoint4 isEqual:waypoint6], @"Waypoints should not be equal.");
    STAssertFalse([waypoint5 isEqual:waypoint6], @"Waypoints should not be equal.");
}

@end
