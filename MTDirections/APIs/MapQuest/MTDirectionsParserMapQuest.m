#import "MTDirectionsParserMapQuest.h"
#import "MTWaypoint.h"
#import "MTXPathResultNode.h"

#define kMTDirectionLatitudeNode    @"lat"
#define kMTDirectionLongitudeNode   @"lng"

@implementation MTDirectionsParserMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mt_direction_block)completion {
    NSArray *results = (NSArray *)self.data;
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:results.count];
    
    // add start coordinate
    [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.fromCoordinate]];
    
    // add all maneuvers
    for (MTXPathResultNode *resultNode in results) {
        CLLocationCoordinate2D coordinate;
        
        for (MTXPathResultNode *childNode in resultNode.childNodes) {
            if ([childNode.name isEqualToString:kMTDirectionLatitudeNode]) {
                coordinate.latitude = [childNode.contentString doubleValue];
            } else if ([childNode.name isEqualToString:kMTDirectionLongitudeNode]) {
                coordinate.longitude = [childNode.contentString doubleValue];
            }
        }
        
        [waypoints addObject:[MTWaypoint waypointWithCoordinate:coordinate]];
    }
    
    // add end coordinate
    [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.toCoordinate]];
    
    if (completion != nil) {
        completion(waypoints);
    }
}

@end
