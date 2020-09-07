//
//  KDABActionTabBar.h
//  kdweibo
//
//  Created by laijiandong on 12-11-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDABActionTabBarDelegate;

typedef enum : NSUInteger {
    KDABActionTabBarTypeTabBar = 0,
    KDABActionTabBarTypeActionBar
    
}KDABActionTabBarType;


@interface KDABActionTabBar : UIView

@property(nonatomic, assign) id<KDABActionTabBarDelegate> delegate;
@property(nonatomic, assign, readonly) KDABActionTabBarType type;
@property(nonatomic, assign) NSInteger selectedIndex;

- (id)initWithFrame:(CGRect)frame type:(KDABActionTabBarType)type selectedIndex:(NSInteger)selectedIndex;

- (UIButton *)actionBarButtonAtIndex:(NSUInteger)index;

@end


@protocol KDABActionTabBarDelegate <NSObject>
@optional

- (void)actionTabBar:(KDABActionTabBar *)actionTabBar didSelectAtIndex:(NSInteger)index;

@end