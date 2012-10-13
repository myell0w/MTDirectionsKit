#import "MTDManeuverTableViewCell.h"
#import <MTDirectionsKit/MTDirectionsKit.h>


static UIFont *mtd_distanceFont = nil;
static UIFont *mtd_instructionsFont = nil;


@implementation MTDManeuverTableViewCell

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (void)initialize {
    if (self == [MTDManeuverTableViewCell class]) {
        mtd_distanceFont = [UIFont boldSystemFontOfSize:16.f];
        mtd_instructionsFont = [UIFont systemFontOfSize:12.f];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;

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
    BOOL imageVisible = NO; // maneuver.turnType != MTDTurnTypeUnknown;
    CGFloat innerWidth = width - 20.f;
    NSString *headerText = [maneuver.distance description];
    NSString *detailText = maneuver.instructions;

    if (imageVisible) {
        // innerWidth -= CGRectGetWidth(kFKImageViewRect) + kFKPaddingXLeft;
    }

    CGSize constraint = CGSizeMake(innerWidth, CGFLOAT_MAX);

    CGSize sizeHeaderText = [headerText sizeWithFont:mtd_distanceFont
                                   constrainedToSize:constraint
                                       lineBreakMode:UILineBreakModeClip];
    CGSize sizeDetailText = [detailText sizeWithFont:mtd_instructionsFont
                                   constrainedToSize:constraint
                                       lineBreakMode:UILineBreakModeWordWrap];

    CGFloat computedHeight = sizeHeaderText.height + sizeDetailText.height + 16.f;
    CGFloat neededHeight = imageVisible ? MAX(computedHeight, 50.f) : computedHeight;

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
#pragma mark - UITableViewCell
////////////////////////////////////////////////////////////////////////

- (void)setManeuver:(MTDManeuver *)maneuver {
    if (maneuver != _maneuver) {
        _maneuver = maneuver;

        self.textLabel.text = [maneuver.distance description];
        self.detailTextLabel.text = maneuver.instructions;
        [self setNeedsLayout];
    }
}

@end
