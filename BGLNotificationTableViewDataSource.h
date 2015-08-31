@interface BGLNotificationTableViewDataSource : NSObject <UITableViewDataSource> {
	NSArray *_bundleIdentifiers;
	NSArray *_cachedBulletins;
}

- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs;

@end