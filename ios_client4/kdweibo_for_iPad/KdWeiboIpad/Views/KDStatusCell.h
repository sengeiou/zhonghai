//
//  KDStatusCell.h
//  KdWeiboIpad
//
//  Created by Tan YingQi on 13-4-6.
//
//

#import <UIKit/UIKit.h>
#import "KWIAvatarV.h"
#import "KDStatusView.h"

@interface KDStatusCell : UITableViewCell
@property (nonatomic,retain)KWIAvatarV *avatarView;
@property (nonatomic,retain)KDStatus *status;
@property (nonatomic,retain)KDLayouterFatherView *statusView;
@property (nonatomic,retain)UILabel *nameLabel;
@property (nonatomic,retain)KDLayouter *layouter;
@end
