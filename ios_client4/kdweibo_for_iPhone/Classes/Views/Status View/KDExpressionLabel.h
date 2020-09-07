//
//  KDExpressionLabel.h
//  kdweibo
//
//  Created by shen kuikui on 13-3-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTCoreText.h"
#import "DTTiledLayerWithoutFade.h"
#import "DTCoreTextLayouter.h"

#define KD_TAG_CORETEXTVIEW  110

enum {
    KDExpressionLabelType_NONE = 0x00,
    KDExpressionLabelType_Expression = 1 << 1,
    KDExpressionLabelType_URL = 1 << 2,
    KDExpressionLabelType_USERNAME = 1 << 3,
    KDExpressionLabelType_TOPIC = 1 << 4,
    KDExpressionLabelType_PHONENUMBER = 1 << 5,
    KDExpressionLabelType_EMAIL = 1 << 6,
    KDExpressionLabelType_Keyword = 1 << 7
};

typedef UInt8 KDExpressionLabelType;

typedef void (*MyFunc)(NSString *url);

@class KDExpressionLabel;

@protocol KDExpressionLabelDelegate <NSObject>

@optional
- (void)expressionLabel:(KDExpressionLabel *)label didClickUserWithName:(NSString *)userName;
- (void)expressionLabel:(KDExpressionLabel *)label didClickTopicWithName:(NSString *)topicName;
- (void)expressionLabel:(KDExpressionLabel *)label didClickUrl:(NSString *)urlString;
- (void)expressionLabel:(KDExpressionLabel *)label didClickPhoneNumber:(NSString *)phoneNumber;
- (void)expressionLabel:(KDExpressionLabel *)label didClickEmail:(NSString *)email;
- (void)expressionLabel:(KDExpressionLabel *)label didClickKeyword:(NSString *)keyword;

@end

@interface KDExpressionLabel : UIView <DTAttributedTextContentViewDelegate>
{
@protected
    DTAttributedTextContentView *contentView_;
    KDExpressionLabelType type_;
    MyFunc f_;
}

@property (nonatomic, assign) id<KDExpressionLabelDelegate> delegate;
/**
 *  添加需要显示高亮效果的字符串
 */
@property (nonatomic, copy) NSString * highlightText; //需要显示高亮的文字

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, retain) DTAttributedTextContentView *contentView;
@property(nonatomic, assign) KDExpressionLabelType type;
- (id)initWithFrame:(CGRect)frame andType:(KDExpressionLabelType)type urlRespondFucIfNeed:(MyFunc)func;

//+ (CGSize)sizeWithString:(NSString *)content constrainedToSize:(CGSize)size withType:(KDExpressionLabelType)type textAlignment:(UITextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font;
//
//+ (NSString *)convertPlainTextToHTML:(NSString *)text withType:(KDExpressionLabelType)type textAlignment:(UITextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font;
///**
// *  新增用于带有显示高亮效果的类方法，比起之前的方法就是增加一个参数
// *  alanwong
// *
// */
//+ (NSString *)convertPlainTextToHTML:(NSString *)text withType:(KDExpressionLabelType)type textAlignment:(UITextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font highlightText:(NSString *)hlText;
+ (CGSize)sizeWithString:(NSString *)content
       constrainedToSize:(CGSize)size
                withType:(KDExpressionLabelType)type
           textAlignment:(NSTextAlignment)alignment
               textColor:(UIColor *)color
                textFont:(UIFont *)font;

+ (NSString *)convertPlainTextToHTML:(NSString *)text
                            withType:(KDExpressionLabelType)type
                       textAlignment:(NSTextAlignment)alignment
                           textColor:(UIColor *)color
                            textFont:(UIFont *)font;
@end