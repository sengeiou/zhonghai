//
//  KDExpressionLabel.m
//  kdweibo
//
//  Created by shen kuikui on 13-3-1.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDExpressionLabel.h"
#import "KDExpressionCode.h"
#import "TwitterText.h"
#import "NSString+URLEncode.h"



@implementation KDExpressionLabel
@synthesize contentView = contentView_;
@synthesize text = text_;
@synthesize font = font_;
@synthesize textColor = textColor_;
@synthesize textAlignment = textAlignment_;
@synthesize delegate = delegate_;
@synthesize highlightText = highlightText_;
@synthesize type = type_;

- (id)initWithFrame:(CGRect)frame andType:(KDExpressionLabelType)type urlRespondFucIfNeed :(MyFunc)func
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        type_ = type;
        f_ = func;
        
        [self setupView];
    }
    return self;
}

- (void)dealloc {
//    [contentView_ release];
//    [text_ release];
//    [textColor_ release];
//    if (highlightText_ != nil) {
//        [highlightText_ release];
//    }
    
    //[super dealloc];
}

////
+ (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component];
    }
}

+ (NSString *)convertColorToHEX:(UIColor *)color {
    CGFloat components[3];
    
    [self getRGBComponents:components forColor:color];
    
    return [NSString stringWithFormat:@"#%x%x%x", (int)components[0], (int)components[1], (int)components[2]];
}

+ (NSString *)descriptionForTextAlignment:(NSTextAlignment)textAlignment {
    
    if(textAlignment == NSTextAlignmentCenter) {
        return @"center";
    } else if(textAlignment == NSTextAlignmentLeft) {
        return @"left";
    } else if(textAlignment == NSTextAlignmentRight) {
        return @"right";
    }
    
    return @"left";
}

- (void)setupView {
    
    [self addSubview:self.contentView];
}

- (DTAttributedTextContentView *)contentView {
    if (!contentView_) {
        //此处改动：iOS 7.0下CATiledLayer有个bug，收到内存警告后，内容为空白。故将之替换为CALayer，会造成性能损失，待Apple修复此bug后需改回来。
        //    [DTAttributedTextContentView setLayerClass:[DTTiledLayerWithoutFade class]];
        [DTAttributedTextContentView setLayerClass:[CALayer class]];
        contentView_ = [[DTAttributedTextContentView alloc] initWithFrame:self.bounds];
        contentView_.backgroundColor = [UIColor clearColor];
        contentView_.tag = KD_TAG_CORETEXTVIEW;
        
        contentView_.shouldDrawImages = YES;
        contentView_.shouldDrawLinks = YES;
        contentView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        contentView_.delegate = self;
        [contentView_ setEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];

    }
    return contentView_;
}

