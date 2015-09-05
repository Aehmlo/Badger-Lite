@interface BGLNotificationTableViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
	NSArray *_bundleIdentifiers;
	NSArray *_cachedBulletins;
}

- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs;

@end