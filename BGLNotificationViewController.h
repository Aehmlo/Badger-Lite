#import "BGLNotificationTableViewDataSource.h"

@interface BGLNotificationViewController : UIViewController {
	NSArray *_bundleIdentifiers;
	UITableView *_tableView;
	UIVisualEffectView *_blurView;
	BGLNotificationTableViewDataSource *_dataSource;
}

- (instancetype)initWithBundleIdentifier:(NSString *)bundleID;
- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs;


@end