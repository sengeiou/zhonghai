//
//  KDStatusContentDetailView.m
//  kdweibo
//
//  Created by shen kuikui on 13-2-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDStatusContentDetailView.h"
#import "KDStatus.h"
#import "KDCommentStatus.h"
#import "TwitterText.h"
#import "KDExpressionCode.h"
#import "NSCharacterSet+Emoji.h"
#import "DTCoreText.h"
#import "DTTiledLayerWithoutFade.h"
#import "DTAttributedTextContentView.h"
#import "NSString+URLEncode.h"

@implementation KDStatusContentDetailView{
    DTAttributedTextContentView *contentView_;
}

@synthesize delegate = delegate_;
@synthesize mode = mode_;
@synthesize type = type_;

@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize alignment = _alignment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        mode_ = KDStatusContentDetailViewExpressionOnlyMode;
        type_ = KDStatusContentDetailViewTypeNormal;
        markString_ =nil;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andMode:(KDStatusContentDetailViewMode)mode {
    self = [self initWithFrame:frame];
    
    if(self) {
        mode_ = mode;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andMode:(KDStatusContentDetailViewMode)mode andType:(KDStatusContentDetailViewType)type {
    self = [self initWithFrame:frame andMode:mode];
    
    if(self) {
        type_ = type;
    }
    
    return self;
}

- (void)dealloc {
    
//    [markString_ release];
//    [status_ release];
//    [contentView_ release];
//    [_font release];
//    [_textColor release];
    
    //[super dealloc];
}

- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
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

- (NSString *)convertColorToHEX:(UIColor *)color {
    CGFloat components[3];
    
    [self getRGBComponents:components forColor:color];
    
    return [NSString stringWithFormat:@"#%x%x%x", (int)components[0], (int)components[1], (int)components[2]];
}

- (NSString *)descriptionForTextAlignment:(UITextAlignment)textAlignment {
    
    if(textAlignment == NSTextAlignmentCenter) {
        return @"center";
    } else if(textAlignment == NSTextAlignmentLeft) {
        return @"left";
    } else if(textAlignment == NSTextAlignmentRight) {
        return @"right";
    }
    
    return @"left";
}

- (void)setStatus:(KDStatus *)status {
    //if(status != status_) {
//        [status_ release];
    status_ = status ;// retain];
      if (status_) {
          markString_ = [status taskFormatContet] ;//retain];
          [self configView];
      }
    
    //}
}

- (void)setMarkString:(NSString *)string
{
    if (string != markString_) {
//        [markString_ release];
        markString_ = string ;//retain];
        [self configView];
    }
}

- (void)configView {
    NSString *markString = [NSString stringWithString:markString_];
    if(contentView_ == nil) {
        [DTAttributedTextContentView setLayerClass:[CALayer class]];
        contentView_ = [[DTAttributedTextContentView alloc] initWithFrame:self.bounds];
        contentView_.backgroundColor = [UIColor clearColor];
        contentView_.shouldDrawImages = YES;
        contentView_.shouldDrawLinks = YES;
        
        contentView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
         contentView_.delegate = self;
        
        [self addSubview:contentView_];
    }
    //before analysis. Convert '<' to &#60 '>' to &#62. '\n' to <br/>
    markString = [markString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    markString = [markString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    markString = [markString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    
    if(mode_ == KDStatusContentDetailViewCompleteMode) {
        NSArray *entities = [TwitterText entitiesInText:markString];
        NSUInteger locationOffset = 0.0;
        
        for(TwitterTextEntity *entity in entities) {
            NSString *url = nil;
            NSString *correspondString = [markString substringWithRange:NSMakeRange(entity.range.location + locationOffset, entity.range.length)];
            
            switch (entity.type) {
                case TwitterTextEntityScreenName:
                    url = [NSString stringWithFormat:@"user:%@", [correspondString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]]];
                    break;
                case TwitterTextEntityHashtag:
                    url = [NSString stringWithFormat:@"topic:%@", [correspondString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]]];
                    break;
                case TwitterTextEntityURL:
                    url = [NSString stringWithFormat:@"url:%@", correspondString];
                    break;
                default:
                    break;
            }
            
            if (url) {
                NSString *replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#1a85ff;\" href=\"%@\">%@</a>", url, correspondString];
                
                markString = [markString stringByReplacingCharactersInRange:NSMakeRange(entity.range.location + locationOffset, entity.range.length) withString:replaceString];
                
                locationOffset += (replaceString.length - entity.range.length);
            }
            
        }
        
        markString = [markString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"&#60;"];
        markString = [markString stringByReplacingOccurrencesOfString:@"&gt;" withString:@"&#62;"];
        
        if(type_ == KDStatusContentDetailViewTypeForwarding) {
            //加判断主要是为了 去掉转发被删除的微博前面的冒号；
            if (status_.author != nil) {
                markString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#1a85ff;\" href=\"user:%@\">%@</a>: %@",
                              (status_.author.username) ? status_.author.username : @"",
                              (status_.author.screenName) ? status_.author.screenName : @"",
                              markString];
            }
            else
            {
                markString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#1a85ff;\" href=\"user:%@\">%@</a> %@",
                              (status_.author.username) ? status_.author.username : @"",
                              (status_.author.screenName) ? status_.author.screenName : @"",
                              markString];
            }
           
        } else if(KDStatusContentDetailViewTypeReply == type_) {
            if([status_ isKindOfClass:[KDCommentStatus class]] && [(KDCommentStatus *)status_ replyUserId]) {
                markString = [NSString stringWithFormat:ASLocalizedString(@"KDStatusContentDetailView_markString"), [status_ replyScreenName], [status_ replyScreenName], markString];
            }
        }
    }
    
    markString = [NSString stringWithFormat:@"<p style=\"font-size:%fpx; font-family:%@; line-height:1.1; text-align:%@; color:%@;\">%@</p>", _font.pointSize, _font.familyName, [self descriptionForTextAlignment:_alignment], [self convertColorToHEX:_textColor], markString];

    // show expression
    NSRegularExpression *expReg = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]" options:NSRegularExpressionCaseInsensitive error:NULL];// autorelease];
    NSUInteger searchBeginLocation = 0;
    
    NSRegularExpression *hrefReg = [[NSRegularExpression alloc] initWithPattern:@"<a[^>]*href[=\"\'\s]+([^\"\']*)[\"\']?[^>]*>" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    while(1) {
        
        NSArray *hrefResults = [hrefReg matchesInString:markString options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, markString.length)];
        
        NSTextCheckingResult *result = [expReg firstMatchInString:markString options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(searchBeginLocation, markString.length - searchBeginLocation)];
        
        if(!result || result.range.location == NSNotFound) break;
        
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
        
        if(imageName && ![imageName isEqualToString:@""]) {
            NSString *imageString = [NSString stringWithFormat:@"<img src=\"%@\" width=%f height=%f>", imageName, _font.lineHeight, _font.lineHeight];
            
            markString = [markString stringByReplacingCharactersInRange:result.range withString:imageString];
            searchBeginLocation = result.range.location + imageString.length;
        }else {
            searchBeginLocation = result.range.location + result.range.length;
        }
    }
    
    //处理emoji表情中的红心变黑问题.
    markString = [markString stringByReplacingOccurrencesOfString:@"❤" withString:@"<span style=\"font-family:apple color emoji\">&#10084;</span>"];
    
    markString = [NSString stringWithFormat:
                  @"<html>\
                  <head> \
                  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /> \
                  <style type=\"text/css\">\
                  body {\
                  margin:0;\
                  padding:0;\
                       }\
                  img { \
                       vertical-align:middle;\
                      }\
                  </style>\
                  </head>\
                  <body>\
                  %@\
                  </body>\
                  </html>", markString];
    
    NSData *html = [markString dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attString =[[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL];// autorelease];
    
    contentView_.attributedString = attString;
    
//    [contentView_ sizeToFit];
    CGRect newFrame = self.frame;
    newFrame.size.height = [contentView_ intrinsicContentSize].height;
    self.frame = newFrame;
    if (delegate_ && [delegate_ respondsToSelector:@selector(contentViewDidChangeFrame:content:)]) {
        [delegate_ contentViewDidChangeFrame:self.frame content:self];
    }
    
}

#pragma mark - DTAttributedTextContentView Delegate method(s)
//url
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
    
    if([urlString hasPrefix:@"user:"]) {
        NSString *userName = [urlString substringFromIndex:[@"user:" length]];
        if(delegate_ && [delegate_ respondsToSelector:@selector(clickedUserWithUserName:)]) {
            [delegate_ clickedUserWithUserName:userName];
        }
    } else if([urlString hasPrefix:@"topic:"]) {
        NSString *topicName = [urlString substringFromIndex:[@"topic:" length]];
        if(delegate_ && [delegate_ respondsToSelector:@selector(clickedTopicWithTopicName:)]) {
            [delegate_ clickedTopicWithTopicName:topicName];
        }
    } else if([urlString hasPrefix:@"url:"]) {
        NSString *url = [urlString substringFromIndex:[@"url:" length]];
        if(delegate_ && [delegate_ respondsToSelector:@selector(clickedURL:)]) {
            [delegate_ clickedURL:url];
        }
    }
}


@end