- (void)setText:(NSString *)text {
    if(![text isEqualToString:text_] || [highlightText_ length] > 0){
//        [text_ release];
        text_ = [text copy];
        NSData *html = [[[self class] convertPlainTextToHTML:text_ withType:type_  textAlignment:textAlignment_ textColor:textColor_ textFont:font_ highlightText:highlightText_] dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attString = [[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL] ;//autorelease];
        
        contentView_.attributedString = attString;
        [contentView_ setNeedsDisplay];
    }
}

+ (NSString *)convertPlainTextToHTML:(NSString *)text
                            withType:(KDExpressionLabelType)type
                       textAlignment:(NSTextAlignment)alignment
                           textColor:(UIColor *)color
                            textFont:(UIFont *)font {
    NSString *markString = text;
    
    //before convert '<' to &#60 '>' to &#62. '\n' to <br/>
    markString = [markString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    markString = [markString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    markString = [markString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    //show url
    if (type & (KDExpressionLabelType_URL | KDExpressionLabelType_USERNAME | KDExpressionLabelType_TOPIC | KDExpressionLabelType_PHONENUMBER | KDExpressionLabelType_EMAIL | KDExpressionLabelType_Keyword)) {
        NSArray *entities = [TwitterText entitiesInText:markString];
        NSUInteger locationOffset = 0.0;
        
        
        for (TwitterTextEntity *entity in entities) {
            NSString *url = nil;
            NSString *correspondString = [markString substringWithRange:NSMakeRange(entity.range.location + locationOffset, entity.range.length)];
            
            switch (entity.type) {
                case TwitterTextEntityScreenName:
                    if (type & KDExpressionLabelType_USERNAME) {
                        url = [NSString stringWithFormat:@"user:%@", [correspondString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]]];
                    }
                    break;
                case TwitterTextEntityHashtag:
                    if (type & KDExpressionLabelType_TOPIC) {
                        url = [NSString stringWithFormat:@"topic:%@", [correspondString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]]];
                    }
                    break;
                case TwitterTextEntityURL:
                    if (type & KDExpressionLabelType_URL) {
                        url = [NSString stringWithFormat:@"url:%@", correspondString];
                    }
                    break;
                case TwitterTextEntityPhoneNumber:
                    if (type & KDExpressionLabelType_PHONENUMBER) {
                        url = [NSString stringWithFormat:@"phone:%@", correspondString];
                    }
                    break;
                case TwitterTextEntityEmail:
                    if (type & KDExpressionLabelType_EMAIL) {
                        url = [NSString stringWithFormat:@"email:%@", correspondString];
                    }
                    break;
                case TwitterTextEntityKeyword:
                    if (type & KDExpressionLabelType_Keyword) {
                        url = [NSString stringWithFormat:@"keyword:%@", correspondString];
                    }
                    break;
                default:
                    break;
            }
            if (url)
            {
                NSString *replaceString;
                
                if (([url rangeOfString:@"keyword:"].location != NSNotFound))
                {
                    //                        if (self.bLeft)
                    //                        {
                    //                            replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#FDB933;\" href=\"%@\">%@</a>", url, correspondString];
                    //                        }
                    //                        else
                    //                        {
                    replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#76f7ff;\" href=\"%@\">%@</a>", url, correspondString];
                    //                        }
                }
                else
                {
                    replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:%@;\" href=\"%@\">%@</a>", @"#FFFFFF", url, correspondString];
                    
                }
                
                
                markString = [markString stringByReplacingCharactersInRange:NSMakeRange(entity.range.location + locationOffset, entity.range.length) withString:replaceString];
                
                locationOffset += (replaceString.length - entity.range.length);
                
            }
            
        }
    }
    
    /**
     *  添加显示搜索字符串高亮效果的操作，如果hlText为空，就不进行操作
     *  alanwong
     *
     //     */
    //    if ([hlText length]) {
    //        NSString *hlHTmlText = [NSString stringWithFormat:@"<span style=\"color:#FDB933\">%@</span>", hlText];
    //        NSRange rang = NSMakeRange(0, 0);
    //        BOOL shouldContinue = YES;
    //        while (shouldContinue == YES) {
    //            NSInteger length = rang.length > 0 ? [hlHTmlText length] : 0;
    //            rang = [markString rangeOfString:hlText options:NSCaseInsensitiveSearch range:NSMakeRange(rang.location + length, [markString length] - (rang.location + length))];
    //            if (rang.length > 0) {
    //                NSString *targetString = [markString substringWithRange:rang];
    //                hlHTmlText = [NSString stringWithFormat:@"<span style=\"color:#FDB933\">%@</span>", targetString];
    //                markString = [markString stringByReplacingCharactersInRange:rang withString:hlHTmlText];
    //
    //            } else {
    //                shouldContinue = NO;
    //            }
    //        }
    //
    //    }
    
    
    if ((type & KDExpressionLabelType_Expression) == 0) {
        
        markString = [NSString stringWithFormat:@"<p style=\"font-size:%fpx; font-family:%@; line-height:%fpx; text-align:%@; color:%@;\">%@</p>", font.pointSize, font.familyName, font.lineHeight, [[self class] descriptionForTextAlignment:alignment], [[self class] convertColorToHEX:color], markString];
    } else if (type & KDExpressionLabelType_Expression) {
        
        markString = [NSString stringWithFormat:@"<p style=\"font-size:%fpx; font-family:%@; line-height:1.1; text-align:%@; color:%@;\">%@</p>", font.pointSize, font.familyName, [[self class] descriptionForTextAlignment:alignment], [[self class] convertColorToHEX:color], markString];
    }
    
    
    markString = [markString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"&#60;"];
    markString = [markString stringByReplacingOccurrencesOfString:@"&gt;" withString:@"&#62;"];
    
    // show expression
    if (type & KDExpressionLabelType_Expression) {
        NSRegularExpression *expReg = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionCaseInsensitive error:NULL];
        NSUInteger searchBeginLocation = 0;
        
        while (1) {
            NSTextCheckingResult *result = [expReg firstMatchInString:markString options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(searchBeginLocation, markString.length - searchBeginLocation)];
            
            if (!result || result.range.location == NSNotFound) break;
            
            NSString *expCode = [markString substringWithRange:result.range];
            NSString *imageName = [KDExpressionCode codeStringToImageName:expCode];
            
            if (imageName && ![imageName isEqualToString:@""]) {
                NSString *imageString = [NSString stringWithFormat:@"<img src=\"%@\" width=%f height=%f>", imageName, font.lineHeight+1, font.lineHeight+1];
                
                markString = [markString stringByReplacingCharactersInRange:result.range withString:imageString];
                searchBeginLocation = result.range.location + imageString.length;
            } else {
                searchBeginLocation = result.range.location + result.range.length;
            }
        }
    }
    
    //处理emoji表情中的红心变黑问题.
    markString = [markString stringByReplacingOccurrencesOfString:@"❤" withString:@"<span style=\"font-family:apple color emoji\">&#10084;</span>"];
    
    markString = [NSString stringWithFormat:
                  @"<html> \
                  <head> \
                  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\
                  <style type=\"text/css\">\
                  body{\
                  margin:0;\
                  padding:0;\
                  }\
                  img {\
                  vertical-align:middle;\
                  }\
                  </style>\
                  </head>\
                  <body>\
                  %@\
                  </body>\
                  </html>", markString];
    
    
    return markString;
}



/**
 *  相对于原来的方法，新增一个highlightText的参数，指定要显示高亮的效果的字符串
 *  当highlightText为nil的时候，其他操作与原方法一样
 *  alanwong
 *
 */

+ (NSString *)convertPlainTextToHTML:(NSString *)text
                            withType:(KDExpressionLabelType)type
                       textAlignment:(NSTextAlignment)alignment
                           textColor:(UIColor *)color
                            textFont:(UIFont *)font
                       highlightText:(NSString *)hlText{
    NSString *markString = text;
    
    //before convert '<' to &#60 '>' to &#62. '\n' to <br/>
    markString = [markString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    markString = [markString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    markString = [markString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    //show url
    if (type & (KDExpressionLabelType_URL | KDExpressionLabelType_USERNAME | KDExpressionLabelType_TOPIC | KDExpressionLabelType_PHONENUMBER | KDExpressionLabelType_EMAIL | KDExpressionLabelType_Keyword)) {
        NSArray *entities = [TwitterText entitiesInText:markString];
        NSUInteger locationOffset = 0.0;
        
        
        for (TwitterTextEntity *entity in entities) {
            NSString *url = nil;
            NSString *correspondString = [markString substringWithRange:NSMakeRange(entity.range.location + locationOffset, entity.range.length)];
            
            switch (entity.type) {
                case TwitterTextEntityScreenName:
                    if (type & KDExpressionLabelType_USERNAME) {
                        url = [NSString stringWithFormat:@"user:%@", [correspondString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]]];
                    }
                    break;
                case TwitterTextEntityHashtag:
                    if (type & KDExpressionLabelType_TOPIC) {
                        url = [NSString stringWithFormat:@"topic:%@", [correspondString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]]];
                    }
                    break;
                case TwitterTextEntityURL:
                    if (type & KDExpressionLabelType_URL) {
                        url = [NSString stringWithFormat:@"url:%@", correspondString];
                    }
                    break;
                case TwitterTextEntityPhoneNumber:
                    if (type & KDExpressionLabelType_PHONENUMBER) {
                        url = [NSString stringWithFormat:@"phone:%@", correspondString];
                    }
                    break;
                case TwitterTextEntityEmail:
                    if (type & KDExpressionLabelType_EMAIL) {
                        url = [NSString stringWithFormat:@"email:%@", correspondString];
                    }
                    break;
                case TwitterTextEntityKeyword:
                    if (type & KDExpressionLabelType_Keyword) {
                        url = [NSString stringWithFormat:@"keyword:%@", correspondString];
                    }
                    break;
                default:
                    break;
            }
            if (url)
            {
                NSString *replaceString;
                
                if (([url rangeOfString:@"keyword:"].location != NSNotFound))
                {
                    //                        if (self.bLeft)
                    //                        {
                    //                            replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#FDB933;\" href=\"%@\">%@</a>", url, correspondString];
                    //                        }
                    //                        else
                    //                        {
                    replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#76f7ff;\" href=\"%@\">%@</a>", url, correspondString];
                    //                        }
                }
                else
                {
                    replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:%@;\" href=\"%@\">%@</a>", @"#1a85ff", url, correspondString];
                    
                }
                
                
                markString = [markString stringByReplacingCharactersInRange:NSMakeRange(entity.range.location + locationOffset, entity.range.length) withString:replaceString];
                
                locationOffset += (replaceString.length - entity.range.length);
                
            }
            
        }
    }
    
    /**
     *  添加显示搜索字符串高亮效果的操作，如果hlText为空，就不进行操作
     *  alanwong
     *
     */
    if ([hlText length]) {
        NSString *hlHTmlText = [NSString stringWithFormat:@"<span style=\"color:#FDB933\">%@</span>", hlText];
        NSRange rang = NSMakeRange(0, 0);
        BOOL shouldContinue = YES;
        while (shouldContinue == YES) {
            NSInteger length = rang.length > 0 ? [hlHTmlText length] : 0;
            rang = [markString rangeOfString:hlText options:NSCaseInsensitiveSearch range:NSMakeRange(rang.location + length, [markString length] - (rang.location + length))];
            if (rang.length > 0) {
                NSString *targetString = [markString substringWithRange:rang];
                hlHTmlText = [NSString stringWithFormat:@"<span style=\"color:#FDB933\">%@</span>", targetString];
                markString = [markString stringByReplacingCharactersInRange:rang withString:hlHTmlText];
                
            } else {
                shouldContinue = NO;
            }
        }
        
    }
    
    
    if ((type & KDExpressionLabelType_Expression) == 0) {
        
        markString = [NSString stringWithFormat:@"<p style=\"font-size:%fpx; font-family:%@; line-height:%fpx; text-align:%@; color:%@;\">%@</p>", font.pointSize, font.familyName, font.lineHeight, [[self class] descriptionForTextAlignment:alignment], [[self class] convertColorToHEX:color], markString];
    } else if (type & KDExpressionLabelType_Expression) {
        
        markString = [NSString stringWithFormat:@"<p style=\"font-size:%fpx; font-family:%@; line-height:1.1; text-align:%@; color:%@;\">%@</p>", font.pointSize, font.familyName, [[self class] descriptionForTextAlignment:alignment], [[self class] convertColorToHEX:color], markString];
    }
    
    
    markString = [markString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"&#60;"];
    markString = [markString stringByReplacingOccurrencesOfString:@"&gt;" withString:@"&#62;"];
    
    // show expression
    if (type & KDExpressionLabelType_Expression) {
        
        NSRegularExpression *expReg = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionCaseInsensitive error:NULL];
        NSUInteger searchBeginLocation = 0;
        
        
        NSRegularExpression *hrefReg = [[NSRegularExpression alloc] initWithPattern:@"<a[^>]*href[=\"\'\s]+([^\"\']*)[\"\']?[^>]*>" options:NSRegularExpressionCaseInsensitive error:NULL];
        
        while (1) {
            
            NSArray *hrefResults = [hrefReg matchesInString:markString options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, markString.length)];
            
            NSTextCheckingResult *result = [expReg firstMatchInString:markString options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(searchBeginLocation, markString.length - searchBeginLocation)];
            
            if (!result || result.range.location == NSNotFound) break;
            
            //add by fang,判断是否为协议内容,是的话不进行表情转义
            bool isLink = NO;
            for (NSTextCheckingResult *hrefResult in hrefResults)
            {
                if(result.range.location>hrefResult.range.location && result.range.location<hrefResult.range.location+hrefResult.range.length)
                {
                    isLink = YES;
                    break;
                }
            }
            
            if(isLink)
            {
                searchBeginLocation = result.range.location + result.range.length;
                continue;
            }
            
            
            NSString *expCode = [markString substringWithRange:result.range];
            NSString *imageName = [KDExpressionCode codeStringToImageName:expCode];
            
            if (imageName && ![imageName isEqualToString:@""]) {
                NSString *imageString = [NSString stringWithFormat:@"<img src=\"%@\" width=%f height=%f>", imageName, font.lineHeight+1, font.lineHeight+1];
                
                markString = [markString stringByReplacingCharactersInRange:result.range withString:imageString];
                searchBeginLocation = result.range.location + imageString.length;
            } else {
                searchBeginLocation = result.range.location + result.range.length;
            }
        }
    }
    
    //处理emoji表情中的红心变黑问题.
    markString = [markString stringByReplacingOccurrencesOfString:@"❤" withString:@"<span style=\"font-family:apple color emoji\">&#10084;</span>"];
    
    markString = [NSString stringWithFormat:
                  @"<html> \
                  <head> \
                  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\
                  <style type=\"text/css\">\
                  body{\
                  margin:0;\
                  padding:0;\
                  }\
                  img {\
                  vertical-align:middle;\
                  }\
                  </style>\
                  </head>\
                  <body>\
                  %@\
                  </body>\
                  </html>", markString];
    
    
    return markString;

}



