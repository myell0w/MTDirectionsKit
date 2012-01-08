#import "MTDirectionsRequest.h"
#import "MTDirectionsRequestMapQuest.h"
#import "MTDirectionsRequestGoogle.h"
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
        case MTDirectionsAPIGoogle:
            request = [[MTDirectionsRequestGoogle alloc] initFrom:fromCoordinate
                                                               to:toCoordinate
                                                        routeType:routeType
                                                       completion:completion];
            break;
            
        case MTDirectionsAPIMapQuest:
        default:
            request = [[MTDirectionsRequestMapQuest alloc] initFrom:fromCoordinate
                                                                 to:toCoordinate
                                                          routeType:routeType
                                                         completion:completion];
            break;
            
    }
    
    return request;
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
