#import "BGLNotificationTableViewDataSource.h"

#import <BulletinBoard/BBBulletin.h>

extern NSString *const kBGLNotificationCellReuseIdentifier;

extern NSUInteger numberOfNotificationsForBundleIdentifiers(NSArray *bundleIDs);
extern NSArray *notificationsForBundleIdentifiers(NSArray *bundleIDs);

@implementation BGLNotificationTableViewDataSource

- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs {

	if((self = [super init])) {
		_bundleIdentifiers = [bundleIDs retain];
	}

	return self;

}

- (void)updateCachedBulletins {
	if(_cachedBulletins) {
		[_cachedBulletins release];
	}
	_cachedBulletins = [notificationsForBundleIdentifiers(_bundleIdentifiers) retain];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// BBBulletin *bulletin = _cachedBulletins[indexPath.row];
	HBLogDebug(@"Returning 44 for cell height");
	return 44;
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