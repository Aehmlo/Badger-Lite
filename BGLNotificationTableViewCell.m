#import "BGLNotificationTableViewCell.h"

extern UIFont *bgl_titleFont(void);
extern UIFont *bgl_messageFont(void);

@implementation BGLNotificationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.textLabel.textColor = [UIColor whiteColor];
		self.textLabel.font = bgl_messageFont();
		self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	}

	return self;

}

@end