//
//  MTDManeuverTableViewControllerDelegate.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


@class MTDManeuverTableViewController;


/**
 The MTDManeuverTableViewControllerDelegate protocol defines a set of methods that you can implement to receive
 information updates from a MTDManeuverTableViewController.
 */
@protocol MTDManeuverTableViewControllerDelegate <NSObject>

@optional

/**
 Asks the delegate whether the maneuver at the given index path can be selected.
 
 @param maneuverTableViewController an instance of MTDManeuverTableViewController
 @param indexPath the index path of the row that got selected
 @return YES in case the maneuver can be selected, NO otherwise
 */
- (BOOL)maneuverTableViewController:(MTDManeuverTableViewController *)maneuverTableViewController canSelectManeuverAtIndexPath:(NSIndexPath *)indexPath;

/**
 Tells the delegate that the specific maneuveur at the given index path is now selected.
 
 @param maneuverTableViewController an instance of MTDManeuverTableViewController 
 @param indexPath the index path of the row that got selected
 */
- (void)maneuverTableViewController:(MTDManeuverTableViewController *)maneuverTableViewController didSelectManeuverAtIndexPath:(NSIndexPath *)indexPath;

@end
