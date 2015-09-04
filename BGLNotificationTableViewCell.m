#import "BGLNotificationTableViewCell.h"

@implementation BGLNotificationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.textLabel.textColor = [UIColor whiteColor];
	}

	return self;

}

@end