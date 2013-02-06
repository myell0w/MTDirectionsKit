#import "MTDManeuverTableViewController.h"
#import "MTDManeuverTableViewCell.h"
#import "MTDManeuverTableViewControllerDelegate.h"
#import "MTDRoute.h"
#import "MTDManeuver.h"
#import "MTDWaypoint.h"
#import "MTDAddress.h"
#import "MTDFunctions.h"


#define kMTDInfoCellHeight                  60.f
#define kMTDFromToCellHeight                65.f


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
        self.title = MTDLocalizedStringFromUIKit(@"Route");

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

    { // Watermark
        UILabel *watermarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 75.f)];
        watermarkLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        watermarkLabel.backgroundColor = [UIColor colorWithRed:1.f green:0.f blue:0.f alpha:0.4f];
        watermarkLabel.textAlignment = UITextAlignmentCenter;
        watermarkLabel.text = @"MTDirectionsKit Demo Version:\nThis watermarked version only supports German instructions.";
        watermarkLabel.numberOfLines = 0;
        self.tableView.tableHeaderView = watermarkLabel;
    }

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
    NSInteger row = indexPath.row - 2; // -2 => info cell, from location cell

    if (row >= 0 && (NSUInteger)row < self.route.maneuvers.count) {
        return self.route.maneuvers[(NSUInteger)row];
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
    return (NSInteger)[self.route.maneuvers count] + 3; // +3 => Route Info cell, start location cell, end location cell
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    if ([self mtd_isInfoCellAtIndexPath:indexPath]) {
        cell = [self mtd_infoCellForTableView:tableView indexPath:indexPath];
    } else if ([self mtd_isFromLocationCellAtIndexPath:indexPath]) {
        cell = [self mtd_fromLocationCellForTableView:tableView indexPath:indexPath];
    } else if ([self mtd_isToLocationCellAtIndexPath:indexPath]) {
        cell = [self mtd_toLocationCellForTableView:tableView indexPath:indexPath];
    } else {
        cell = [self mtd_maneuverCellForTableView:tableView indexPath:indexPath];
    }

    MTDAssert(cell != nil, @"No cell was created for the given indexPath: %@", indexPath);
    
    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self mtd_isInfoCellAtIndexPath:indexPath]) {
        return kMTDInfoCellHeight;
    } else if ([self mtd_isFromLocationCellAtIndexPath:indexPath] || [self mtd_isToLocationCellAtIndexPath:indexPath]) {
        return kMTDFromToCellHeight;
    }  else {
        MTDManeuver *maneuver = [self maneuverAtIndexPath:indexPath];

        return [MTDManeuverTableViewCell neededHeightForManeuver:maneuver constrainedToWidth:CGRectGetWidth(tableView.bounds)];
    }
}

- (NSIndexPath *)tableView:(__unused UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self mtd_isInfoCellAtIndexPath:indexPath]
        || [self mtd_isFromLocationCellAtIndexPath:indexPath]
        || [self mtd_isToLocationCellAtIndexPath:indexPath]) {
        return nil;
    }

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
#pragma mark -
#pragma mark - Private
#pragma mark -
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
#pragma mark - UI
////////////////////////////////////////////////////////////////////////

- (BOOL)mtd_isInfoCellAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0;
}

- (BOOL)mtd_isFromLocationCellAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 1;
}

- (BOOL)mtd_isToLocationCellAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger)indexPath.row;
    
    return row == [self.route.maneuvers count] + 2;
}

- (UITableViewCell *)mtd_infoCellForTableView:(UITableView *)tableView indexPath:(__unused NSIndexPath *)indexPath {
    static NSString *cellID = @"MTDManeuverInfoTableViewCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];

        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.f];
        cell.textLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.clipsToBounds = YES;
    }

    cell.textLabel.text = self.route.name ?: self.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", self.route.formattedTime, self.route.distance];
    cell.imageView.image = [UIImage imageNamed:@"MTDirectionsKit.bundle/route-header"];

    return cell;
}

- (UITableViewCell *)mtd_fromLocationCellForTableView:(UITableView *)tableView indexPath:(__unused NSIndexPath *)indexPath {
    static NSString *cellID = @"MTDManeuverFromLocationTableViewCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    MTDWaypoint *from = self.route.from;

    if (cell == nil) {
        cell = [self mtd_fromToCellWithReuseIdentifier:cellID];
    }

    cell.imageView.image = [UIImage imageNamed:@"MTDirectionsKit.bundle/cell-depart"];
    cell.textLabel.text = [from.address fullAddress] ?: MTDLocalizedStringFromUIKit(@"Departure");

    return cell;
}

- (UITableViewCell *)mtd_toLocationCellForTableView:(UITableView *)tableView indexPath:(__unused NSIndexPath *)indexPath {
    static NSString *cellID = @"MTDManeuverToLocationTableViewCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    MTDWaypoint *to = self.route.to;

    if (cell == nil) {
        cell = [self mtd_fromToCellWithReuseIdentifier:cellID];
    }

    cell.imageView.image = [UIImage imageNamed:@"MTDirectionsKit.bundle/cell-arrive"];
    cell.textLabel.text = [to.address fullAddress] ?: MTDLocalizedStringFromUIKit(@"Destination");

    return cell;
}

- (UITableViewCell *)mtd_maneuverCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"MTDManeuverTableViewCell";

    MTDManeuverTableViewCell *cell = (MTDManeuverTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    MTDManeuver *maneuver = [self maneuverAtIndexPath:indexPath];

    if (cell == nil) {
        cell = [[MTDManeuverTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }

    cell.maneuver = maneuver;

    return cell;
}

- (UITableViewCell *)mtd_fromToCellWithReuseIdentifier:(NSString *)cellID {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];

    cell.textLabel.numberOfLines = 3;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.f];
    cell.textLabel.backgroundColor = [UIColor colorWithRed:229.f/255.f green:234.f/255.f blue:239.f/255.f alpha:1.f];
    cell.contentView.backgroundColor = cell.textLabel.backgroundColor;
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.clipsToBounds = YES;

    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Delegate
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
