//
//  KDBadgeView.h
//  kdweibo
//
//  Created by Tan Yingqi on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDBadgeView : UIView
@property(nonatomic, assign) NSInteger badgeValue;
@property(nonatomic, retain) UIColor *badgeColor;

- (void)setBadgeBackgroundImage:(UIImage *)image;
- (BOOL)badgeIndicatorVisible;
- (void)setbadgeTextFont:(UIFont *)font;
+ (UIImage *)redGroupBackgroundImage;
+ (UIImage *)tipBadgeBackgroundImage;
+ (UIImage *)redBadgeBackgroundImage;
+ (UIImage *)greenPointBackgroundImage;
+ (UIImage *)smallRedGroupBackgroundImage;
+ (UIImage *)redLeftBadgeBackgroundImag;
+ (UIImage *)redTeamBadgeBackgroundImag;
+ (UIImage *)newRedBadgeBackgroundImage;
//迅通的消息页的未读红色背景
+ (UIImage *)XTRedBadgeBackgroudImage;
@end
