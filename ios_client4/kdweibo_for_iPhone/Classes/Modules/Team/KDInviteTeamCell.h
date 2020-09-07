//
//  KDInviteTeamCell.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTeamCell.h"

@class KDInviteTeamCell;

@protocol KDInviteTeamCellDelegate <NSObject>

- (void)ignoreInviteInTeamCell:(KDInviteTeamCell *)cell;
- (void)joinTeamInTeamCell:(KDInviteTeamCell *)cell;

@end

@interface KDInviteTeamCell : KDTeamCell

@property (nonatomic, assign) id<KDInviteTeamCellDelegate> delegate;

@end
