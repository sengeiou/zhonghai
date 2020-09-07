//
//  KDNavigationMenuView.h
//  kdweibo
//
//  Created by Tan yingqi on 13-11-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDNavigationMenuButton.h"
#import "KDNavigationMenuItem.h"

#define KD_TITLE_PARTITION @"!@#$%^&*"

enum MenuType{
    kMenuTypeDefault =1,
    kMenuTypeCommunity
};

typedef enum MenuType MenuType;

@protocol KDNavigationMenuViewDelegate <NSObject>

- (void)didSelectItemAtIndex:(NSUInteger)index;

@end

@interface KDNavigationMenuView : UIView

@property(nonatomic,retain)NSArray *items;
@property(nonatomic,assign)id<KDNavigationMenuViewDelegate> delegate;
@property(nonatomic,assign)MenuType type;
@property(nonatomic, assign) NSInteger currentIndex;

- (void)setItems:(NSArray *)items index:(NSInteger)index;

- (void)setTitle:(NSString *)title;
- (void)displayMenuInView:(UIView *)view;
- (void)hideNavigationToolBar;
@end
