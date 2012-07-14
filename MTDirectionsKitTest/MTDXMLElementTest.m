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


@end
