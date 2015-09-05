#import "BGLNotificationTableViewDataSource.h"

#import <CoreFoundation/CoreFoundation.h>

#import <BulletinBoard/BBBulletin.h>

#define MESSAGE_FONT [UIFont systemFontOfSize:16]

extern NSString *const kBGLNotificationCellReuseIdentifier;

extern NSUInteger numberOfNotificationsForBundleIdentifiers(NSArray *bundleIDs);
extern NSArray *notificationsForBundleIdentifiers(NSArray *bundleIDs);

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
	return [bulletin.message boundingRectWithSize:CGSizeMake([UIApplication sharedApplication].statusBarFrame.size.width, CGFLOAT_MAX) options:0 attributes:@{
		NSFontAttributeName: MESSAGE_FONT
	} context:nil].size.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBGLNotificationCellReuseIdentifier forIndexPath:indexPath];
	cell.backgroundColor = [UIColor clearColor];
	BBBulletin *bulletin = _cachedBulletins[indexPath.row];
	cell.textLabel.text = bulletin.message;
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