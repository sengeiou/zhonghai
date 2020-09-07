//
//  KDCreateAndJoinTeamCell.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-30.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDCreateAndJoinTeamCell;

@protocol KDCreateAndJoinTeamCellDelegate <NSObject>

- (void)createButtonClickedInCreateAndJoinTeamCell:(KDCreateAndJoinTeamCell *)cell;
- (void)joinButtonClickedInCreateAndJoinTeamCell:(KDCreateAndJoinTeamCell *)cell;

@end

@interface KDCreateAndJoinTeamCell : UITableViewCell

@property (nonatomic, assign) id<KDCreateAndJoinTeamCellDelegate> delegate;

+ (CGFloat)defaultHeight;

@end
