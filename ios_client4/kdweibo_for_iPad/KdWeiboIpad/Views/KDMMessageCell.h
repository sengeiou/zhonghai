//
//  KDMessageCell.h
//  KdWeiboIpad
//
//  Created by Tan yingqi on 12-11-6.
//
//

#import <UIKit/UIKit.h>
#import "KWIAvatarV.h"

#import "KDDMMessage.h"
#import "KDStatusView.h"

@interface KDMMessageCell : UITableViewCell
@property (nonatomic,retain)KWIAvatarV *avatarView;
@property (nonatomic,retain)KDDMMessage *message;
@property (nonatomic,retain)UILabel *nameLabel;
//- (void)update:(KDDMMessage *)message layouter:(KDMessageLayouter  *)layouter;
- (void)setMessage:(KDDMMessage *)message shouldDisplayTimeStamp:(BOOL) should;
@end
