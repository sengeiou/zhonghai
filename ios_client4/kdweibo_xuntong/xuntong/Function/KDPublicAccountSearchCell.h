//
//  KDPublicAccountSearchCell.h
//  kdweibo
//
//  Created by Gil on 15/1/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"
#import "XTPersonHeaderImageView.h"
#import "RTLabel.h"

@class PersonSimpleDataModel;
@interface KDPublicAccountSearchCell : KDTableViewCell

//UI
@property (nonatomic, strong, readonly) XTPersonHeaderImageView *headerImageView;
@property (nonatomic, strong, readonly) RTLabel *nameLabel;

//Data
@property (nonatomic, strong) PersonSimpleDataModel *person;

@end
