//
//  KDMenuItem.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-24.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDObject.h"
@class KDMenuView;

@interface KDMenuItem : KDObject {
 @private
    KDMenuView *menuView_; // weak reference 
    UIView *customView_;
}

@property(nonatomic, assign) KDMenuView *menuView;
@property(nonatomic, retain, readonly) UIView *customView;

- (id)initWithCustomView:(UIView *)customView;

@end
