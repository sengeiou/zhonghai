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
@class KKTextView;

@protocol KKTextViewDelegate <NSObject>
@optional
- (void)handelPanGestureView:(KKTextView*)textView withGR:(UIPanGestureRecognizer *)pan;

@end

typedef void(^TapTextBlock)();
@interface KKTextView : UIView
@property (nonatomic, strong)TapTextBlock tapTextBlock;
@property (nonatomic, strong) KKTextLable *label;
@property (nonatomic, weak) id <KKTextViewDelegate> delegate;

+ (void)setActiveTextView:(KKTextView*)view;

- (id)initWithEditor:(KDImageEditorViewController*)editor;

- (void)setLableText:(NSString *)text;
- (void)setLableTextColor:(UIColor *)color;
- (NSString *)getLableText;

@end
