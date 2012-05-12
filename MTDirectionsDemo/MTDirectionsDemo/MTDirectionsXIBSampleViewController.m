#import "MTDirectionsXIBSampleViewController.h"
#import <MTDirectionsKit/MTDirectionsKit.h>


@interface MTDirectionsXIBSampleViewController ()

@property (nonatomic, strong) IBOutlet MTDMapView *mapView;

@end


@implementation MTDirectionsXIBSampleViewController

@synthesize mapView = _mapView;

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(51.459596, -0.973277),
                                                  MKCoordinateSpanMake(0.026846, 0.032959));
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
