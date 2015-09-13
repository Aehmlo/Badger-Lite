#import "BGLNotificationTableViewDataSource.h"
#import "BGLNotificationTableViewCell.h"
#import "BGLNotificationTableViewHeaderView.h"

#import <CoreFoundation/CoreFoundation.h>

#import <BulletinBoard/BBBulletin.h>

#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>

extern UIFont *bgl_titleFont(void);
extern UIFont *bgl_messageFont(void);
extern UIFont *bgl_headerFont(void);
extern BOOL showHeader;
extern NSUInteger numberOfNotificationsForBundleIdentifiers(NSArray *bundleIDs);
extern NSArray *notificationsForBundleIdentifiers(NSArray *bundleIDs);
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
	BBBulletin *bulletin = _cachedBulletins[indexPath.row];
	return CGRectIntegral([bulletin.message boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 20, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{
		NSFontAttributeName: bgl_messageFont(),
		NSParagraphStyleAttributeName: [NSParagraphStyle defaultParagraphStyle]
	} context:nil]).size.height + 25 + bgl_titleFont().lineHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BGLNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBGLNotificationCellReuseIdentifier forIndexPath:indexPath];
	cell.backgroundColor = [UIColor clearColor];
	BBBulletin *bulletin = _cachedBulletins[indexPath.row];
	cell.bulletin = bulletin;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_cachedBulletins count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(!showHeader) {
		return nil;
	}
	BGLNotificationTableViewHeaderView *headerView = [[BGLNotificationTableViewHeaderView alloc] init];
	headerView.unreadCount = [_cachedBulletins count];
	return [headerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return showHeader ? bgl_headerFont().lineHeight + 10 : 0;
}

- (void)dealloc {
	[_bundleIdentifiers release];
	[_cachedBulletins release];
	[super dealloc];
}

@end