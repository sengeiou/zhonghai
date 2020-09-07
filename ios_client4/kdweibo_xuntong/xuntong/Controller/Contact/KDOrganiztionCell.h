//
//  KDOrganiztionCell.h
//  kdweibo
//
//  Created by KongBo on 15/9/6.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"

@class KDTableViewCell;
@protocol KDTableViewCellDelegate <NSObject>
- (void)didEditingTableViewCell:(KDTableViewCell *)cell;
@end

@interface KDOrganiztionCell : KDTableViewCell

@property (weak, nonatomic) id<KDTableViewCellDelegate>editeDelegate;
- (void)setEditingShowSytle:(BOOL)isEditing;
@end
