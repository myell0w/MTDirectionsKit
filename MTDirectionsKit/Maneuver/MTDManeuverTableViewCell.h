//
//  MTDManeuverTableViewCell.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDManeuver;


/**
 MTDManeuverTableViewCell is a UITableViewCell subclass that can be used to display information
 about a maneuver. It is modeled after the interface of the built-in iOS 6 Maps App with the
 distance as the title and the textual description as the subtitle and an optional image
 describing the turn type.
 */
@interface MTDManeuverTableViewCell : UITableViewCell

/** The maneuver to display in this cell */
@property (nonatomic, strong) MTDManeuver *maneuver;

/**
 This class method can be used to compute the height that would be needed for a cell
 to display the given maneuver with the set distance and instructions font.
 This method can be used in tableView:heightForRowAtIndexPath:
 
 @param maneuver the maneuver to compute the needed height of
 @param width the width of the tableView
 @return the height of the cell
 
 @see setDistanceFont:
 @see setInstructionsFont:
 */
+ (CGFloat)neededHeightForManeuver:(MTDManeuver *)maneuver constrainedToWidth:(CGFloat)width;

/**
 Sets the font that is used to display the distance. This font gets set on the textLabel
 of the cell.
 
 @param distanceFont the font to use for the distance
 */
+ (void)setDistanceFont:(UIFont *)distanceFont;

/**
 Sets the font that is used to display the textual instructions.
 This font gets set on the detailLabel of the cell.
 
 @param instructionsFont the font to use for the textual instructions
 */
+ (void)setInstructionsFont:(UIFont *)instructionsFont;

/**
 Let's you programatically hide the turn type image displayed on the left, if 
 MTDirectionsKit.bundle is added to your resources. Defaults to NO.
 
 @param imageHidden YES if you want to hide the image, NO otherwise
 */
+ (void)setTurnTypeImageHidden:(BOOL)imageHidden;

/**
 Set the background color of the cell for the selected state. You can easily customize this property using UIAppearance.
 
 e.g. [[MTDManeuverTableViewCell appearance] setSelectedBackgroundColor:[UIColor redColor]];

 @param backgroundColor the color of the selectedBackgroundView
 */
- (void)setSelectedBackgroundColor:(UIColor *)backgroundColor UI_APPEARANCE_SELECTOR;

@end
