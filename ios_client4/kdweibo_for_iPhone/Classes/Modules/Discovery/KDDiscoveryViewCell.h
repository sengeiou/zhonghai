//
//  KDDiscoveryViewCell.h
//  kdweibo
//
//  Created by weihao_xu on 14-4-16.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDBadgeView.h"
#import "KDTopicGridView.h"
#import "KDUserAvatarView.h"

typedef enum  {
    KDDiscoveryViewCellInlineStyleTop = 0,
    KDDiscoveryViewCellInlineStyleMiddle,
    KDDiscoveryViewCellInlineStyleButtom
}KDDiscoveryViewCellInlineStyle;

typedef enum {
    FirstRow          = 0,
    MiddleRow        = 1,
    LastRow         = 2,
    FullRow  = 3,
    Logout=4,
    User_Image,
    None
} RowType;

@interface KDDiscoveryViewCell : UITableViewCell
@property (nonatomic, retain) UIImageView *avatarImageView;
@property (nonatomic, retain) UILabel *discoveryLabel;
@property (nonatomic, retain) KDBadgeView *badgeImageView;
@property (nonatomic, retain) UIImageView *accessoryImageView;
@property (nonatomic, retain) KDUserAvatarView *userAvatar;
@property (nonatomic, retain) KDTopicGridView *extendView;
@property (nonatomic) KDDiscoveryViewCellInlineStyle inlineStyle;
@property (nonatomic) RowType rowType;
- (void)showBadgeTipView :(BOOL)showed;
- (void)setBadgeValue:(NSInteger)newbadgeValue;
- (void)initWithInlineLineStyle : (KDDiscoveryViewCellInlineStyle)inlineStyle  reuseIdentifier : (NSString *)reuseIdentifier;
@end
