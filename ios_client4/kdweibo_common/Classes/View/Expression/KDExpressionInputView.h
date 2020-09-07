//
//  KDExpressionInputView.h
//  kdweibo_common
//
//  Created by shen kuikui on 13-4-9.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDExpressionView.h"
#import "KDBaseScrollView.h"

@interface UIImage (KDExpression)
+ (UIImage *)imageWithUIColor:(UIColor *)color;
@end

/**
 *  表情种类的按钮Modal
 */
@interface EmojiModal : NSObject
@property (nonatomic, strong) NSString *strName;
@property (nonatomic, strong) NSString *strImageName;
@end


@protocol KDExpressionInputViewDelegate;

@interface KDExpressionInputView : KDBaseScrollView<KDExpressionViewDelegate>

@property (nonatomic, assign) id<KDExpressionInputViewDelegate> delegate;
@property (nonatomic, strong) NSArray *arrayEmojiModals;

- (void)setSendButtonShown:(BOOL)show;

/**
 *  当前选择的表情菜单index
 */
@property (nonatomic, assign) int iSelectedEmojiIndex;

@end

@protocol KDExpressionInputViewDelegate <NSObject>

@optional

- (void)expressionInputView:(KDExpressionInputView *)inputView didTapExpression:(NSString *)expressionCode;
- (void)expressionInputView:(KDExpressionInputView *)inputView didTapExpressionImage:(UIImage *)expressionImage;

- (void)didTapDeleteInExpressionInputView:(KDExpressionInputView *)inputView;
- (void)didTapKeyBoardInExpressionInputView:(KDExpressionInputView *)inputView;
- (void)didTapSendInExpressionInputView:(KDExpressionInputView *)inputView;

@end
