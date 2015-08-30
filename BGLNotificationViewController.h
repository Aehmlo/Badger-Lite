@interface BGLNotificationViewController : UIViewController {
	NSArray *_bundleIdentifiers;
	UITableView *_tableView;
	UIVisualEffectView *_blurView;
}

- (instancetype)initWithBundleIdentifier:(NSString *)bundleID;
- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs;


@end