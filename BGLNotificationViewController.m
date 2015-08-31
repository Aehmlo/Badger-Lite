#import "BGLNotificationViewController.h"
#import "BGLNotificationTableViewDataSource.h"

extern NSString *const kBGLNotificationCellReuseIdentifier;

@implementation BGLNotificationViewController

extern NSInteger blurStyle;

- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs {

	if((self = [super init])) {
		_bundleIdentifiers = [bundleIDs retain];
	}

	return self;

}

- (instancetype)initWithBundleIdentifier:(NSString *)bundleID {
	return [self initWithBundleIdentifiers:@[bundleID]];
}

- (void)viewDidLoad {

	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	self.view.alpha = 0;

	UIBlurEffectStyle style;

	switch(blurStyle) {
		case 2:
			style = UIBlurEffectStyleLight;
			break;
		case 3:
			style = UIBlurEffectStyleExtraLight;
			break;
		default:
			style = UIBlurEffectStyleDark;
			break;
	}

	_blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
	_blurView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_blurView];
	[self.view addConstraints:@[
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:200],
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]
	]];
	[_blurView release];

	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.tableFooterView = [[[UIView alloc] init] autorelease];
	_tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kBGLNotificationCellReuseIdentifier];
	_tableView.dataSource = [[[BGLNotificationTableViewDataSource alloc] initWithBundleIdentifiers:_bundleIdentifiers] autorelease];
	[_blurView addSubview:_tableView];
	[self.view addConstraints:@[
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]
	]];
	[_tableView release];

}

- (void)dealloc {
	[_bundleIdentifiers release];
	[super dealloc];
}

@end
