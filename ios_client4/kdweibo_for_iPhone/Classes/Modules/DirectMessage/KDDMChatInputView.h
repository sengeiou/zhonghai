//
//  KDDMChatInputView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "KDInputAlertView.h"
#import "KDExpressionInputView.h"
#import "KDPickedImage.h"
#import "KDDMChatInputExtendView.h"

@protocol KDDMChatInputViewDelegate;

@class KDProgressActionView;

@class HPGrowingTextView;

#define KD_DM_CHAT_INPUT_VIEW_HEIGHT    46.0

typedef enum{
     KDInputViewTypeDM= 1,
     KDInputViewTypeTK       //任务讨论
}KDInputViewType;

@interface KDDMChatInputView : KDInputAlertView <UITextViewDelegate, UIActionSheetDelegate, KDPickedImageDelegate, UIGestureRecognizerDelegate, KDExpressionInputViewDelegate> {
@private
//    UIViewController *hostViewController_; // weak reference
    KDPickedImage *pickedImage_;
    
    UIButton *recordBtn_;
    UIImageView *recordBgView_;
    
    
    UIButton *pickerBtn_;
    UILabel *wordLimitsLabel_;
    UIButton *expressionBtn_;
    UIView   *functionView_;
    UIView   *firstPromptView_;
    UIActivityIndicatorView *activityView_;
    
    HPGrowingTextView *textView_; // weak reference
    
    NSRange caret;
    KDExpressionInputView *expressionInputView_;
    
    KDDMChatInputExtendView *extendView_;
    KDProgressActionView *progressActionView_;
    UIView *maskView_;
    
    CGFloat keyboardHeight_;
    CGFloat previousTextViewContentHeight_;
    
    struct {
        unsigned int isKeyBoardShown:1;
        unsigned int isFunctionViewShown:1;
        unsigned int isExpressionViewShown:1;
    } viewFlags_;
    
    KDInputViewType type_;
}

@property(nonatomic, assign) id<KDDMChatInputViewDelegate> delegate;
@property(nonatomic, assign) UIViewController *hostViewController;
@property(nonatomic, readonly) UIButton       *recordBtn;

@property(nonatomic, retain) KDPickedImage *pickedImage;
@property(nonatomic, retain) KDDefaultInputCenterView *inputImplView;

- (id)initWithFrame:(CGRect)frame delegate:(id<KDDMChatInputViewDelegate>)delegate hostViewController:(UIViewController *)hostViewController;

- (id)initWithFrame:(CGRect)frame delegate:(id<KDDMChatInputViewDelegate>)delegate hostViewController:(UIViewController *)hostViewController inputType:(KDInputViewType)type;

- (void)showProcessIndicatorVisible:(BOOL)visible;
- (void)setProgress:(float)progress info:(NSString *)info;

- (void)setPickedImage:(KDPickedImage *)pickedImage;

- (void)setPickedPhoto:(UIImage *)image;

- (CGFloat)extendViewHeight;

- (BOOL)hasContent;
- (BOOL)checkedMail;
- (BOOL)hasAttachments;
- (NSString *)text;
- (void)reset:(BOOL)needClearText;
- (void)resignFirstResponderIfNeed;
- (BOOL)isFirstResponder;
- (BOOL)isActive;
- (void)addKeyboardNotification;
- (void)removeKeyboardNotification;

- (void)resetReturnKeyStatus;

@end


@protocol KDDMChatInputViewDelegate <KDAlertViewDelegate>
@optional

- (void)presentImagePickerForDMChatInputView:(KDDMChatInputView *)dmChatInputView takePhoto:(BOOL)takePhoto;
- (void)presentLocationSelectView:(KDDMChatInputView *)dmChatInputView;
- (void)sendContentsInDMChatInputView:(KDDMChatInputView *)dmChatInputView;
- (void)didChangeDMChatInputViewVisibleHeight:(KDDMChatInputView *)dmChatInputView;

- (void)dmChatInputViewBeginRecord:(KDDMChatInputView *)dmChatInputView;
- (void)dmChatInputViewEndRecord:(KDDMChatInputView *)dmChatInputView;

@end
