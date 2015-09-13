#import "BGLNotificationTableViewHeaderView.h"

@implementation BGLNotificationTableViewHeaderView

- (instancetype)init {
	if((self = [super init])) {
		_label = [[UILabel alloc] init];
		_label.numberOfLines = 1;
		_label.font = [UIFont systemFontOfSize:20];
		_label.textColor = [UIColor whiteColor];
		_label.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_label];
		[self addConstraints:@[
			[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:10],
			[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
			[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0],
			[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-20]
		]];
		[_label release];
	}
	return self;
}

- (void)setUnreadCount:(NSUInteger)unreadCount {

	switch(unreadCount) {
		case 0:
			_label.text = @"No Unread Notifications";
			break;
		case 1:
			_label.text = @"1 Unread Notification";
			break;
		default:
			_label.text = [NSString stringWithFormat:@"%lu Unread Notifications", (unsigned long)unreadCount];
			break;
	}

	_unreadCount = unreadCount;

}

- (NSUInteger)unreadCount {
	return _unreadCount;
}

@end