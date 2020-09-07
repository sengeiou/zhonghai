//
//  KDHelpWhiteBGView.h
//  kdweibo
//
//  Created by tangzeng on 16/12/27.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//
/*
 KDHelpWhiteBGView : 白色背景的helpView，点 ？弹出
 */

#import <UIKit/UIKit.h>

@interface KDHelpWhiteBGViewModel : NSObject


@property (nonatomic, strong) NSString *tips;

+ (KDHelpWhiteBGViewModel *)modelWithTips:(NSString *)tips;

@end

@interface KDHelpWhiteBGView : UIView
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImageView *imageViewMask;
@property (nonatomic, strong) NSMutableArray *mArrayModels;
@property (nonatomic, strong) void (^backgroundPressed)();
@property (nonatomic, strong) UIImageView *imageViewTriangle;
@property (nonatomic, strong) UIView *popDownBgView;

- (void)shrinkView;
- (void)restoreView;
- (void)addModel:(KDHelpWhiteBGViewModel *)model;
@end

@interface KDTableViewHeadViewForHelpView : UIView
@property (nonatomic, strong) NSString *labelText;
@end

