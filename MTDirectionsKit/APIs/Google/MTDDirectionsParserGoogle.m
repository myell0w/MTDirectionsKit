#import "MTDDirectionsParserGoogle.h"
#import "MTDDirectionsOverlay.h"
#import "MTDXMLElement.h"
#import "MTDDistance.h"
#import "MTDFunctions.h"
#import "MTDWaypoint.h"
#import "MTDLogging.h"
#import "MTDStatusCodeGoogle.h"


@interface MTDDirectionsParserGoogle ()

- (NSArray *)waypointsFromEncodedPolyline:(NSString *)encodedPolyline;

@end


@implementation MTDDirectionsParserGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_parser_block)completion {
    NSArray *statusCodeNodes = [MTDXMLElement nodesForXPathQuery:@"//DirectionsResponse/status" onXML:self.data];
    MTDStatusCodeGoogle statusCode = MTDStatusCodeGoogleSuccess;
    MTDDirectionsOverlay *overlay = nil;
    NSError *error = nil;
    
    if (statusCodeNodes.count > 0) {
        statusCode = MTDStatusCodeGoogleFromDescription([[statusCodeNodes objectAtIndex:0] contentString]);
    }
    
    if (statusCode == MTDStatusCodeGoogleSuccess) {
        NSArray *waypointNodes = [MTDXMLElement nodesForXPathQuery:@"//route/leg[1]/step/polyline/points" onXML:self.data];
        NSArray *distanceNodes = [MTDXMLElement nodesForXPathQuery:@"//route/leg[1]/step/distance/value" onXML:self.data];
        NSArray *timeNodes = [MTDXMLElement nodesForXPathQuery:@"//route/leg[1]/step/duration/value" onXML:self.data];
        
        NSMutableArray *waypoints = [NSMutableArray array];
        MTDDistance *distance = [MTDDistance distanceWithValue:0. measurementSystem:MTDMeasurementSystemMetric];
        NSTimeInterval timeInSeconds = 0.;
        
        // Parse Waypoints
        {
            // add start coordinate
            //if (CLLocationCoordinate2DIsValid(self.fromCoordinate)) {
            //    [waypoints addObject:[MTDWaypoint waypointWithCoordinate:self.fromCoordinate]];
            //}
            
            for (MTDXMLElement *waypointNode in waypointNodes) {
                NSString *encodedPolyline = [waypointNode contentString];
                
                [waypoints addObjectsFromArray:[self waypointsFromEncodedPolyline:encodedPolyline]];
            }
            
            // add end coordinate
            //if (CLLocationCoordinate2DIsValid(self.toCoordinate)) {
            //    [waypoints addObject:[MTDWaypoint waypointWithCoordinate:self.toCoordinate]];
            //}
        }
        
        // Parse Additional Info of directions
        {
            // compute total distance
            for (MTDXMLElement *distanceNode in distanceNodes) {
                double distanceInMeters = [[distanceNode contentString] doubleValue];
                
                [distance addDistanceWithMeters:distanceInMeters];
            }
            
            // compute total time
            for (MTDXMLElement *timeNode in timeNodes) {
                NSTimeInterval timeValue = [[timeNode contentString] doubleValue];
                
                timeInSeconds += timeValue;
            }
        }
        
        overlay = [MTDDirectionsOverlay overlayWithWaypoints:[waypoints copy]
                                                    distance:distance
                                               timeInSeconds:timeInSeconds
                                                   routeType:self.routeType];
    } else {
        error = [NSError errorWithDomain:MTDDirectionsKitErrorDomain
                                    code:statusCode
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                          self.data, MTDDirectionsKitDataKey,
                                          nil]];
        
        MTDLogError(@"Error occurred during parsing of directions from %@ to %@:\n%@", 
                    MTDStringFromCLLocationCoordinate2D(self.fromCoordinate),
                    MTDStringFromCLLocationCoordinate2D(self.toCoordinate),
                    error);
    }
    
    if (completion != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(overlay, error);
        });
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

// Algorithm description:
// http://code.google.com/apis/maps/documentation/utilities/polylinealgorithm.html
- (NSArray *)waypointsFromEncodedPolyline:(NSString *)encodedPolyline {    
    encodedPolyline = [encodedPolyline stringByReplacingOccurrencesOfString:@"\\\\"
                                                                 withString:@"\\"
                                                                    options:NSLiteralSearch
                                                                      range:NSMakeRange(0, encodedPolyline.length)];
    NSInteger index = 0;  
    NSMutableArray *array = [[NSMutableArray alloc] init];  
    NSInteger lat=0;  
    NSInteger lng=0;  
    
    while (index < encodedPolyline.length) {  
        NSInteger b;  
        NSInteger shift = 0;  
        NSInteger result = 0;  
        
        do {  
            b = [encodedPolyline characterAtIndex:index++] - 63;  
            result |= (b & 0x1f) << shift;  
            shift += 5;  
        } while (b >= 0x20);  
        
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));  
        
        lat += dlat;  
        shift = 0;  
        result = 0;  
        
        do {  
            b = [encodedPolyline characterAtIndex:index++] - 63;  
            result |= (b & 0x1f) << shift;  
            shift += 5;  
        } while (b >= 0x20);  
        
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));  
        lng += dlng;  
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat*1e-5, lng*1e-5);
        [array addObject:[MTDWaypoint waypointWithCoordinate:coordinate]];
    }  
    
    return [array copy];  
}


@end
