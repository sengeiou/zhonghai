//
//  XTContactPersonViewCell.h
//  kdweibo
//  通讯录-常用联系人cell
//  Created by weihao_xu on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTPersonHeaderImageView.h"
#import "XTOrgTreeDataModel.h"
@interface XTContactPersonViewCell : KDTableViewCell

@property (nonatomic, retain) XTPersonHeaderImageView *headerImageView;
@property (nonatomic, retain) UIImageView *partnerImageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *departmentLabel;
@property (nonatomic, retain) UIImageView *accessoryImageView;
@property (nonatomic, assign) BOOL isDisplay;
@property (nonatomic, retain) PersonSimpleDataModel *person;
@property (nonatomic, retain) UIImageView * managerImage;
//兼职图标
@property (nonatomic, retain) UIImageView * parttimejobImage;

//管理员图标
@property (nonatomic, assign) BOOL showManagerImage;

@property (nonatomic, assign) BOOL showParttimeJob;
- (void)setDisplayDepartment : (BOOL)isDisplayDepartment;
@end
