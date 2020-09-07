//
//  KDSearchTextCell.h
//  kdweibo
//
//  Created by sevli on 15/8/7.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"
#import "XTGroupHeaderImageView.h"
#import "RTLabel.h"

@class KDSearchTextModel;
@class XTUnreadImageView;
@interface KDSearchTextCell : KDTableViewCell

@property (nonatomic, strong, readonly) XTGroupHeaderImageView *headerImageView;
@property (nonatomic, strong, readonly) RTLabel *nameLabel;
@property (nonatomic, strong, readonly) RTLabel *messageLabel;


@property (nonatomic, strong) KDSearchTextModel *searchModel;

@end
