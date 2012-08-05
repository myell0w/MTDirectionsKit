#import "MTDXMLElementTest.h"


@implementation MTDXMLElementTest

- (void)testXML {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"mapquest_guessing_vienna.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    STAssertNotNil(data, @"Couldn't read mapquest_guessing_vienna.xml");

    NSArray *maneuverNodes = [MTDXMLElement nodesForXPathQuery:@"//maneuverIndexes" onXML:data];
    STAssertTrue(maneuverNodes.count == 1, @"Number of maneuver nodes not matching");
    MTDXMLElement *maneuverNode = [maneuverNodes objectAtIndex:0];

    NSArray *indexNodes = [maneuverNode childNodesWithName:@"index"];
    STAssertTrue(indexNodes.count == 50, @"Number of index nodes not matching");

    MTDXMLElement *firstIndex = [maneuverNode firstChildNodeWithName:@"index"];
    STAssertEqualObjects([indexNodes objectAtIndex:0], firstIndex, @"Child nodes not equal");
    STAssertEqualObjects(firstIndex.contentString, @"0", @"Content not matching");
}

- (void)testChildNodes {
    NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"google_intermediate_optimized.xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    STAssertNotNil(data, @"Couldn't read google_intermediate_optimized.xml");

    MTDXMLElement *routeNode = [MTDXMLElement nodeForXPathQuery:@"//route" onXML:data];
    STAssertNotNil(routeNode, @"Couldn't read routeNode");

    NSArray *children = [routeNode childNodesTraversingFirstChildWithPath:@"leg.step.duration.value"];
    STAssertTrue(children.count == 1, @"Wrong number of child nodes");
    STAssertEqualObjects([[children objectAtIndex:0] contentString], @"16", @"Wrong content");

    children = [routeNode childNodesTraversingAllChildrenWithPath:@"leg.step.duration.value"];
    STAssertTrue(children.count == 29, @"Wrong number of child nodes");
    STAssertEqualObjects([[children valueForKey:@"contentString"] componentsJoinedByString:@""],
                         @"162340241161059412844104218164233421522906190123200654993623073",
                         @"Wrong content");
}

@end
