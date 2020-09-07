//
//  KDDMChatInputExtendView.h
//  kdweibo
//
//  Created by Tan Yingqi on 14-1-9.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDDMChatInputExtendViewDelegate <NSObject>

- (void)checkButtonTapped:(id)sender;
@end

@interface KDDMChatInputExtendView : UIView
@property(nonatomic, retain) UIImageView *backgroundImageView;
@property(nonatomic, retain) UIButton *checkBoxButton;
@property(nonatomic, retain) UILabel *textLabel;
@property(nonatomic, assign)id<KDDMChatInputExtendViewDelegate> delegate;

- (void)setChecked:(BOOL)checked;
- (BOOL)checked;

@end