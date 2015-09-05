#import "BGLNotificationViewController.h"

#import "BGLNotificationTableViewCell.h"

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

	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_animateHideAndReleaseIfApplicable:)];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release];

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
	[_tableView registerClass:[BGLNotificationTableViewCell class] forCellReuseIdentifier:kBGLNotificationCellReuseIdentifier];
	_dataSource = [[BGLNotificationTableViewDataSource alloc] initWithBundleIdentifiers:_bundleIdentifiers];
	_tableView.dataSource = _dataSource;
	_tableView.delegate = _dataSource;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_tableView];
	[self.view addConstraints:@[
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]
	]];
	[_tableView release];

}

- (void)hideAndRelease:(BOOL)animated {
	[UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
		self.view.alpha = 0;
	} completion:^(BOOL complete) {
		if(complete) {
			[self.view removeFromSuperview];
			[self release];
		}
	}];
}

- (void)_animateHideAndReleaseIfApplicable:(UITapGestureRecognizer *)recognizer {
	if(recognizer.state != UIGestureRecognizerStateEnded) return; // goto fail;
	if([[self.view hitTest:[recognizer locationInView:self.view] withEvent:nil] isEqual:self.view]) {
		[self hideAndRelease:YES];
	}
}

- (void)dealloc {
	[_bundleIdentifiers release];
	[_dataSource release];
	[super dealloc];
}

@end
