//
//  XTRoundSelectStateView.h
//  kdweibo
//
//  Created by Ad on 14-5-21.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTRoundSelectStateView : UIView

@property (nonatomic, assign) BOOL selected;

- (void)setSelected:(BOOL)selected;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end
