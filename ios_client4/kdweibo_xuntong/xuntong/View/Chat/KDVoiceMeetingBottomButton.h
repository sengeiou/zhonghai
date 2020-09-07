//
//  KDVoiceMeetingBottomButton.h
//  kdweibo
//
//  Created by 张培增 on 16/8/16.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDVoiceMeetingBottomButton : UIButton

//PPT共享按钮
+ (KDVoiceMeetingBottomButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title image:(UIImage *)image imageIsSquare:(BOOL)isSquare;

//主持人模式按钮
+ (KDVoiceMeetingBottomButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title selectedColor:(UIColor *)selectedColor;

//切换成主持人模式
- (void)changeToHostMode;

//切换成自由模式
- (void)changeToFreeMode;

@end
