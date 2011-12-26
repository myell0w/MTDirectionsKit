//
//  MTDirectionRequest.m
//  WhereTU
//
//  Created by Tretter Matthias on 25.12.11.
//  Copyright (c) 2011 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "MTDirectionRequest.h"
#import "MTWaypoint.h"
#import "MTXMLFetcher.h"
#import "MTXPathResultNode.h"

#define kMTDirectionBaseURL         @"http://open.mapquestapi.com/directions/v0/route?outFormat=xml&unit=k&narrativeType=none"
#define kMTDirectionXPathQuery      @"//startPoint"
#define kMTDirectionLatitudeNode    @"lat"
#define kMTDirectionLongitudeNode   @"lng"


@interface MTDirectionRequest ()

@property (nonatomic, assign) CLLocationCoordinate2D fromCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D toCoordinate;
@property (nonatomic, strong) MTXMLFetcher *fetcher;
@property (nonatomic, copy) mt_direction_block completion;

- (void)requestFinished:(MTXMLFetcher *)fetcher;

@end

@implementation MTDirectionRequest

@synthesize fromCoordinate = fromCoordinate_;
@synthesize toCoordinate = toCoordinate_;
@synthesize fetcher = fetcher_;
@synthesize completion = completion_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
    completion:(mt_direction_block)completion {
    return [self initFrom:fromCoordinate
                       to:toCoordinate
            routeType:MTDirectionRouteTypePedestrian
               completion:completion];
}

- (id)initFrom:(CLLocationCoordinate2D)fromCoordinate
            to:(CLLocationCoordinate2D)toCoordinate
     routeType:(MTDirectionRouteType)routeType
    completion:(mt_direction_block)completion {
    if ((self = [super init])) {
        fromCoordinate_ = fromCoordinate;
        toCoordinate_ = toCoordinate;
        completion_ = completion;
        
        NSString *address = [NSString stringWithFormat:@"%@&from=%f,%f&to=%f,%f&routeType=%@",
                             kMTDirectionBaseURL, 
                             fromCoordinate.latitude, fromCoordinate.longitude,
                             toCoordinate.latitude, toCoordinate.longitude,
                             MTDirectionAPIStringForDirectionRouteType(routeType)];
        
        fetcher_ = [[MTXMLFetcher alloc] initWithURLString:address
                                                xPathQuery:kMTDirectionXPathQuery
                                                  receiver:self
                                                    action:@selector(requestFinished:)];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDirectionRequest
////////////////////////////////////////////////////////////////////////

- (void)start {
    [self.fetcher start];
}

- (void)cancel {
    [self.fetcher cancel];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)requestFinished:(MTXMLFetcher *)fetcher {
    NSMutableArray *waypoints = [NSMutableArray arrayWithCapacity:fetcher.results.count];
    
    // add start coordinate
    [waypoints addObject:[MTWaypoint waypointWithCoordinate:self.fromCoordinate]];
    
    // add all maneuvers
    for (MTXPathResultNode *resultNode in fetcher.results) {
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
    
    self.completion(waypoints);
}

@end
