//
//  KDTitleNavView.h
//  kdweibo
//
//  Created by fang.jiaxin on 15/7/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTUnreadImageView.h"


@protocol KDTitleNavViewDelegate <NSObject>
-(void)clickTitle:(NSString *)title inIndex:(int)index;
-(void)clickArrowSinceIndex:(int)sinceIndex toIndex:(int)toIndex;
@end


@interface KDTitleNavView : UIView
@property(nonatomic,strong) NSArray *titleArray;
@property(nonatomic,strong) NSMutableArray *titleViewArray;
@property(nonatomic,strong) UIColor *titleColor;
@property(nonatomic,strong) UIColor *selectedColor;
@property(nonatomic,assign) int currentIndex;
@property(nonatomic,copy) NSString *currentTitle;
@property(nonatomic,weak) id<KDTitleNavViewDelegate> delegate;



@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIButton *rollView;
@property(nonatomic,strong) UIView *selectView;
@property(nonatomic,strong) UIView *lineView;

@property(nonatomic,strong) NSMutableArray *redNumArray;

@property(nonatomic,strong) NSMutableArray *redDotArray;

@property(nonatomic,assign) BOOL isFillWidth;//是否满屏显示
@property (nonatomic, strong) XTUnreadImageView *unreadImageView;
@end
