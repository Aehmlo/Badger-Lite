#import <objc/runtime.h>

#import <SpringBoard/SBIconView.h>
#import "SBIconView+BadgerLite.h"

static UIPanGestureRecognizer *createPanGestureRecognizerForIconView(SBIconView *iconView) {

	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:iconView action:@selector(bgl_handleGesture:)];
	recognizer.maximumNumberOfTouches = 1;

	return recognizer;
}

%hook SBIconView

- (void)_setIcon:(SBIcon *)icon animated:(BOOL)animated {

	HBLogDebug(@"Setting icon: %@ animated: %d", icon, animated);

	if(!self.bgl_panGestureRecognizer) {
		HBLogDebug(@"No pan gesture recognizer exists for icon view %@; creating one.", self);
		self.bgl_panGestureRecognizer = createPanGestureRecognizerForIconView(self);
	} else {
		HBLogDebug(@"Pan gesture recognizer already exists for icon view %@; skipping.", self);
	}

	%orig(icon, animated);
}

// SBIconView (BadgerLite)

%new - (UIPanGestureRecognizer *)bgl_panGestureRecognizer {
	return objc_getAssociatedObject(self, @selector(bgl_panGestureRecognizer));
}

%new - (void)setBgl_panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
	objc_setAssociatedObject(self, @selector(bgl_panGestureRecognizer), gestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end