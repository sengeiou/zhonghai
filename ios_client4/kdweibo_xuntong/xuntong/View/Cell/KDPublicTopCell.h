//
//  KDPublicTopCell.h
//  kdweibo
//
//  Created by Ad on 14-5-12.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "FoldPublicDataModel.h"

@interface KDPublicTopCell : SWTableViewCell

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) XTUnreadImageView *unreadImageView;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *separateLineImageView;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) FoldPublicDataModel *dataModel;
@property (nonatomic, assign) BOOL pressOrNot;
@end
