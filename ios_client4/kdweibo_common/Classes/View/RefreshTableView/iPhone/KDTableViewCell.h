//
//  KDTrendCell.h
//  kdweibo
//
//  Created by shen kuikui on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

//@interface KDTableViewCell : UITableViewCell
//
//@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
//
//@end
typedef NS_ENUM(NSUInteger, KDTableViewCellSeparatorLineStyle) {
    KDTableViewCellSeparatorLineNone = 0,//无分割线
    KDTableViewCellSeparatorLineTop,//分隔线顶端对齐
    KDTableViewCellSeparatorLineSpace//分割线与顶端间隔
};

typedef NS_ENUM(NSUInteger, KDTableViewCellAccessoryStyle) {
    KDTableViewCellAccessoryStyleNone = 0,//无右侧箭头
    KDTableViewCellAccessoryStyleDisclosureIndicator//有右侧箭头
};

@interface KDTableViewCell : UITableViewCell

@property (assign, nonatomic) KDTableViewCellSeparatorLineStyle separatorLineStyle;
@property (assign, nonatomic) KDTableViewCellAccessoryStyle accessoryStyle;
@property (assign, nonatomic) UIEdgeInsets separatorLineInset;

@property (strong, nonatomic, readonly) UIView *separatorLineView;
@property (strong, nonatomic, readonly) UIImageView *disclosureIndicatorView;

@end