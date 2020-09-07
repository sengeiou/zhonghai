//
//  NSMutableAttributedString+DZCategory.h
//  kdweibo
//
//  Created by Darren on 15/7/14.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (DZCategory)

// 字体
- (void)dz_setFont:(UIFont *)font;
- (void)dz_setFont:(UIFont *)font range:(NSRange)range;

// 颜色
- (void)dz_setTextColor:(UIColor *)color;
- (void)dz_setTextColor:(UIColor *)color range:(NSRange)range;

// 对齐
- (void)dz_setTextAlignment:(NSTextAlignment)alignment;
- (void)dz_setTextAlignment:(NSTextAlignment)alignment range:(NSRange)range;

// 下划线
- (void)dz_setUnderline;
- (void)dz_setUnderlineWithRange:(NSRange)range;

// NSParagraphStyle
- (void)dz_setParagraphStyle:(NSParagraphStyle *)style;
- (void)dz_setParagraphStyle:(NSParagraphStyle *)style range:(NSRange)range;

// NSBaselineOffsetAttributeName
- (void)dz_setBaselineOffset:(CGFloat)fOffset;
- (void)dz_setBaselineOffset:(CGFloat)fOffset range:(NSRange)range;

// letter spacing
- (void)dz_setLetterSpacing:(CGFloat)fSpacing;
- (void)dz_setLetterSpacing:(CGFloat)fSpacing range:(NSRange)range;

// image
- (void)dz_setImageWithName:(NSString *)imageName range:(NSRange)range;

@end
