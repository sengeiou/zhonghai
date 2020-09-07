//
//  XTSelectStateView.h
//  XT
//
//  Created by Gil on 13-7-22.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTSelectStateView : UIView

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, strong) UIImageView *selectStateImageView;
@property (nonatomic, assign) BOOL isCanSelect; //是否可选

- (void)setSelected:(BOOL)selected;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end
