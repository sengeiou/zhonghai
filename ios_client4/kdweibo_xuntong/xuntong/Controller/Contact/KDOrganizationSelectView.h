//
//  IDOrganizationSelectView.h
//  kdweibo
//
//  Created by KongBo on 15/9/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSelectItemView.h"

@class KDOrganizationSelectView;
@protocol KDOrganizationSelectViewDelegate <NSObject>
- (void)organiztionSelectView:(KDOrganizationSelectView *)view didSelectedAtIndex:(NSUInteger)index;
@end

@protocol KDOrganizationSelectViewDataDelegate <NSObject>
- (NSUInteger)numberOfItemsInOraganizationSelectView:(KDOrganizationSelectView *)view;
- (NSString *)organiztionSelectView:(KDOrganizationSelectView *)view itemViewAtIndex:(NSUInteger)index;
@end

@interface KDOrganizationSelectView : UIView
@property (nonatomic, weak) id<KDOrganizationSelectViewDataDelegate>dataDelegate;
@property (nonatomic, weak) id<KDOrganizationSelectViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)reloadData;
@end
