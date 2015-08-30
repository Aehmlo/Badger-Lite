#import <objc/runtime.h>

#import <SpringBoard/SBIconView.h>
#import "SBIconView+BadgerLite.h"

static UIPanGestureRecognizer *createPanGestureRecognizerForIconView(SBIconView *iconView) {

	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:iconView action:@selector(bgl_handleGesture:)];
	recognizer.maximumNumberOfTouches = 1;

	return [recognizer autorelease];
}

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

	HBLogDebug(@"Would now set alpha to %0.02f", alpha);

}

// SBIconView (BadgerLite)

%new - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

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