#import "BGLNotificationTableViewDataSource.h"
#import <SpringBoard/SBIconView.h>
#import <SpringBoard/SBIconListView.h>

@interface BGLNotificationViewController : UIViewController {
	NSArray *_bundleIdentifiers;
	SBIconView *_iconView;
	UITableView *_tableView;
	UIVisualEffectView *_blurView;
	BGLNotificationTableViewDataSource *_dataSource;
}

- (instancetype)initWithIconView:(SBIconView *)iconView;
- (void)hideAndRelease:(BOOL)animated;

@property (nonatomic, retain) SBIconListView *listView;
@property (nonatomic, readonly) SBIconListView *dockListView;

@end