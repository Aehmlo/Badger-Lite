#import <objc/runtime.h>

#import <SpringBoard/SBIconView.h>

@interface SBIconView (BadgerLite)

@property (nonatomic, retain) UIPanGestureRecognizer *bfl_panGestureRecognizer;

@end

%hook SBIconView

%new - (UIPanGestureRecognizer *)bfl_panGestureRecognizer {
	return objc_getAssociatedObject(self, @selector(bfl_panGestureRecognizer));
}

%new - (void)setBfl_panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
	objc_setAssociatedObject(self, @selector(bfl_panGestureRecognizer), gestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end