+ (CGSize)sizeWithString:(NSString *)content constrainedToSize:(CGSize)size withType:(KDExpressionLabelType)type textAlignment:(NSTextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font  {
    
    if (content == nil)     return CGSizeZero;
    
    NSData *html = [[self convertPlainTextToHTML:content withType:type textAlignment:alignment textColor:color textFont:font] dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL] ;//autorelease];
    
    [DTAttributedTextContentView setLayerClass:[CALayer class]];
    DTAttributedTextContentView *contentView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)] ;//autorelease];
    //    if (isAboveiOS7) {
    [contentView setEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
    //    }
    contentView.backgroundColor = [UIColor clearColor];
    contentView.tag = KD_TAG_CORETEXTVIEW;
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    contentView.attributedString = attString;
    contentView.shouldDrawImages = NO;
    contentView.shouldDrawLinks = NO;
    
    
    CGSize retSize = [contentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:size.width];
    
    //    if(type & KDExpressionLabelType_Expression) {
    //        CGSize testSize = [ASLocalizedString(@"KDAuthViewController_ok")sizeWithFont:font constrainedToSize:size];
    //        if(retSize.height < testSize.height * 1.7f) {
    //            CGSize textSize = [content sizeWithFont:font];
    //
    //            NSRegularExpression *expReg = [[[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionCaseInsensitive error:NULL] autorelease];
    //
    //            NSArray *matches = [expReg matchesInString:content options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, content.length)];
    //
    //            for(NSTextCheckingResult *result in matches) {
    //                NSString *expCode = [content substringWithRange:result.range];
    //                NSString *imageName = [KDExpressionCode codeStringToImageName:expCode];
    //
    //                if(imageName && ![imageName isEqualToString:@""]) {
    //                    CGSize expSize = [expCode sizeWithFont:font constrainedToSize:size];
    //                    CGFloat widthGap = expSize.width - font.lineHeight - 1.0f;
    //                    textSize.width = textSize.width - widthGap;
    //                }
    //            }
    //            retSize.width = textSize.width;
    //        }
    //    }else {
    //        retSize.width = [content sizeWithFont:font constrainedToSize:size].width;
    //    }
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString);
    CGSize targetSize = CGSizeMake(size.width, CGFLOAT_MAX);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attString length]), NULL, targetSize, NULL);
    CFRelease(framesetter);
    retSize.width = fitSize.width;
    return retSize;
}



