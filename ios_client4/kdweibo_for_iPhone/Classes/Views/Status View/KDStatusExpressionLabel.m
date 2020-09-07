//
//  KDStatusExpressionLabel.m
//  kdweibo
//
//  Created by shen kuikui on 13-3-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDStatusExpressionLabel.h"


@implementation KDStatusExpressionLabel

- (DTAttributedTextContentView *)contentView {
    if (!contentView_) {
        //此处改动：iOS 7.0下CATiledLayer有个bug，收到内存警告后，内容为空白。故将之替换为CALayer，会造成性能损失，待Apple修复此bug后需改回来。
        //    [DTAttributedTextContentView setLayerClass:[DTTiledLayerWithoutFade class]];
        [DTAttributedLabel setLayerClass:[CALayer class]];
        contentView_ = [[DTAttributedLabel alloc] initWithFrame:self.bounds];
        contentView_.backgroundColor = [UIColor clearColor];
        contentView_.tag = KD_TAG_CORETEXTVIEW;
        
        contentView_.shouldDrawImages = YES;
        contentView_.shouldDrawLinks = YES;
        contentView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        contentView_.delegate = self;
        [contentView_ setEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
        ((DTAttributedLabel *)contentView_).lineBreakMode = NSLineBreakByTruncatingTail;
        
    }
    return contentView_;
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
     ((DTAttributedLabel *)contentView_).numberOfLines = numberOfLines;
}

//覆盖父类的方法，主要是屏蔽表情的宽度计算部分 解决在ios6 下显示的问题。
+ (CGSize)sizeWithString:(NSString *)content constrainedToSize:(CGSize)size withType:(KDExpressionLabelType)type textAlignment:(NSTextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font  {
    
    if (content == nil)     return CGSizeZero;
    
    NSData *html = [[self convertPlainTextToHTML:content withType:type textAlignment:alignment textColor:color textFont:font] dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL];//; autorelease];
    
    [DTAttributedTextContentView setLayerClass:[CALayer class]];
    DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];// autorelease];
    [contentView setEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.tag = KD_TAG_CORETEXTVIEW;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    contentView.attributedString = attString;
    contentView.shouldDrawImages = NO;
    contentView.shouldDrawLinks = NO;
    
    CGSize retSize = [contentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:size.width];
    
    retSize.width = [content sizeWithFont:font constrainedToSize:size].width;
    
    return retSize;
}

+ (CGSize)sizeWithString:(NSString *)content constrainedToSize:(CGSize)size withType:(KDExpressionLabelType)type textAlignment:(NSTextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font limitLineNumber:(NSUInteger)limitLineNumber moreThanLimit:(BOOL *)moreThanLimit {
    CGSize resultSize = [self sizeWithString:content constrainedToSize:size withType:type textAlignment:alignment textColor:color textFont:font];
//   CGFloat oneLineHeight = [self sizeWithString:ASLocalizedString(@"[汗]")constrainedToSize:size withType:type textAlignment:alignment textColor:color textFont:font].height;
    CGFloat oneLineHeight = font.lineHeight;
    NSUInteger lineNum = ceilf(resultSize.height/oneLineHeight);
    if (limitLineNumber >=lineNum) {
        *moreThanLimit = NO;
    }else {
        *moreThanLimit = YES;
        lineNum = limitLineNumber;
        resultSize.height = lineNum *oneLineHeight;
    }
    return resultSize;
}
@end
