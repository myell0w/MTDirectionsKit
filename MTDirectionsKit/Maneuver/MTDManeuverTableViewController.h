//
//  MTDManeuverTableViewController.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


#import "MTDWeak.h"


@class MTDRoute;
@class MTDManeuver;
@protocol MTDManeuverTableViewControllerDelegate;


/**
 MTDManeuverTableViewController is a subclass of UITableViewController that can be used to 
 conveniently display a list of textual instructions of a route.
 */
@interface MTDManeuverTableViewController : UITableViewController

/** The route which maneuvers get displayed */
@property (nonatomic, readonly) MTDRoute *route;
/** The delegate for information about maneuver-specific events */
@property (nonatomic, mtd_weak) id<MTDManeuverTableViewControllerDelegate> maneuverDelegate;

/**
 The designated intializer. Creates an instance of MTDManeuverTableViewController with the given
 route and the style UITableViewStylePlain.
 
 @param route the route to display the maneuvers of
 @return an instance of MTDManeuverTableViewController
 */
- (id)initWithRoute:(MTDRoute *)route;

/**
 Returns the maneuver at the given indexPath.
 
 @param indexPath the index path of the row
 @return an instance of MTDManeuver that is displayed at the given indexPath
 */
- (MTDManeuver *)maneuverAtIndexPath:(NSIndexPath *)indexPath;

@end
