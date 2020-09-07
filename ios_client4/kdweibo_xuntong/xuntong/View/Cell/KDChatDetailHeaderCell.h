//
//  KDChatDetailHeaderCell.h
//  kdweibo
//
//  Created by kyle on 16/9/29.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"

typedef void(^KDEditGroupNameBlock)();

@interface KDChatDetailHeaderCell : KDTableViewCell

@property (nonatomic, strong) UIImageView *extImageView;
@property (nonatomic, strong) UIImageView *groupHeaderImageView;
@property (nonatomic, strong) UIImageView *canmeraImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *editGroupNameBtn; //
@property (nonatomic, strong) KDEditGroupNameBlock block;

- (void)setNameLabelValue:(NSString *)text;

@end
