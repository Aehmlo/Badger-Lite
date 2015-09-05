#import "BGLNotificationTableViewDataSource.h"
#import <SpringBoard/SBIconView.h>

@interface BGLNotificationViewController : UIViewController {
	NSArray *_bundleIdentifiers;
	SBIconView *_iconView;
	UITableView *_tableView;
	UIVisualEffectView *_blurView;
	BGLNotificationTableViewDataSource *_dataSource;
}

- (instancetype)initWithIconView:(SBIconView *)iconView;
- (void)hideAndRelease:(BOOL)animated;


@end