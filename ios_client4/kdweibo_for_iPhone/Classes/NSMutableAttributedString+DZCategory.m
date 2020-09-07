//
//  NSMutableAttributedString+DZCategory.m
//  kdweibo
//
//  Created by Darren on 15/7/14.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "NSMutableAttributedString+DZCategory.h"

@implementation NSMutableAttributedString (DZCategory)

- (void)dz_setFont:(UIFont *)font
{
    [self dz_setFont:font range:NSMakeRange(0, self.string.length)];
}

- (void)dz_setFont:(UIFont *)font range:(NSRange)range
{
    [self addAttributes:@{NSFontAttributeName: font} range:range];
}

- (void)dz_setTextColor:(UIColor *)color
{
    [self dz_setTextColor:color range:NSMakeRange(0, self.string.length)];
}

- (void)dz_setTextColor:(UIColor *)color range:(NSRange)range
{
    [self addAttributes:@{NSForegroundColorAttributeName: color} range:range];
}

- (void)dz_setTextAlignment:(NSTextAlignment)alignment
{
    [self dz_setTextAlignment:alignment range:NSMakeRange(0, self.string.length)];
}

- (void)dz_setTextAlignment:(NSTextAlignment)alignment range:(NSRange)range
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:alignment];
    [self addAttributes:@{NSParagraphStyleAttributeName: style} range:range];
}

- (void)dz_setUnderline
{
    [self dz_setUnderlineWithRange:NSMakeRange(0, self.string.length)];
}

- (void)dz_setUnderlineWithRange:(NSRange)range
{
    [self addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:range];
}

- (void)dz_setParagraphStyle:(NSParagraphStyle *)style
{
    [self dz_setParagraphStyle:style range:NSMakeRange(0, self.string.length)];
}

- (void)dz_setParagraphStyle:(NSParagraphStyle *)style range:(NSRange)range
{
    [self addAttributes:@{NSParagraphStyleAttributeName: style} range:range];
}

// NSBaselineOffsetAttributeName
- (void)dz_setBaselineOffset:(CGFloat)fOffset
{
    [self dz_setBaselineOffset:fOffset range:NSMakeRange(0, self.string.length)];
}

- (void)dz_setBaselineOffset:(CGFloat)fOffset range:(NSRange)range
{
    [self addAttributes:@{NSBaselineOffsetAttributeName: @(fOffset)} range:range];
}


- (void)dz_setLetterSpacing:(CGFloat)fSpacing
{
    [self dz_setLetterSpacing:fSpacing range:NSMakeRange(0, self.string.length)];
}

- (void)dz_setLetterSpacing:(CGFloat)fSpacing range:(NSRange)range
{
    [self addAttribute:NSKernAttributeName
                 value:@(fSpacing)
                 range:range];
}

- (void)dz_setImageWithName:(NSString *)imageName range:(NSRange)range
{
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [UIImage imageNamed:imageName];
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [self replaceCharactersInRange:range withAttributedString:attrStringWithImage];
}
@end
