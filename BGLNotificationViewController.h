@interface BGLNotificationViewController : UIViewController {
	NSArray *_bundleIdentifiers;
	UIVisualEffectView *_blurView;
}

- (instancetype)initWithBundleIdentifier:(NSString *)bundleID;
- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs;


@end