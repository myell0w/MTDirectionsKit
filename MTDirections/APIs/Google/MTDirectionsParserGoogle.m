#import "MTDirectionsParserGoogle.h"
#import "MTDirectionsOverlay.h"

@implementation MTDirectionsParserGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mt_direction_block)completion {
    NSString *xml = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    MTDirectionsOverlay *overlay = nil;
    
    NSLog(@"Google XML: \n\n%@", xml);
    
    if (completion != nil) {
        completion(overlay);
    }
}


@end
