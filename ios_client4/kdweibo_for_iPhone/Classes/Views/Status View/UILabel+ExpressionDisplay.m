//
//  UILabel+ExpressionDisplay.m
//  kdweibo
//
//  Created by shen kuikui on 13-3-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "UILabel+ExpressionDisplay.h"

#import "DTCoreText.h"
#import "DTTiledLayerWithoutFade.h"
#import "KDExpressionCode.h"

#define KD_TAG_CORETEXTVIEW  110

@implementation UILabel (ExpressionDisplay)

//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    
//    if(self) {
//        [self setupView];
//    }
//    
//    return self;
//}
//
//- (void)setupView {
////    DTAttributedTextContentView *contentView = (DTAttributedTextContentView *)[self viewWithTag:KD_TAG_CORETEXTVIEW];
////    if(!contentView) {
////        [DTAttributedTextContentView setLayerClass:[DTTiledLayerWithoutFade class]];
////        contentView = [[DTAttributedTextContentView alloc] initWithFrame:self.bounds];
////        contentView.backgroundColor = [UIColor clearColor];
////        contentView.tag = KD_TAG_CORETEXTVIEW;
////        
////        contentView.shouldDrawImages = YES;
////        contentView.shouldDrawLinks = YES;
////        
////        [self addSubview:contentView];
////        [contentView release];
////    }
//}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    
//    NSString *markString = self.text;
//    
//    markString = [NSString stringWithFormat:@"<p style=\"font-size:%fpx; font-family:sans-serif; line-height:1.2;\">%@<>", self.font.pointSize, markString];
//    
//    // show expression
//    NSRegularExpression *expReg = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionCaseInsensitive error:NULL];
//    NSUInteger searchBeginLocation = 0;
//    
//    while(1) {
//        NSTextCheckingResult *result = [expReg firstMatchInString:markString options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(searchBeginLocation, markString.length - searchBeginLocation)];
//        
//        if(!result || result.range.location == NSNotFound) break;
//        
//        NSString *expCode = [markString substringWithRange:result.range];
//        NSString *imageName = [KDExpressionCode codeStringToImageName:expCode];
//        
//        if(imageName && ![imageName isEqualToString:@""]) {
//            NSString *imageString = [NSString stringWithFormat:@"<img src=\"%@\" width=22 height=22>", imageName];
//            
//            markString = [markString stringByReplacingCharactersInRange:result.range withString:imageString];
//            searchBeginLocation = result.range.location + imageString.length;
//        }else {
//            searchBeginLocation = result.range.location + result.range.length;
//        }
//    }
//    
//    NSData *html = [markString dataUsingEncoding:NSUTF8StringEncoding];
//    NSAttributedString *attString = [[[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL] autorelease];
//    
//    DTAttributedTextContentView *contentView = (DTAttributedTextContentView *)[self viewWithTag:KD_TAG_CORETEXTVIEW];
//    contentView.attributedString = attString;
//    
//    [contentView sizeToFit];
//    
//    self.bounds = contentView.bounds;
//
//}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    NSString *markString = self.text;
//    
//    markString = [NSString stringWithFormat:@"<p style=\"font-size:15px; font-family:sans-serif; line-height:1.2;\">%@<>", markString];
//    
//    // show expression
//    NSRegularExpression *expReg = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionCaseInsensitive error:NULL];
//    NSUInteger searchBeginLocation = 0;
//    
//    while(1) {
//        NSTextCheckingResult *result = [expReg firstMatchInString:markString options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(searchBeginLocation, markString.length - searchBeginLocation)];
//        
//        if(!result || result.range.location == NSNotFound) break;
//        
//        NSString *expCode = [markString substringWithRange:result.range];
//        NSString *imageName = [KDExpressionCode codeStringToImageName:expCode];
//        
//        if(imageName && ![imageName isEqualToString:@""]) {
//            NSString *imageString = [NSString stringWithFormat:@"<img src=\"%@\" width=22 height=22>", imageName];
//            
//            markString = [markString stringByReplacingCharactersInRange:result.range withString:imageString];
//            searchBeginLocation = result.range.location + imageString.length;
//        }else {
//            searchBeginLocation = result.range.location + result.range.length;
//        }
//    }
//    
//    NSData *html = [markString dataUsingEncoding:NSUTF8StringEncoding];
//    NSAttributedString *attString = [[[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL] autorelease];
//    
//    DTAttributedTextContentView *contentView = (DTAttributedTextContentView *)[self viewWithTag:KD_TAG_CORETEXTVIEW];
//    contentView.attributedString = attString;
//    
//    [contentView sizeToFit];
//    
//    self.bounds = contentView.bounds;
//
//}

@end
