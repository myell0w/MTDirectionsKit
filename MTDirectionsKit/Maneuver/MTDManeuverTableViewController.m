#import "MTDManeuverTableViewController.h"
#import "MTDManeuverTableViewCell.h"
#import "MTDManeuverTableViewControllerDelegate.h"
#import "MTDRoute.h"
#import "MTDManeuver.h"


@implementation MTDManeuverTableViewController {
    // flags for methods implemented in the delegate
    struct {
        unsigned int canSelect:1;
        unsigned int didSelect:1;
	} _delegateFlags;

    BOOL _hideTurnTypeImages;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithRoute:(MTDRoute *)route {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.title = route.name;

        _route = route;

        NSArray *maneuversWithDefinedTurnType = [route.maneuvers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MTDManeuver *evaluatedObject, __unused NSDictionary *bindings) {
            return evaluatedObject.turnType != MTDTurnTypeUnknown;
        }]];

        _hideTurnTypeImages = maneuversWithDefinedTurnType.count == 0;
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [MTDManeuverTableViewCell setTurnTypeImageHidden:_hideTurnTypeImages];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDManeuverTableViewController
////////////////////////////////////////////////////////////////////////

- (MTDManeuver *)maneuverAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger)indexPath.row;

    if (row < self.route.maneuvers.count) {
        return self.route.maneuvers[row];
    }

    return nil;
}

- (void)setManeuverDelegate:(id<MTDManeuverTableViewControllerDelegate>)maneuverDelegate {
    if (maneuverDelegate != _maneuverDelegate) {
        _maneuverDelegate = maneuverDelegate;

        // update delegate flags
        _delegateFlags.canSelect = (unsigned int)[maneuverDelegate respondsToSelector:@selector(maneuverTableViewController:canSelectManeuverAtIndexPath:)];
        _delegateFlags.didSelect = (unsigned int)[maneuverDelegate respondsToSelector:@selector(maneuverTableViewController:didSelectManeuverAtIndexPath:)];
    }
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

    return [MTDManeuverTableViewCell neededHeightForManeuver:maneuver constrainedToWidth:CGRectGetWidth(tableView.bounds)];
}

- (NSIndexPath *)tableView:(__unused UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canSelect = [self mtd_askDelegateIfSelectionIsSupportedAtIndexPath:indexPath];

    if (canSelect) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(__unused UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self mtd_notifyDelegateDidSelectManeuverAtIndexPath:indexPath];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (BOOL)mtd_askDelegateIfSelectionIsSupportedAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateFlags.canSelect) {
        id<MTDManeuverTableViewControllerDelegate> delegate = self.maneuverDelegate;

        return [delegate maneuverTableViewController:self canSelectManeuverAtIndexPath:indexPath];
    }

    return NO;
}

- (void)mtd_notifyDelegateDidSelectManeuverAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateFlags.didSelect) {
        id<MTDManeuverTableViewControllerDelegate> delegate = self.maneuverDelegate;

        [delegate maneuverTableViewController:self didSelectManeuverAtIndexPath:indexPath];
    }
}

@end
