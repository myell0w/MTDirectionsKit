//
//  MTDirectionsSampleViewController.m
//  MTDirectionsDemo
//
//  Created by Tretter Matthias on 19.03.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "MTDirectionsSampleViewController.h"
#import "MTDirections.h"

@interface MTDirectionsSampleViewController ()

@property (nonatomic, strong) MTMapView *mapView;

@end

@implementation MTDirectionsSampleViewController

@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.mapView = [[MTMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CLLocationCoordinate2D from = CLLocationCoordinate2DMake(51.38713, -1.0316);
    CLLocationCoordinate2D to = CLLocationCoordinate2DMake(51.4554, -0.9742);
    
    [self.mapView loadDirectionsFrom:from
                                  to:to
                           routeType:MTDirectionsRouteTypeFastestDriving
                zoomToShowDirections:YES];
}

@end
