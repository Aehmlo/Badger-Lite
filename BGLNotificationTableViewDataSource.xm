#import "BGLNotificationTableViewDataSource.h"
#import "BGLNotificationTableViewCell.h"

#import <CoreFoundation/CoreFoundation.h>

#import <BulletinBoard/BBBulletin.h>

#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>

extern "C" {
	UIFont *bgl_titleFont(void);
	UIFont *bgl_messageFont(void);
	NSUInteger numberOfNotificationsForBundleIdentifiers(NSArray *bundleIDs);
	NSArray *notificationsForBundleIdentifiers(NSArray *bundleIDs);
}
extern NSString *kBGLNotificationCellReuseIdentifier;

@implementation BGLNotificationTableViewDataSource

- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs {

	if((self = [super init])) {
		_bundleIdentifiers = [bundleIDs retain];
	}

	[self _updateCachedBulletins];

	return self;

}

- (void)_updateCachedBulletins {
	if(_cachedBulletins) {
		[_cachedBulletins release];
	}
	_cachedBulletins = [notificationsForBundleIdentifiers(_bundleIdentifiers) retain];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	style.lineBreakMode = NSLineBreakByWordWrapping;
	BBBulletin *bulletin = _cachedBulletins[indexPath.row];
	return [bulletin.message boundingRectWithSize:CGSizeMake([UIApplication sharedApplication].statusBarFrame.size.width - 10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
		NSFontAttributeName: bgl_messageFont(),
		NSParagraphStyleAttributeName: style
	} context:nil].size.height + 30 + bgl_titleFont().lineHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BGLNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBGLNotificationCellReuseIdentifier forIndexPath:indexPath];
	cell.backgroundColor = [UIColor clearColor];
	BBBulletin *bulletin = _cachedBulletins[indexPath.row];
	cell.messageLabel.text = bulletin.message;
	NSString *text = bulletin.title ?: bulletin.subtitle;
	if(!text) {
		SBApplication *application = [((SBApplicationController *)[%c(SBApplicationController) sharedInstance]) applicationWithBundleIdentifier:bulletin.section];
		text = application.displayName;
	}
	cell.titleLabel.text = text;
	HBLogDebug(@"Cell: %@, label: %@", cell, cell.textLabel);
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_cachedBulletins count];
}

- (void)dealloc {
	[_bundleIdentifiers release];
	[_cachedBulletins release];
	[super dealloc];
}

@end