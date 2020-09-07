//
//  KDAnimationAvatarView.h
//  kdweibo
//
//  Created by shen kuikui on 13-11-19.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDAnimationAvatarView : UIView

@property (nonatomic, copy) NSString *avatarImageURL;
@property (nonatomic, retain) UIImage *ringImage;

- (void)rotate;
- (void)stopRotate;

- (void)rotateWithReaptCount:(float)repeateCount duration:(CFTimeInterval)duration andDelegate:(id)delegate;

- (id)initWithFrame:(CGRect)frame andNeedHighLight:(BOOL)isNeed;

- (BOOL)hasHighLight;
- (void)setNeedHighLight:(BOOL)isNeed;

- (void)changeAvatarImageTo:(UIImage *)image animation:(BOOL)animated;

- (void)setAnimateImageViewHidden:(BOOL)hidden;

@end
