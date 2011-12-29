#import "MTDirectionsParserMapQuest.h"
#import "MTWaypoint.h"
#import "MTXPathResultNode.h"

#define kMTDirectionsCoordinateNode     @"latLng"
#define kMTDirectionsLatitudeNode       @"lat"
#define kMTDirectionsLongitudeNode      @"lng"

@implementation MTDirectionsParserMapQuest

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mt_direction_block)completion {
    NSArray *results = (NSArray *)self.data;
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:results.count];
    
    // add start coordinate
    [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.fromCoordinate]];
    
    // There should only be one element "shapePoints"
    for (MTXPathResultNode *resultNode in results) {
        // latLng childs
        for (MTXPathResultNode *childNode in resultNode.childNodes) {
            MTXPathResultNode *latitudeNode = [childNode firstChildNodeWithName:kMTDirectionsLatitudeNode];
            MTXPathResultNode *longitudeNode = [childNode firstChildNodeWithName:kMTDirectionsLongitudeNode];
            
            if (latitudeNode != nil && longitudeNode != nil) {
                CLLocationCoordinate2D coordinate;
                
                coordinate.latitude = [latitudeNode.contentString doubleValue];
                coordinate.longitude = [longitudeNode.contentString doubleValue];
                
                [waypoints addObject:[MTWaypoint waypointWithCoordinate:coordinate]];
            }
        }
    }
    
    // add end coordinate
    [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.toCoordinate]];
    
    if (completion != nil) {
        completion(waypoints);
    }
}

@end