- (CGSize)sizeThatFits:(CGSize)size {
    //    [contentView_ setFrame:CGRectMake(0.0f, 0.0f, size.width, 1.0f)];
    //    [contentView_ sizeToFit];
    //    //return [contentView_ suggestedFrameSizeToFitEntireStringConstraintedToWidth:size.width];
    //    return contentView_.bounds.size;
    CGSize result = [[self class] sizeWithString:self.text constrainedToSize:CGSizeMake(size.width, size.height) withType:self.type textAlignment:self.textAlignment textColor:self.textColor textFont:self.font];
    return result;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [contentView_ setFrame:self.bounds];
}

#pragma mark - DTAttributedTextContentView
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame {
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    linkButton.URL = url;
    linkButton.GUID = identifier;
    linkButton.minimumHitSize = CGSizeMake(25.0f, 25.0f);
    [linkButton addTarget:self action:@selector(linkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return linkButton;// autorelease];
}

- (void)linkButtonClicked:(DTLinkButton *)sender {
    NSString *urlString = [sender.URL.absoluteString decodeFromURL];
    
    if ([urlString hasPrefix:@"user:"]) {
        NSString *userName = [urlString substringFromIndex:[@"user:" length]];
        if (delegate_ && [delegate_ respondsToSelector:@selector(expressionLabel:didClickUserWithName:)]) {
            [delegate_ expressionLabel:self didClickUserWithName:userName];
        }
    }
    else if ([urlString hasPrefix:@"topic:"]) {
        NSString *topicName = [urlString substringFromIndex:[@"topic:" length]];
        if (delegate_ && [delegate_ respondsToSelector:@selector(expressionLabel:didClickTopicWithName:)]) {
            [delegate_ expressionLabel:self didClickTopicWithName:topicName];
        }
    }
    else if ([urlString hasPrefix:@"url:"]) {
        NSString *url = [urlString substringFromIndex:[@"url:" length]];
        if (delegate_ && [delegate_ respondsToSelector:@selector(expressionLabel:didClickUrl:)]) {
            [delegate_ expressionLabel:self didClickUrl:url];
        }
        
        if (f_) {
            f_(url);
        }
    }
    else if ([urlString hasPrefix:@"phone:"]) {
        NSString *phoneNumber = [urlString substringFromIndex:[@"phone:" length]];
        if (delegate_ && [delegate_ respondsToSelector:@selector(expressionLabel:didClickPhoneNumber:)]) {
            [delegate_ expressionLabel:self didClickPhoneNumber:phoneNumber];
        }
    }
    else if ([urlString hasPrefix:@"email:"]) {
        NSString *email = [urlString substringFromIndex:[@"email:" length]];
        if (delegate_ && [delegate_ respondsToSelector:@selector(expressionLabel:didClickEmail:)]) {
            [delegate_ expressionLabel:self didClickEmail:email];
        }
    }
    
    else if ([urlString hasPrefix:@"keyword:"]) {
        NSString *keyword = [urlString substringFromIndex:[@"keyword:" length]];
        if (delegate_ && [delegate_ respondsToSelector:@selector(expressionLabel:didClickKeyword:)]) {
            [delegate_ expressionLabel:self didClickKeyword:keyword];
        }
    }
}



@end
