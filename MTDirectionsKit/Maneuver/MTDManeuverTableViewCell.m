#import "MTDManeuverTableViewCell.h"
#import <MTDirectionsKit/MTDirectionsKit.h>


#define kMTDImageViewFrame                  CGRectMake(5.f,5.f,50.f,50.f)
#define kMTDImageViewWidthIncludingMargin   (2*CGRectGetMinX(kMTDImageViewFrame) + CGRectGetWidth(kMTDImageViewFrame))
#define kMTDImageViewHeightIncludingMargin  (2*CGRectGetMinY(kMTDImageViewFrame) + CGRectGetHeight(kMTDImageViewFrame))
#define kMTDMinCellHeight                   kMTDImageViewHeightIncludingMargin


static UIFont *mtd_distanceFont = nil;
static UIFont *mtd_instructionsFont = nil;
static BOOL mtd_bundleLoaded = NO;


@implementation MTDManeuverTableViewCell

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [MTDManeuverTableViewCell class]) {
        mtd_distanceFont = [UIFont boldSystemFontOfSize:16.f];
        mtd_instructionsFont = [UIFont systemFontOfSize:12.f];

        // Test if the bundle was added to see if the images can be displayed.
        // If not, we don't use the imageView size to calculate the size of the cell
        UIImage *testImage = MTDGetImageForTurnType(MTDTurnTypeLeft);
        mtd_bundleLoaded = testImage != nil;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.textLabel.textColor = [UIColor darkGrayColor];
        self.textLabel.font = mtd_distanceFont;
        self.textLabel.lineBreakMode = UILineBreakModeClip;

        self.detailTextLabel.font = mtd_instructionsFont;
        self.detailTextLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
////////////////////////////////////////////////////////////////////////

+ (CGFloat)neededHeightForManeuver:(MTDManeuver *)maneuver constrainedToWidth:(CGFloat)width {
    BOOL imageVisible = mtd_bundleLoaded && maneuver.turnType != MTDTurnTypeUnknown;
    CGFloat innerWidth = width - 20.f;
    NSString *headerText = [maneuver.distance description];
    NSString *detailText = maneuver.instructions;

    if (imageVisible) {
        innerWidth -= kMTDImageViewWidthIncludingMargin;
    }

    CGSize constraint = CGSizeMake(innerWidth, CGFLOAT_MAX);

    CGSize sizeHeaderText = [headerText sizeWithFont:mtd_distanceFont
                                   constrainedToSize:constraint
                                       lineBreakMode:UILineBreakModeClip];
    CGSize sizeDetailText = [detailText sizeWithFont:mtd_instructionsFont
                                   constrainedToSize:constraint
                                       lineBreakMode:UILineBreakModeWordWrap];

    CGFloat computedHeight = sizeHeaderText.height + sizeDetailText.height + 16.f;
    CGFloat neededHeight = imageVisible ? MAX(computedHeight, kMTDMinCellHeight) : computedHeight;

    return neededHeight;
}

+ (void)setDistanceFont:(UIFont *)distanceFont {
    if (distanceFont != mtd_distanceFont) {
        mtd_distanceFont = distanceFont;
    }
}

+ (void)setInstructionsFont:(UIFont *)instructionsFont {
    if (instructionsFont != mtd_instructionsFont) {
        mtd_instructionsFont = instructionsFont;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = kMTDImageViewFrame;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewCell
////////////////////////////////////////////////////////////////////////

- (void)prepareForReuse {
    [super prepareForReuse];

    self.maneuver = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDManeuverTableViewCell
////////////////////////////////////////////////////////////////////////

- (void)setManeuver:(MTDManeuver *)maneuver {
    if (maneuver != _maneuver) {
        _maneuver = maneuver;

        if (maneuver != nil) {
            self.imageView.image = MTDGetImageForTurnType(maneuver.turnType);
            self.detailTextLabel.text = maneuver.instructions;

            if (maneuver.distance.distanceInMeter > 0.) {
                self.textLabel.text = [maneuver.distance description];
            } else {
                self.textLabel.text = nil;
            }
        } else {
            self.imageView.image = nil;
            self.textLabel.text = nil;
            self.detailTextLabel.text = nil;
        }
        
        [self setNeedsLayout];
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)backgroundColor {
    UIView *backgroundView = self.selectedBackgroundView;

    if (backgroundView == nil || ![backgroundView isMemberOfClass:[UIView class]]) {
        backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.selectedBackgroundView = backgroundView;
    }

    self.selectionStyle = UITableViewCellSelectionStyleGray;
    backgroundView.backgroundColor = backgroundColor;
}

@end
