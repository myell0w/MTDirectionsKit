#import "MTDirectionsRequest.h"
#import "MTDirectionsRequestMapQuest.h"
#import "MTDirectionsAPI.h"

@implementation MTDirectionsRequest

@synthesize fromCoordinate = fromCoordinate_;
@synthesize toCoordinate = toCoordinate_;
@synthesize completion = completion_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (id)requestFrom:(CLLocationCoordinate2D)fromCoordinate
               to:(CLLocationCoordinate2D)toCoordinate
       completion:(mt_direction_block)completion {
    return [self requestFrom:fromCoordinate
                          to:toCoordinate
                   routeType:kMTDefaultDirectionsRouteType
                  completion:completion];
}

+ (id)requestFrom:(CLLocationCoordinate2D)fromCoordinate
               to:(CLLocationCoordinate2D)toCoordinate
        routeType:(MTDirectionsRouteType)routeType
       completion:(mt_direction_block)completion {
    MTDirectionsRequest *request = nil;
    
    switch (kMTDirectionsActiveAPI) {
        case MTDirectionsAPIMapQuest:
            request = [[MTDirectionsRequestMapQuest alloc] initFrom:fromCoordinate
                                                                 to:toCoordinate
                                                          routeType:routeType
                                                         completion:completion];
            break;
            
        default:
            // nothing to do here
            break;
    }
    
    return request;
}

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
    completion:(mt_direction_block)completion {
    return [self initFrom:fromCoordinate
                       to:toCoordinate
                routeType:kMTDefaultDirectionsRouteType
               completion:completion];
}

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDirectionsRouteType)routeType
    completion:(mt_direction_block)completion {
    if ((self = [super init])) {
        fromCoordinate_ = fromCoordinate;
        toCoordinate_ = toCoordinate;
        completion_ = completion;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionRequest
////////////////////////////////////////////////////////////////////////

- (void)start {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)cancel {
    [self doesNotRecognizeSelector:_cmd];
}

@end
