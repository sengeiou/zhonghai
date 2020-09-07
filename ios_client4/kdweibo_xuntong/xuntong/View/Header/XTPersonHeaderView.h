//
//  XTPersonHeaderView.h
//  XT
//
//  Created by Gil on 13-7-5.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTPersonHeaderImageView.h"

@protocol XTPersonHeaderViewDelegate;
@protocol XTPersonHeaderViewLongPressDelegate;
@interface XTPersonHeaderView : UIView

@property (nonatomic, strong) PersonSimpleDataModel *person;
@property (nonatomic, strong, readonly) XTPersonHeaderImageView *personHeaderImageView;
@property (nonatomic, strong, readonly) UIImageView *partnerImageVIew;
@property (nonatomic, strong, readonly) UILabel *personNameLabel;
@property (nonatomic, weak) id<XTPersonHeaderViewDelegate> delegate;
@property (nonatomic, weak) id<XTPersonHeaderViewLongPressDelegate> longPressdelegate;

@property (nonatomic, assign)BOOL hidePartnerImageView;

@property (nonatomic, assign) BOOL personDetail;//是否为详情界面，用于区分聊天界面和群详情界面的头像名称显示，如果为是则名字显示在头像下方，否则显示在头像右边
- (void)tapHeaderView;

@end

@protocol XTPersonHeaderViewDelegate <NSObject>
- (void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person;
@end

@protocol XTPersonHeaderViewLongPressDelegate <NSObject>
- (void)personHeaderLongPressed:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person;
@end
