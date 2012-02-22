#import "MTManeuverAnnotationView.h"
#import "MTManeuver.h"

@implementation MTManeuverAnnotationView

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (NSString *)reuseIdentifer {
    return NSStringFromClass([self class]);
}

+ (id)annotationViewForMapView:(MKMapView *)mapView maneuver:(MTManeuver *)maneuver {
    NSString *reuseIdentifier = [self reuseIdentifer];
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    if (annotationView == nil) {
        annotationView = [[self alloc] initWithManeuver:maneuver];
    } else {
        annotationView.annotation = maneuver;
    }
    
    return annotationView; 
}

- (id)initWithManeuver:(MTManeuver *)maneuver {
    return [self initWithAnnotation:maneuver reuseIdentifier:kMTManeuverAnnotationViewReuseIdentifier];
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
        self.opaque = NO;
        self.canShowCallout = NO;
        self.clipsToBounds = NO;
        self.frame = CGRectMake(0.f,0.f,15.f,15.f);
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat centerX = CGRectGetMidX(self.bounds);
    CGFloat centerY = CGRectGetMidY(self.bounds);
    CGFloat radius = self.bounds.size.width/2.f;
    
    CGContextSaveGState(context);
    
    {
        CGContextBeginPath(context);
        CGContextSetLineWidth(context,2.f);
        CGContextSetFillColorWithColor(context, [[UIColor blueColor] colorWithAlphaComponent:0.4].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextAddEllipseInRect(context, CGRectMake(centerX - radius, centerY - radius, 2*radius, 2*radius));
        CGContextFillPath(context);
    }
    
    CGContextRestoreGState(context);
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTManeuverAnnotationView
////////////////////////////////////////////////////////////////////////

- (MTManeuver *)maneuver {
    return (MTManeuver *)self.annotation;
}

@end
