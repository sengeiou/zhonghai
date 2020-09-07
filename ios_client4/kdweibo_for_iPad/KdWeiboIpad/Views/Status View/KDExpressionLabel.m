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

#define KD_TAG_CORETEXTVIEW  110

@implementation KDExpressionLabel
@synthesize text = text_;
@synthesize font = font_;
@synthesize textColor = textColor_;
@synthesize textAlignment = textAlignment_;

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
    [contentView_ release];
    [text_ release];
    [textColor_ release];
    
    [super dealloc];
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

+ (NSString *)descriptionForTextAlignment:(UITextAlignment)textAlignment {
    
    if(textAlignment == UITextAlignmentCenter) {
        return @"center";
    } else if(textAlignment == UITextAlignmentLeft) {
        return @"left";
    } else if(textAlignment == UITextAlignmentRight) {
        return @"right";
    }
    
    return @"left";
}

///

- (void)setupView {
    [DTAttributedTextContentView setLayerClass:[DTTiledLayerWithoutFade class]];
    contentView_ = [[DTAttributedTextContentView alloc] initWithFrame:self.bounds];
    contentView_.backgroundColor = [UIColor clearColor];
    contentView_.tag = KD_TAG_CORETEXTVIEW;
    
    contentView_.shouldDrawImages = YES;
    contentView_.shouldDrawLinks = YES;
    contentView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    contentView_.delegate = self;
    
    [self addSubview:contentView_];
}


- (void)setText:(NSString *)text {
    if(![text isEqualToString:text_]){
        [text_ release];
        text_ = [text copy];
        
        NSData *html = [[[self class] convertPlainTextToHTML:text_ withType:type_  textAlignment:textAlignment_ textColor:textColor_ textFont:font_] dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attString = [[[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL] autorelease];
        
        contentView_.attributedString = attString;
    }
}

+ (NSString *)convertPlainTextToHTML:(NSString *)text withType:(KDExpressionLabelType)type textAlignment:(UITextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font {
    NSString *markString = text;
    
    //before convert '<' to &#60 '>' to &#62. '\n' to <br/>
    markString = [markString stringByReplacingOccurrencesOfString:@"<" withString:@"&#60"];
    markString = [markString stringByReplacingOccurrencesOfString:@">" withString:@"&#62"];
    markString = [markString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    if(type == KDExpressionLabelType_URL || type == KDExpressionLabelType_NONE) {
        markString = [NSString stringWithFormat:@"<p style=\"font-size:%fpx; font-family:%@; line-height:%fpx; text-align:%@; color:%@;\">%@</p>", font.pointSize, font.familyName, font.lineHeight,[self descriptionForTextAlignment:alignment], [self convertColorToHEX:color], markString];
    }else if(type == KDExpressionLabelType_Expression) {
        markString = [NSString stringWithFormat:@"<p style=\"font-size:%fpx; font-family:%@; line-height:1.2; text-align:%@; color:%@;\">%@</p>", font.pointSize, font.familyName, [self descriptionForTextAlignment:alignment], [self convertColorToHEX:color], markString];
    }
    
    // show expression
    if(type == KDExpressionLabelType_Expression) {
        NSRegularExpression *expReg = [[[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionCaseInsensitive error:NULL] autorelease];
        NSUInteger searchBeginLocation = 0;
        
        while(1) {
            NSTextCheckingResult *result = [expReg firstMatchInString:markString options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(searchBeginLocation, markString.length - searchBeginLocation)];
            
            if(!result || result.range.location == NSNotFound) break;
            
            NSString *expCode = [markString substringWithRange:result.range];
            NSString *imageName = [KDExpressionCode codeStringToImageName:expCode];
            
            if(imageName && ![imageName isEqualToString:@""]) {
                NSString *imageString = [NSString stringWithFormat:@"<img src=\"%@\">", imageName];
                
                markString = [markString stringByReplacingCharactersInRange:result.range withString:imageString];
                searchBeginLocation = result.range.location + imageString.length;
            }else {
                searchBeginLocation = result.range.location + result.range.length;
            }
        }
    } else if(type == KDExpressionLabelType_URL) {
        NSArray *urlEntities = [TwitterText URLsInText:markString];
        CGFloat offsetLocation = 0.0f;
        
        for(TwitterTextEntity *entity in urlEntities) {
            if(entity.type == TwitterTextEntityURL) {
                NSString *urlString = [markString substringWithRange:NSMakeRange(entity.range.location + offsetLocation, entity.range.length)];
                NSString *replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#198eb6;\" href=\"%@\">%@</a>", urlString, urlString];
                
                markString = [markString stringByReplacingCharactersInRange:NSMakeRange(entity.range.location + offsetLocation, entity.range.length) withString:replaceString];
                offsetLocation += (replaceString.length - entity.range.length);
            }
        }
    }
    
    markString = [NSString stringWithFormat:
                  @"<html> \
                  <head> \
                  <style type=\"text/css\">\
                  body{\
                        margin:0;\
                        padding:0;\
                       }\
                  </style>\
                  </head>\
                  <body>\
                  %@\
                  </body>\
                  </html>", markString];
    
    return markString;
}

+ (CGSize)sizeWithString:(NSString *)content constrainedToSize:(CGSize)size withType:(KDExpressionLabelType)type textAlignment:(UITextAlignment)alignment textColor:(UIColor *)color textFont:(UIFont *)font {
    NSData *html = [[self convertPlainTextToHTML:content withType:type textAlignment:alignment textColor:color textFont:font] dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attString = [[[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL] autorelease];
    
    [DTAttributedTextContentView setLayerClass:[DTTiledLayerWithoutFade class]];
    DTAttributedTextContentView *contentView = [[[DTAttributedTextContentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)] autorelease];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.tag = KD_TAG_CORETEXTVIEW;
    
//    contentView.shouldDrawImages = YES;
//    contentView.shouldDrawLinks = YES;
    
    
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    contentView.attributedString = attString;
    
    [contentView sizeToFit];
    
    return contentView.bounds.size;
}

- (CGSize)sizeThatFits:(CGSize)size {
    [contentView_ setFrame:CGRectMake(0.0f, 0.0f, size.width, 1.0f)];
    [contentView_ sizeToFit];
    
    return contentView_.bounds.size;
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
    
    return [linkButton autorelease];
}

- (void)linkButtonClicked:(DTLinkButton *)sender {
    NSString *url = [sender.URL absoluteString];
    
    f_(url);
}

@end
