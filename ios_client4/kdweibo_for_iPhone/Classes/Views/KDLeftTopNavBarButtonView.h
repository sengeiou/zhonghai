//
//  KDLeftTopNavBarButtonView.h
//  kdweibo
//
//  Created by Tan yingqi on 12-12-18.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDManagerContext.h"
#import "KDUnread.h"
#import "KDBadgeIndicatorView.h"

@interface KDLeftTopNavBarButtonView : UIView<KDUnreadListener, KDUnreadListener>
@property(nonatomic,retain)UIButton *button;

- (void)setbadgeCount:(NSInteger)count;
@end
