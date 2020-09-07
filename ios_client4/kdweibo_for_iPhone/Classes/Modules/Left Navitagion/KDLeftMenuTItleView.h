//
//  KDLeftMenuTItleView.h
//  KDLeftMenu
//
//  Created by 王 松 on 14-4-16.
//  Copyright (c) 2014年 Song.wang. All rights reserved.
//

#import "CompanyDataModel.h"

@protocol KDLeftMenuTitleViewDelegate;

@interface KDLeftMenuTitleView : UIView

@property (nonatomic, weak) id<KDLeftMenuTitleViewDelegate> delegate;

@property (nonatomic, assign) BOOL  shouldShowTipAnimation;

- (void)setBadgeViewHidden:(BOOL)hidden;

- (void)resetActionButtonRotate;

- (void)startTipAnimation;

- (void)stopTipAnimation;

- (void)updateDraft:(NSInteger)count;

- (void)showListActionButtonRotate;
@end

@protocol KDLeftMenuTitleViewDelegate <NSObject>

@optional
- (void)leftMenuTitleView:(KDLeftMenuTitleView *)leftMenuTitleView actionButtonClicked:(id)sender;
- (void)leftMenuTitleView:(KDLeftMenuTitleView *)leftMenuTitleView showProfile:(id)sender;

@end
