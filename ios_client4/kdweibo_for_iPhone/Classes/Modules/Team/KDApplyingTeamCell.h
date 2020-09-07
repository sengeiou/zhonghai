//
//  KDApplyingTeamCell.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTeamCell.h"

@class KDApplyingTeamCell;
@protocol KDApplyingTeamCellDelegate <NSObject>

- (void)cancelApplyTeamOfApplyingTeamCell:(KDApplyingTeamCell *)cell;

@end

@interface KDApplyingTeamCell : KDTeamCell

@property (nonatomic, assign) id<KDApplyingTeamCellDelegate> delegate;

@end
