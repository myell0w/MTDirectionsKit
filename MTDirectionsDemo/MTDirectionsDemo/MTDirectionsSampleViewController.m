#import "MTDirectionsSampleViewController.h"
#import "MTDirectionsKit.h"


@interface MTDirectionsSampleViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MTDMapView *mapView;

@end



@implementation MTDirectionsSampleViewController

@synthesize mapView = _mapView;

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.mapView = [[MTDMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(51.459596, -0.973277),
                                                 MKCoordinateSpanMake(0.026846, 0.032959));
    [self.view addSubview:self.mapView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CLLocationCoordinate2D from = CLLocationCoordinate2DMake(51.38713, -1.0316);
    CLLocationCoordinate2D to = CLLocationCoordinate2DMake(51.4554, -0.9742);
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.mapView loadDirectionsFrom:from
                                      to:to
                               routeType:MTDDirectionsRouteTypeFastestDriving
                    zoomToShowDirections:YES];
    });
}


@end
