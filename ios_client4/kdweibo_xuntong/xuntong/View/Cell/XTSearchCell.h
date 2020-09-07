//
//  XTSearchCell.h
//  XT
//
//  Created by Gil on 13-7-15.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTPersonHeaderImageView.h"
#import "RTLabel.h"

@class T9SearchResult;
@class PersonSimpleDataModel;
@interface XTSearchCell : KDTableViewCell

//UI
@property (nonatomic, strong, readonly) XTPersonHeaderImageView *headerImageView;
@property (nonatomic, strong, readonly) UIImageView *partnerImageView;
@property (nonatomic, strong, readonly) RTLabel *nameLabel;
@property (nonatomic, strong, readonly) RTLabel *pinyinLabel;
@property (nonatomic, strong, readonly) UILabel *departmentLabel;
@property (nonatomic, strong, readonly) RTLabel *phoneLabel;
@property (nonatomic, strong, readonly) UIImageView *separateLineImageView;

//Data
@property (nonatomic, strong) T9SearchResult *searchResult;
@property (nonatomic, strong) PersonSimpleDataModel *person;

@end
