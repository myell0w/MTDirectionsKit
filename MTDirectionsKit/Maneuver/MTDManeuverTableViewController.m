#import "MTDManeuverTableViewController.h"
#import "MTDManeuverTableViewCell.h"
#import "MTDManeuverTableViewControllerDelegate.h"
#import <MTDirectionsKit/MTDirectionsKit.h>


@implementation MTDManeuverTableViewController

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithRoute:(MTDRoute *)route {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.title = route.name;

        _route = route;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDManeuverTableViewController
////////////////////////////////////////////////////////////////////////

- (MTDManeuver *)maneuverAtIndexPath:(NSIndexPath *)indexPath {
    return [self.route.maneuvers objectAtIndex:(NSUInteger)indexPath.row];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return (NSInteger)[self.route.maneuvers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"MTDManeuverTableViewCell";

    MTDManeuver *maneuver = [self maneuverAtIndexPath:indexPath];
    MTDManeuverTableViewCell *cell = (MTDManeuverTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];

    if (cell == nil) {
        cell = [[MTDManeuverTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }

    cell.maneuver = maneuver;
    
    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MTDManeuver *maneuver = [self maneuverAtIndexPath:indexPath];

    return [MTDManeuverTableViewCell neededHeightForManeuver:maneuver constrainedToWidth:tableView.bounds.size.width];
}

- (void)tableView:(__unused UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.maneuverDelegate maneuverTableViewController:self didSelectManeuverAtIndexPath:indexPath];
}

@end
