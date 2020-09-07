
//
//  KDAttachmentIndicatorView.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-8-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDAttachmentIndicatorView : UIView {
 @private
    UIImageView *backroundImageView_;
    UIImageView *dividerImageView_;
    UIButton *indicatorButton_;
    UILabel *infoLabel_;
    NSString *iconName_;
    
    UIEdgeInsets contentEdgeInsets_;
    
    NSUInteger attachmentsCount_;
    
    id delegate_;
    
    SEL eventHandleSelector;
}

@property(nonatomic, retain, readonly) UIButton *indicatorButton;
@property(nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property(nonatomic, assign) NSUInteger attachmentsCount;
@property (nonatomic, copy) NSString *iconName;

- (void)setDefaultBackgroundImageStyle;

- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)setDividerImage:(UIImage *)dividerImage;

+ (CGFloat)defaultAttachmentIndicatorViewHeight;

- (void)addTaget:(id)target selector:(SEL)selector;

@end
