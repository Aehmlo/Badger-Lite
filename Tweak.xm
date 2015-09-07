#import <objc/runtime.h>
#include <substrate.h>
#include <stdlib.h>

#import <Cephei/HBPreferences.h>

#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBBulletinViewController.h>
#import <SpringBoard/SBIconContentView.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconListView.h>
#import <SpringBoard/SBIconView.h>
#import "SBIconView+BadgerLite.h"

#include "BGLActivationMethod.h"
#import "BGLNotificationViewController.h"
#import "UIGestureRecognizerTarget.h"

#define USING_LEFT_RECOGNIZER ((activationMethod & BGLActivationMethodSwipeLeft) != 0)
#define USING_RIGHT_RECOGNIZER ((activationMethod & BGLActivationMethodSwipeRight) != 0)
#define USING_UP_RECOGNIZER ((activationMethod & BGLActivationMethodSwipeUp) != 0)
#define USING_DOWN_RECOGNIZER ((activationMethod & BGLActivationMethodSwipeDown) != 0)
#define USING_VERTICAL_RECOGNIZER (USING_UP_RECOGNIZER || USING_DOWN_RECOGNIZER)
#define USING_HORIZONTAL_RECOGNIZER (USING_LEFT_RECOGNIZER || USING_RIGHT_RECOGNIZER)

static BOOL enabled;
NSInteger blurStyle;
static BGLActivationMethod activationMethod = BGLActivationMethodSwipeUp;
static BGLNotificationViewController *viewController;

extern "C" UIPanGestureRecognizer *createPanGestureRecognizerForIconView(SBIconView *iconView);

%hook SBIconView

- (void)_setIcon:(SBIcon *)icon animated:(BOOL)animated {

	@autoreleasepool {

		if(!self.bgl_panGestureRecognizer) {
			UIPanGestureRecognizer *recognizer = createPanGestureRecognizerForIconView(self);
			[self addGestureRecognizer:recognizer];
			self.bgl_panGestureRecognizer = recognizer;

		} else {
			HBLogDebug(@"Pan gesture recognizer already exists for icon view %@ (current icon %@); skipping.", self, icon);
		}

		%orig(icon, animated);

	}
}

