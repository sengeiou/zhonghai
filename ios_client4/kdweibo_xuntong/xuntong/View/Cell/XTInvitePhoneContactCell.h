//
//  XTInvitePhoneContactCell.h
//  XT
//
//  Created by chen qicheng on 14-3-31.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTSelectStateView.h"

@interface XTInvitePhoneContactCell : UITableViewCell

@property (nonatomic,assign) BOOL checked;
@property (nonatomic,strong) UILabel *nameLabel;

- (void)setChecked:(BOOL)checked;
- (void)setChecked:(BOOL)checked animated:(BOOL)animated;

@end
