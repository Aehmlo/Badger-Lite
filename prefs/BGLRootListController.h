#import <Preferences/PSListController.h>
#import <Cephei/HBListController.h>

@interface BGLRootListController : HBListController

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

+ (UIColor *)hb_tintColor {
	return [UIColor blueColor];
}

@end
