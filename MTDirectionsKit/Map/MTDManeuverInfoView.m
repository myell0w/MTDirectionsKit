#import "MTDManeuverInfoView.h"


@interface MTDManeuverInfoView ()

@property (nonatomic, strong) UILabel *infoLabel;

@end


@implementation MTDManeuverInfoView

@synthesize infoLabel = _infoLabel;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTDManeuverInfoView *)infoViewForMapView:(MKMapView *)mapView {
    MTDManeuverInfoView *infoView = [[MTDManeuverInfoView alloc] initWithFrame:CGRectMake(0.f, 0.f, mapView.bounds.size.width, 150.f)];
    
    return infoView;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor grayColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _infoLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textColor = [UIColor blackColor];
        [self addSubview:_infoLabel];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDManeuverInfoView
////////////////////////////////////////////////////////////////////////

- (void)setInfoText:(NSString *)infoText {
    self.infoLabel.text = infoText;
}

- (NSString *)infoText {
    return self.infoLabel.text;
}

@end
