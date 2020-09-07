//
//  KDTopActionToolbar.h
//  kdweibo
//
//  Created by Tan yingqi on 13-11-19.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDTopActionToolbar;
@protocol KDTopActionToolbarDelegate <NSObject>

- (void)topActionToolBar:(KDTopActionToolbar *)toolbar didSelectAtIndex:(NSInteger)index;

@end

@interface KDTopActionToolbar : UIView
@property(nonatomic,retain)NSArray *dataSource;
@property(nonatomic, assign)id<KDTopActionToolbarDelegate> delegate;
@property(nonatomic,assign)NSInteger selectedIndex;

- (void)hide:(void(^)(void))completionBlock;
- (void)show:(void(^)(void))completionBlock;

/*
    在我的公司模块才调用此方法，只是为了改变高亮字的颜色。。。
 */
- (void)updateTitleColor;
@end
