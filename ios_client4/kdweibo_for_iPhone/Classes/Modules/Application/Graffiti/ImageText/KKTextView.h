//
//  KKTextView.h
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKTextLable.h"

@class KDImageEditorViewController;

static NSString* const kTextViewActiveViewDidTapNotification = @"kTextViewActiveViewDidTapNotification";

@interface KKTextView : UIView

@property (nonatomic, strong) KKTextLable *label;

+ (void)setActiveTextView:(KKTextView*)view;

- (void)setAvtive:(BOOL)active;

- (id)initWithEditor:(KDImageEditorViewController*)editor;

- (void)setLableText:(NSString *)text;
- (void)setLableTextColor:(UIColor *)color;
- (NSString *)getLableText;

@end
