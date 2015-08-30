@interface BGLNotificationTableViewDataSource : NSObject <UITableViewDataSource> {
	NSArray *_bundleIdentifiers;
}

- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs;

@end