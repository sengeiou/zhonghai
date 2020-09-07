//
//  XTPersonContactCell.h
//  XT
//
//  Created by Gil on 13-7-3.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTPersonHeaderImageView.h"

@class PersonSimpleDataModel;
@interface XTContactPersonCell : KDTableViewCell

//UI
@property (nonatomic, strong, readonly) XTPersonHeaderImageView *headerImageView;
@property (nonatomic, strong) UIImageView *partnerImageView;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *departmentLabel;
@property (nonatomic, strong, readonly) UIImageView *separateLineImageView;

//Data
@property (nonatomic, assign) CGFloat separateLineSpace;
@property (nonatomic, strong) PersonSimpleDataModel *person;

@end