%new - (void)bgl_handleGesture:(UIPanGestureRecognizer *)recognizer {

	if(!enabled) return;

	if(recognizer.state == UIGestureRecognizerStateBegan) {

		viewController = [[BGLNotificationViewController alloc] initWithIconView:self];
		SBIconController *controller = [%c(SBIconController) sharedInstance];
		SBIconContentView *contentView = controller.contentView;
		UIView *view = viewController.view;
		[contentView addSubview:view];

		[contentView addConstraints:@[
			[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0],
			[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
			[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
			[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]
		]];


	} else if(recognizer.state == UIGestureRecognizerStateChanged) {

		if(!USING_HORIZONTAL_RECOGNIZER && !USING_VERTICAL_RECOGNIZER) {
			HBLogWarn(@"Neither horizontal nor vertical recognizers appear to be enabled; ignoring pan gesture.");
			return;
		}

		CGPoint translationInView = [recognizer translationInView:self];
		CGFloat effectiveTranslation;

		if(USING_LEFT_RECOGNIZER != USING_RIGHT_RECOGNIZER) { // Using exactly one horizontal direction
			if((USING_LEFT_RECOGNIZER && translationInView.x > 0) || (USING_RIGHT_RECOGNIZER && translationInView.x < 0)) {
				translationInView.x = 0;
			}
		} else {
			translationInView.x = fabs(translationInView.x);
		}
		if(USING_UP_RECOGNIZER != USING_DOWN_RECOGNIZER) { // Using exactly one vertical dimension
			if((USING_UP_RECOGNIZER && translationInView.y > 0) || (USING_DOWN_RECOGNIZER && translationInView.y < 0)) {
				translationInView.y = 0;
			}
		} else {
			translationInView.y = fabs(translationInView.y);
		}

		if(USING_VERTICAL_RECOGNIZER && USING_HORIZONTAL_RECOGNIZER) {
			effectiveTranslation = fmax(fabs(translationInView.x), fabs(translationInView.y));
		} else {
			effectiveTranslation = USING_HORIZONTAL_RECOGNIZER ? fabs(translationInView.x) : fabs(translationInView.y);
		}

		CGFloat alpha = effectiveTranslation / 80.0;
		if(alpha > 1) alpha = 1; // goto fail;

		viewController.view.alpha = alpha;
		[viewController.listView setAlphaForAllIcons:(1 - (0.8 * alpha))]; // Humans are not as good of parsers as the compiler is.
		[viewController.dockListView setAlphaForAllIcons:(1 - (0.8 * alpha))];
		self.alpha = 1;

	} else if(recognizer.state == UIGestureRecognizerStateEnded) {
		if(viewController.view.alpha <= 0.7) { // Use the alpha so we don't redo the (expensive) calculations we've already done.
			[viewController hideAndRelease:YES];
		} else { // Here to stay
			viewController.view.alpha = 1;
			[viewController.listView setAlphaForAllIcons:0.2];
			self.alpha = 1;
		}
	}

}

// SBIconView (BadgerLite)

%new - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

	if(!enabled) return YES;

	BOOL shouldConflict = NO;

	NSArray *targets = MSHookIvar<NSMutableArray *>(otherGestureRecognizer, "_targets");
	for(UIGestureRecognizerTarget *_target in targets) {
		id target = MSHookIvar<id>(_target, "_target"); // Wrapper class, of course.
		if((USING_VERTICAL_RECOGNIZER && [target isKindOfClass:%c(SBSearchScrollView)]) || (USING_HORIZONTAL_RECOGNIZER && [target isKindOfClass:%c(SBIconScrollView)])) {
			shouldConflict = YES;
			break;
		}
	}

	return !shouldConflict;

}

%new - (UIPanGestureRecognizer *)bgl_panGestureRecognizer {
	return objc_getAssociatedObject(self, @selector(bgl_panGestureRecognizer));
}

%new - (void)setBgl_panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
	objc_setAssociatedObject(self, @selector(bgl_panGestureRecognizer), gestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end

SBBulletinViewController *bulletinViewController;

%hook SBBulletinViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSString *)bundle { // I really should make Logos understand instancetype or something
	self = %orig(nibName, bundle);
	if (self && ![self isKindOfClass:%c(SBWidgetHandlingBulletinViewController)]) { // Turns out SBWidgetHandlingBulletinViewController isn't what we want. Reminds me of the original version of Badger...but you don't have that source code, do you, dear reader?
		// TODO: Find a better way to do this.
		bulletinViewController = self;
	}
	return self;
}

%end

%ctor {

	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:@"com.bflatstudios.badger-lite"];

	[preferences registerBool:&enabled default:YES forKey:@"Enable"];
	[preferences registerInteger:&blurStyle default:1 forKey:@"BlurStyle"];

	void (^changeBlock)(NSString *, id) = ^(NSString *name, id value) { // <3 fuckingblocksyntax.com
		activationMethod = ([preferences boolForKey:@"SwipeUpEnabled"] ? BGLActivationMethodSwipeUp : 0) | ([preferences boolForKey:@"SwipeDownEnabled"] ? BGLActivationMethodSwipeDown : 0) | ([preferences boolForKey:@"SwipeLeftEnabled"] ? BGLActivationMethodSwipeLeft : 0) | ([preferences boolForKey:@"SwipeRightEnabled"] ? BGLActivationMethodSwipeRight : 0);
	};

	[preferences registerPreferenceChangeBlock:changeBlock forKey:@"SwipeUpEnabled"];
	[preferences registerPreferenceChangeBlock:changeBlock forKey:@"SwipeDownEnabled"];
	[preferences registerPreferenceChangeBlock:changeBlock forKey:@"SwipeLeftEnabled"];
	[preferences registerPreferenceChangeBlock:changeBlock forKey:@"SwipeRightEnabled"];

	changeBlock(nil, nil);

}