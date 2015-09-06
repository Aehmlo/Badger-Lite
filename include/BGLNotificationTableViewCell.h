#import <BulletinBoard/BBBulletin.h>

@interface BGLNotificationTableViewCell : UITableViewCell {
	BBBulletin *_bulletin;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) BBBulletin *bulletin;

@end