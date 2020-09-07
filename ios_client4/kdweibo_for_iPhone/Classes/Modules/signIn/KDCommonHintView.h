//
//  KDCommonHintView.h
//  kdweibo
//
//  Created by shifking on 15/11/21.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HintViewButtonClickBlock)( NSInteger index , NSString *title );

@interface KDCommonHintView : UIView

@property (strong , nonatomic) HintViewButtonClickBlock buttonClickBlock;

@property (strong , nonatomic) UIImage *headerImage;

@property (strong , nonatomic) NSString *leftButtonString;
@property (strong , nonatomic) NSString *rightButtonString;

@property (strong , nonatomic) UIColor *leftButtonTextColor;
@property (strong , nonatomic) UIColor *rightButtonTextColor;

@property (assign , nonatomic) BOOL showCloseButton;
@property (assign , nonatomic) BOOL hideRightButton;

- (id)initWithFatherView:(UIView *)fatherView;

- (void)setupTitle:(NSString *)title image:(UIImage *)image contentText:(NSString *)content;
- (void)setupTitle:(NSString *)title image:(UIImage *)image pointTexts:(NSArray *)items;

- (void)show;

@end
