#import "BGLNotificationViewController.h"

#import "BGLNotificationTableViewCell.h"

#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBFolder.h>
#import <SpringBoard/SBFolderIconView.h>
#import <SpringBoard/SBIcon.h>
#import <SpringBoard/SBIconView.h>

extern "C" NSString *const kBGLNotificationCellReuseIdentifier;

@implementation BGLNotificationViewController

extern NSInteger blurStyle;

- (instancetype)initWithIconView:(SBIconView *)iconView {

	if((self = [super init])) {
		if(iconView) {
			_iconView = iconView;
			SBIcon *icon = iconView.icon;
			if(!icon.isFolderIcon) {
				_bundleIdentifiers = @[((SBApplicationIcon *)iconView.icon).application.bundleIdentifier];
			} else {
				SBFolder *folder = ((SBFolderIconView *)iconView).folder;
				NSArray *icons = folder.allIcons;
				NSMutableArray *ids = [NSMutableArray arrayWithCapacity:icons.count];
				for(SBApplicationIcon *icon in icons) { // May not actually be an app icon.
					SBApplication *app = icon.application;
					NSString *bundleID = app.bundleIdentifier;
					if(bundleID) {
						[ids addObject:bundleID]; // Thank goodness for safe nil, right?
					}
				}
				_bundleIdentifiers = ids.count ? ids : @[@"com.bflatstudios.badger-lite.error"];
			}
		} else { // No icon view; default to showing the consolidated view.
			_bundleIdentifiers = [%c(SBApplicationController) sharedInstance].allBundleIdentifiers;
		}
		[_bundleIdentifiers retain];
	}

	return self;

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

	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	CGFloat iconTop = [window convertPoint:_iconView.frame.origin toView:nil].y - [window convertPoint:_iconView.superview.frame.origin toView:nil].y + [window convertPoint:_iconView.superview.superview.frame.origin toView:nil].y;
	CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

	_blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
	_blurView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_blurView];
	[self.view addConstraints:@[
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:iconTop],
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
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-statusBarHeight],
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_blurView attribute:NSLayoutAttributeTop multiplier:1.0 constant:statusBarHeight]
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
