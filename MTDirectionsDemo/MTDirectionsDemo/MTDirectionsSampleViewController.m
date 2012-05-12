#import "MTDirectionsSampleViewController.h"
#import <MTDirectionsKit/MTDirectionsKit.h>


@interface MTDirectionsSampleViewController () <MKMapViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MTDMapView *mapView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UIBarButtonItem *searchItem;
@property (nonatomic, strong) UIBarButtonItem *routeItem;
@property (nonatomic, strong) UIBarButtonItem *cancelItem;

@property (nonatomic, strong) UIView *routeBackgroundView;
@property (nonatomic, strong) UITextField *fromControl;
@property (nonatomic, strong) UITextField *toControl;

@property (nonatomic, readonly, getter = isSearchUIVisible) BOOL searchUIVisible;

- (void)handleSearchItemPress:(id)sender;
- (void)handleRouteItemPress:(id)sender;
- (void)handleCancelItemPress:(id)sender;

- (void)hideRouteView;
- (void)performSearch;

@end


@implementation MTDirectionsSampleViewController

@synthesize mapView = _mapView;
@synthesize segmentedControl = _segmentedControl;
@synthesize searchItem = _searchItem;
@synthesize routeItem = _routeItem;
@synthesize cancelItem = _cancelItem;
@synthesize routeBackgroundView = _routeBackgroundView;
@synthesize fromControl = _fromControl;
@synthesize toControl = _toControl;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"MTDirecionsKit";
    }
    
    return self;
}

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
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                       [UIImage imageNamed:@"pedestrian"],
                                                                       [UIImage imageNamed:@"bicycle"],
                                                                       [UIImage imageNamed:@"car"], nil]];
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentedControl.selectedSegmentIndex = 0;
    
    self.searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                    target:self
                                                                    action:@selector(handleSearchItemPress:)];
    self.navigationItem.leftBarButtonItem = self.searchItem;
    
    self.routeItem = [[UIBarButtonItem alloc] initWithTitle:@"Route" 
                                                      style:UIBarButtonItemStyleDone
                                                     target:self 
                                                     action:@selector(handleRouteItemPress:)];
    
    self.cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                       style:UIBarButtonItemStyleDone
                                                      target:self 
                                                      action:@selector(handleCancelItemPress:)];
    
    self.routeBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -75.f, self.view.bounds.size.width, 75.f)];
    self.routeBackgroundView.backgroundColor = [UIColor grayColor];
    self.routeBackgroundView.alpha = 0.f;
    [self.view addSubview:self.routeBackgroundView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 50.f, 30.f)];
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.textAlignment = UITextAlignmentRight;
    label.text = @"Start:";
    
    self.fromControl = [[UITextField alloc] initWithFrame:CGRectMake(5.f, 5.f, self.view.bounds.size.width-10.f, 30.f)];
    self.fromControl.borderStyle = UITextBorderStyleRoundedRect;
    self.fromControl.leftViewMode = UITextFieldViewModeAlways;
    self.fromControl.leftView = label;
    self.fromControl.returnKeyType = UIReturnKeyNext;
    self.fromControl.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.fromControl.delegate = self;
    [self.routeBackgroundView addSubview:self.fromControl];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 50.f, 30.f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.textAlignment = UITextAlignmentRight;
    label.text = @"End:";
    
    self.toControl = [[UITextField alloc] initWithFrame:CGRectMake(5.f, self.fromControl.frame.origin.y + self.fromControl.frame.size.height + 5.f,
                                                                  self.view.bounds.size.width-10.f, 30.f)];
    self.toControl.borderStyle = UITextBorderStyleRoundedRect;
    self.toControl.leftViewMode = UITextFieldViewModeAlways;
    self.toControl.leftView = label;
    self.toControl.returnKeyType = UIReturnKeyRoute;
    self.toControl.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.toControl.delegate = self;
    [self.routeBackgroundView addSubview:self.toControl];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
    
    self.searchItem = nil;
    self.routeItem = nil;
    self.cancelItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    self.segmentedControl = nil;
    
    self.routeBackgroundView = nil;
    self.fromControl = nil;
    self.toControl = nil;
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

////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.fromControl) {
        [self.toControl becomeFirstResponder];
    } else {
        [self performSearch];
        [self.toControl resignFirstResponder];
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (BOOL)isSearchUIVisible {
    return self.navigationItem.titleView == self.segmentedControl;
}

- (void)handleSearchItemPress:(id)sender {
    self.navigationItem.titleView = self.segmentedControl;
    [self.navigationItem setLeftBarButtonItem:self.cancelItem animated:YES];
    [self.navigationItem setRightBarButtonItem:self.routeItem animated:YES];
    
    CGRect frame = self.routeBackgroundView.frame;
    frame.origin.y = - frame.size.height;
    self.routeBackgroundView.frame = frame;
    frame.origin.y = 0.f;
    
    [self.fromControl becomeFirstResponder];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.routeBackgroundView.frame = frame;
                         self.routeBackgroundView.alpha = 1.f;
                     }];
}

- (void)handleCancelItemPress:(id)sender {
    self.fromControl.text = @"";
    self.toControl.text = @"";
    
    [self hideRouteView];
}

- (void)handleRouteItemPress:(id)sender {
    [self performSearch];
}

- (void)hideRouteView {
    self.navigationItem.titleView = nil;
    [self.navigationItem setLeftBarButtonItem:self.searchItem animated:YES];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    CGRect frame = self.routeBackgroundView.frame;
    frame.origin.y = - frame.size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.routeBackgroundView.frame = frame;
                         self.routeBackgroundView.alpha = 0.f;
                     }];
}

- (void)performSearch {
    NSLog(@"Search");
    [self hideRouteView];
}

@end
