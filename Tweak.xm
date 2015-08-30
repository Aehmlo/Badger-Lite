#import <objc/runtime.h>
#include <substrate.h>
#include <stdlib.h>

#import <Cephei/HBPreferences.h>

#import <SpringBoard/SBIconContentView.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconView.h>
#import "SBIconView+BadgerLite.h"

#include "BGLActivationMethod.h"
#import "BGLNotificationViewController.h"
#import "UIGestureRecognizerTarget.h"

#define USING_LEFT_RECOGNIZER (activationMethod & BGLActivationMethodSwipeLeft)
#define USING_RIGHT_RECOGNIZER (activationMethod & BGLActivationMethodSwipeRight)
#define USING_UP_RECOGNIZER (activationMethod & BGLActivationMethodSwipeUp)
#define USING_DOWN_RECOGNIZER (activationMethod & BGLActivationMethodSwipeDown)
#define USING_VERTICAL_RECOGNIZER (USING_UP_RECOGNIZER || USING_DOWN_RECOGNIZER)
#define USING_HORIZONTAL_RECOGNIZER (USING_LEFT_RECOGNIZER || USING_RIGHT_RECOGNIZER)

static BOOL enabled;
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
			HBLogDebug(@"Pan gesture recognizer already exists for icon view %@ (icon %@); skipping.", self, icon);
		}

		%orig(icon, animated);

	}
}

%new -(void)bgl_handleGesture:(UIPanGestureRecognizer *)recognizer {

	if(!enabled) return;

	if(recognizer.state == UIGestureRecognizerStateBegan) {

		viewController = [[BGLNotificationViewController alloc] init];
		SBIconController *controller = [%c(SBIconController) sharedInstance];
		SBIconContentView *contentView = controller.contentView;
		UIView *view = viewController.view;
		[contentView addSubview:view];


		[contentView addConstraints:@[
			[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0],
			[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
			[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
			[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:200]
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

	} else if(recognizer.state == UIGestureRecognizerStateEnded) {
		if(viewController.view.alpha <= 0.6) { // Use the alpha so we don't redo the (expensive) calculations we've already done.
			viewController.view.alpha = 0;
			[viewController.view removeFromSuperview];
			[viewController release];
		} else { // Here to stay
			viewController.view.alpha = 1;
			[viewController release]; // TODO: Do this when the thing's actually hidden (not now!)
			viewController = nil; // TODO: Do this only when absolutely necessary!
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

%ctor {

	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:@"com.bflatstudios.badger-lite"];

	[preferences registerBool:&enabled default:YES forKey:@"Enable"];

}