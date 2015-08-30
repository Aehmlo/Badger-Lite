#import <SpringBoard/SBIconView.h>
#import "SBIconView+BadgerLite.h"

UIPanGestureRecognizer *createPanGestureRecognizerForIconView(SBIconView *iconView) {

	UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:iconView action:@selector(bgl_handleGesture:)];
	recognizer.maximumNumberOfTouches = 1;
	recognizer.delegate = iconView;

	return [recognizer autorelease];
}