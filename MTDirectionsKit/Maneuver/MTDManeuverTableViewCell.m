#import "MTDManeuverTableViewCell.h"
#import <MTDirectionsKit/MTDirectionsKit.h>


#define kMTDImageMargin                     10.f
#define kMTDImageViewSize                   CGSizeMake(40.f,42.f)
#define kMTDImageViewWidthIncludingMargin   (2*kMTDImageMargin + kMTDImageViewSize.width)
#define kMTDImageViewHeightIncludingMargin  (2*kMTDImageMargin + kMTDImageViewSize.height)
#define kMTDMinCellHeight                   (kMTDImageViewHeightIncludingMargin + 10.f)


static UIFont *mtd_distanceFont = nil;
static UIFont *mtd_instructionsFont = nil;
static UIImage *mtd_emptyImage = nil;
static BOOL mtd_bundleLoaded = NO;


@implementation MTDManeuverTableViewCell

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [MTDManeuverTableViewCell class]) {
        mtd_distanceFont = [UIFont systemFontOfSize:18.f];
        mtd_instructionsFont = [UIFont boldSystemFontOfSize:12.f];

        // Test if the bundle was added to see if the images can be displayed.
        // If not, we don't use the imageView size to calculate the size of the cell
        UIImage *testImage = MTDGetImageForTurnType(MTDTurnTypeLeft);
        mtd_bundleLoaded = testImage != nil;

        // if there is no image specified for some turn type we display a
        // transparent one instead to align the labels
        if (mtd_bundleLoaded) {
            mtd_emptyImage = MTDColoredImage(kMTDImageViewSize, [UIColor clearColor]);
        }
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.textLabel.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.f];
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

    CGFloat computedHeight = sizeHeaderText.height + sizeDetailText.height + 20.f;
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

    CGRect frame = self.imageView.frame;

    frame.size = kMTDImageViewSize;
    frame.origin.x = kMTDImageMargin;
    frame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(frame)) / 2.f;

    self.imageView.frame = CGRectIntegral(frame);
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
            if (mtd_bundleLoaded) {
                UIImage *image =  MTDGetImageForTurnType(maneuver.turnType);

                if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                    image = mtd_emptyImage;
                }

                self.imageView.image = image;
            } else {
                self.imageView.image = nil;
            }
            
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
