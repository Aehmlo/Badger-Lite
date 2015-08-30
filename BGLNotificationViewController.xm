#import "BGLNotificationViewController.h"

@implementation BGLNotificationViewController

extern "C" NSInteger blurStyle;

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

}

@end