#import <SpringBoard/SBBulletinListSection.h>
#import <SpringBoard/SBBulletinViewController.h>
#import <SpringBoard/SBNotificationCenterSectionInfo.h>

extern SBBulletinViewController *bulletinViewController;

NSArray *notificationsForBundleIdentifiers(NSArray *bundleIDs) {

	NSUInteger i = 0;
	NSUInteger remainingBundleIDs = [bundleIDs count];
	NSMutableArray *bulletins = [NSMutableArray arrayWithCapacity:1];

	while(remainingBundleIDs) {

		SBNotificationCenterSectionInfo *sectionInfo = [bulletinViewController sectionAtIndex:i];

		if([bundleIDs containsObject:sectionInfo.representedListSection.sectionID]) {

			SBBulletinListSection *listSection = sectionInfo.representedListSection;
			[bulletins addObjectsFromArray:listSection.bulletins];
			remainingBundleIDs--;

		}

		i++;

		if(!sectionInfo) { // We've exhausted the available sections without finding anything.
			break;
		}

	}

	return bulletins;

}

NSUInteger numberOfNotificationsForBundleIdentifiers(NSArray *bundleIDs) {
	return [notificationsForBundleIdentifiers(bundleIDs) count];
}