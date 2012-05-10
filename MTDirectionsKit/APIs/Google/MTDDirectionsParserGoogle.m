#import "MTDDirectionsParserGoogle.h"
#import "MTDDirectionsOverlay.h"

@implementation MTDDirectionsParserGoogle

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionsParser
////////////////////////////////////////////////////////////////////////

- (void)parseWithCompletion:(mtd_direction_block)completion {
    NSString *xml = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    MTDDirectionsOverlay *overlay = nil;
    
    NSLog(@"Google XML: \n\n%@", xml);
    
    if (completion != nil) {
        completion(overlay);
    }
}


@end
