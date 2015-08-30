#import "BGLNotificationViewController.h"

@implementation BGLNotificationViewController

- (void)viewDidLoad {

	self.view.translatesAutoresizingMaskIntoConstraints = false;

	_blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
	_blurView.translatesAutoresizingMaskIntoConstraints = false;
	[self.view addSubview:_blurView];
	[self.view addConstraints:@[
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
		[NSLayoutConstraint constraintWithItem:_blurView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]
	]];
	[_blurView release];

}

@end