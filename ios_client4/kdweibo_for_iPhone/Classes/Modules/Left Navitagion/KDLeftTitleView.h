//
//  KDLeftTitleView.h
//  kdweibo
//
//  Created by gordon_wu on 13-11-22.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  通过Delegate把点击事件传递到viewcontroller中，点击事件放在view内则无法present或者获得navigationController。
 *  @modified-by:shenkuikui
 *  @modified-at:2013年11月27日14:35:12
 */

@class KDLeftTitleView;

@protocol KDLetfTitleViewDelegate <NSObject>

- (void)leftTitleView:(KDLeftTitleView *)view searchButtonClicked:(UIButton *)btn;
- (void)leftTitleView:(KDLeftTitleView *)view settingButtonClicked:(UIButton *)btn;
- (void)leftTitleView:(KDLeftTitleView *)view avatarViewClicked:(KDAnimationAvatarView *)avatarView;
//- (void)leftTitleView:(KDLeftTitleView *)view infoCenterButtonClicked:(UIButton *)btn;

@end
@interface KDLeftTitleView : UIView

@property(nonatomic,retain) KDUser *user;
@property (nonatomic, weak) id<KDLetfTitleViewDelegate> delegate;
@property (nonatomic, readonly, retain) KDAnimationAvatarView *avatarView;

- (void)setInfoCount:(NSInteger)count;

@end
