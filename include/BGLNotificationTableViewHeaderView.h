@interface BGLNotificationTableViewHeaderView : UIView {
	UILabel *_label;
	NSUInteger _unreadCount;
}

@property (nonatomic, assign) NSUInteger unreadCount;

@end