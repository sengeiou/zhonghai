//
//  KDLeftNavBadgeIndicatorView.h
//  kdweibo_common
//
//  Created by Tan yingqi on 12-12-18.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDLeftNavBadgeIndicatorView : UIView

@property(nonatomic,assign)NSInteger count;
- (void)setCount:(NSInteger)count type:(NSInteger)type;
@end
