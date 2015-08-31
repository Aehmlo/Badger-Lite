#import "BGLNotificationTableViewDataSource.h"

extern NSString *const kBGLNotificationCellReuseIdentifier;

@implementation BGLNotificationTableViewDataSource

- (instancetype)initWithBundleIdentifiers:(NSArray *)bundleIDs {

	if((self = [super init])) {
		_bundleIdentifiers = [bundleIDs retain];
	}

	return self;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBGLNotificationCellReuseIdentifier forIndexPath:indexPath];
	cell.backgroundColor = [UIColor clearColor];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (void)dealloc {
	[_bundleIdentifiers release];
	[super dealloc];
}

@end