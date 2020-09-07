//
//  KDLayouter.m
//  kdweibo
//
//  Created by Tan yingqi on 12-10-31.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDLayouter.h"
#import "KDManagerContext.h"
#import "KDStatusView.h"
#import "KDExtendStatus.h"
#import "KWIStatusContent.h"
#import "KDManagerContext.h"
#import "TwitterTextEntity.h"
#import "TwitterText.h"
#import "DTCoreText.h"
#import "UIDevice+KWIExt.h"
#import "UIImage+Additions.h"
#import "NSDate+Additions.h"
#import "DTCoreText.h"
#import "KDDocumentListView.h"

UIKIT_STATIC_INLINE CGRect boundsByContrainedWidth(CGFloat width ,UIFont *font ,NSString *text) {
     CGSize size = CGSizeMake(width, MAXFLOAT);
     size =  [text sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeCharacterWrap];
     CGRect rect = CGRectMake(0, 0, size.width, size.height);
     return rect;
}

UIKIT_STATIC_INLINE NSAttributedString * buildAttriString(NSString *text, BOOL enable, CGFloat fontSize) {
    {
        NSString *markString = text;
        if (!markString || 0 == markString.length) {
            return nil;
        }
        
        markString = [markString stringByReplacingOccurrencesOfString:@"<" withString:@"&#60"];
        markString = [markString stringByReplacingOccurrencesOfString:@">" withString:@"&#62"];
        markString = [markString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        
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
            
            
            NSString *replaceString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:%@;\" href=\"%@\">%@</a>",enable?@"#198eb6":@"#333", url, correspondString];
            
            markString = [markString stringByReplacingCharactersInRange:NSMakeRange(entity.range.location + locationOffset, entity.range.length) withString:replaceString];
            
            locationOffset += (replaceString.length - entity.range.length);
        }
        
        markString = [NSString stringWithFormat:@"<p style=\"font-size:%dpx; font-family:sans-serif; line-height:1.2;\">%@<>",(int)fontSize, markString];
        
        
        NSData *html = [markString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSAttributedString *attString = [[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithHTMLData:html documentAttributes:NULL];
        
        if (6 <= [UIDevice curSysVer]) {
            NSMutableParagraphStyle *ps = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
            ps.lineHeightMultiple = 1.8;
            
            ps.maximumLineHeight = ps.minimumLineHeight = (int)fontSize * ps.lineHeightMultiple;
            [attString addAttributes:[NSDictionary dictionaryWithObject:ps
                                                                 forKey:NSParagraphStyleAttributeName]
                               range:NSMakeRange(0, attString.length)];
        }
        
        
        return [attString autorelease];
    }
}

UIKIT_STATIC_INLINE NSAttributedString * buildQuoteAttrStr(NSString * text,CGFloat fontSize){
    NSString * markString = text;
    markString = [markString stringByReplacingOccurrencesOfString:@"<" withString:@"&#60"];
    markString = [markString stringByReplacingOccurrencesOfString:@">" withString:@"&#62"];
    markString = [markString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    NSString *ctnTpl = [NSString stringWithFormat:@"<p style=\"font-size:%dpx; font-family:sans-serif; line- height:1.5; color:#555; background-color:transparent;\">%@</p>",(int)fontSize,markString];
    
    NSData *data = [ctnTpl dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithHTMLData:data
                                                                           documentAttributes:nil] autorelease];
    if (6 <= [UIDevice curSysVer]) {
        NSMutableParagraphStyle *ps = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        ps.lineHeightMultiple = 1.8;
        ps.maximumLineHeight = ps.minimumLineHeight = (int)fontSize * ps.lineHeightMultiple;
        [attrStr addAttributes:[NSDictionary dictionaryWithObject:ps
                                                           forKey:NSParagraphStyleAttributeName]
                         range:NSMakeRange(0, attrStr.length)];
    }
    return attrStr;
    
}

@implementation KDLayouter
@synthesize subLayouters = subLayouters_;
@synthesize superLayouter = superLayouter_;
@synthesize frame = frame_;
@synthesize bounds = bounds_;
@synthesize statusView = statusView_;
@synthesize constrainedWidth = constrainedWidth_;
@synthesize propertyDic = propertyDic_;

- (id) init {
    self =[super init];
    if (self) {
        //
        self.subLayouters = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}
- (KDLayouter *)preLayouter {
    KDLayouter *pre = nil;
    KDLayouter *superLayouter = [self superLayouter];
    if (superLayouter) {
        NSMutableArray *subLayouters = [superLayouter subLayouters];
        if ([subLayouters count] >0) {
            NSUInteger index =[subLayouters  indexOfObject:self];
            if (index >0) {
                pre = [subLayouters objectAtIndex:index -1];
            }
        }
    }
    return pre;
}

- (void)addSubLayouter:(KDLayouter *)layout {
    if (layout == self) {
        return;
    }
    [self.subLayouters addObject:layout];
    layout.superLayouter = self;
//    [layout updateFrame];
//    
//     CGRect theBounds = self.bounds;
//     theBounds.size.height = CGRectGetMaxY(layout.frame);
//     self.bounds = theBounds;
    
}

- (KDLayouter *)lastSubLayouter {
    KDLayouter *resut = nil;
    if ([self.subLayouters count] >0) {
      resut =   [self.subLayouters lastObject];
    }
    return resut;
}



+(KDLayouter *)layouterWithPropertyDic:(NSDictionary *)dic {
    KDLayouter *layouter = [[[self class] alloc] init];
    layouter.propertyDic = dic;
    layouter.defaultEdgeInsets = UIEdgeInsetsFromString([dic objectForKey:@"insets"]);
    return [layouter autorelease];
}

- (KDStatusView *)statusView {
    if (statusView_ == nil) {
        statusView_ = [[[self statusViewClass] alloc] init];
        statusView_.userInfo = self.propertyDic;
        statusView_.frame = self.frame;
        [statusView_ update];
        for (KDLayouter *layouter in subLayouters_) {
          KDStatusView *statusView = layouter.statusView;
          [statusView_ addSubview:statusView];
        }
    
    }

    return statusView_;
}

- (Class)statusViewClass {
    return [KDStatusView class];
}

- (CGRect)frame {
    if (CGRectEqualToRect(CGRectZero, frame_)) {
        KDLayouter *pre = [self preLayouter];
        UIEdgeInsets inst = [self defaultEdgeInsets];
        CGFloat offX = inst.left;
        CGFloat offY = inst.top ;
        if (pre != nil) {
            CGRect preFrame = CGRectZero;
            preFrame = pre.frame;
            offY +=CGRectGetMaxY(preFrame)+[pre defaultEdgeInsets].bottom;
        }
       CGRect bounds = [self bounds];
        //self.frame = CGRectOffset(bounds, offX, offY);
        if (self.propertyDic && [self.propertyDic objectForKey:@"bounds"]) {
            NSValue *value = [self.propertyDic objectForKey:@"bounds"];
            bounds = value.CGRectValue;
        }
        
        frame_ = CGRectOffset(bounds, offX, offY);
    }
    return frame_;
}

- (CGRect)bounds {
    CGRect result = CGRectZero;
    
    if (self.subLayouters.count >0) {
        KDLayouter *lastlayouter = self.lastSubLayouter;
        result.size.height = CGRectGetMaxY(lastlayouter.frame)+[lastlayouter defaultEdgeInsets].bottom;
        UIEdgeInsets insets = [self defaultEdgeInsets];
        result.size.width =  self.constrainedWidth - insets.left-insets.right;
    }
    return result;
}

- (CGFloat)constrainedWidth {
    if (!isnormal(constrainedWidth_)) {
        UIEdgeInsets insets = [self defaultEdgeInsets];
        if (self.superLayouter) {
            constrainedWidth_ = [self.superLayouter constrainedWidth]-insets.left-insets.right;
        }
       
    }
    return constrainedWidth_;
}

- (void)dealloc {
    KD_RELEASE_SAFELY(subLayouters_);
    KD_RELEASE_SAFELY(propertyDic_);
    KD_RELEASE_SAFELY(statusView_);
    [super dealloc];
}

@end



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDQuotedLayoutere
@implementation KDQuotedLayouter

//- (UIEdgeInsets)defaultEdgeInsets {
//    UIEdgeInsets result = UIEdgeInsetsMake(0, 0, 15, 10);
//    return result;
//}

- (Class)statusViewClass {
    return [KDQuotedStatusView class];
}

@end


#pragma - mark KDCoreTextLayouter
@implementation KDCoreTextLayouter

- (CGRect)bounds {
    CGRect result = CGRectZero;
        if (self.propertyDic) {
            NSAttributedString *string = [self.propertyDic objectForKey:@"text"];
            if (string) {
                DTAttributedTextContentView *view = [[DTAttributedTextContentView alloc] init];
                view.attributedString = string;
                result.size = [view suggestedFrameSizeToFitEntireStringConstraintedToWidth:self.constrainedWidth];
                [view release];
            }
        }
        
    return result;
}

- (Class)statusViewClass {
    return [KDLayouterCoreTextView class];
}
@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDHeaderLayouter
@implementation KDHeaderLayouter

- (CGRect)bounds {
    CGRect result = CGRectMake(0, 0, self.constrainedWidth- [self defaultEdgeInsets].left-[self defaultEdgeInsets].right, 24);

    return result;
}

- (void)dealloc {
    [super dealloc];
}
- (Class)statusViewClass {
    return [KDLayouterHeaderView class];
}

@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDThumbnailsLayouter
@implementation KDThumbnailsLayouter

- (void)dealloc {
    [super dealloc];
}

- (Class)statusViewClass {
    return [KDLayouterThumbnailsView class];
}

- (CGRect)bounds {
    return CGRectMake(0, 0, 100, 100);
}
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDImageLayouter
@implementation KDImageLayouter

- (CGRect)bounds {
    return CGRectMake(0, 0, 100, 100);
}

- (void)dealloc {
    [super dealloc];
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDFooterLayoutr
@implementation KDFooterLayoutr

- (void)dealloc {
    [super dealloc];
    
}
@end

@implementation KDCommentFooterLayouter

@end

@implementation  KDDocumentListLayouter : KDLayouter
- (Class)statusViewClass {
    return [KDLayouterDocumentListView class];
}
- (CGRect)bounds {
    CGRect result = CGRectMake(0, 0, self.constrainedWidth- [self defaultEdgeInsets].left-[self defaultEdgeInsets].right, 0);
    if (self.propertyDic) {
        id dataSource = [self.propertyDic objectForKey:@"dataSource"];
        if (dataSource) {
            NSArray *attachemts = [dataSource performSelector:@selector(attachments)];
            result.size.height = [KDDocumentListView heightOfTableViewByAttachemts:attachemts];
        }
    }
    return result;
}


@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDExtraStatusLayouter

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma - mark KDCommentCellLayouter

@implementation KDCommentCellLayouter

+ (KDLayouter *)layouter:(KDCommentStatus *)status constrainedWidth:(CGFloat)width {
    KDLayouter *layouter = [status propertyForKey:@"layouter"];
    if (layouter == nil) {
        NSString *insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 0, 10, 0));
        NSDictionary *dic = @{@"insets":insets};
        layouter = [KDCommentCellLayouter layouterWithPropertyDic:nil];
        [status setProperty:layouter forKey:@"layouter"];
        layouter.constrainedWidth = width;
        
        
        insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(8, 0, 5, 50));
        NSString *text = [status.author screenName];
        dic = @{@"font": [UIFont systemFontOfSize:15],
                              @"textColor":[UIColor blackColor],
                              @"text":text,
                              @"insets":insets};
       
        KDLayouter *nameLayouter = [KDHeaderLayouter layouterWithPropertyDic:dic];
        [layouter addSubLayouter:nameLayouter];
       
        
        insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(-10, 0, 10, 15));
        NSAttributedString *string =  [buildAttriString(status.text,NO,15.0f) copy];

        dic = @{@"font": [UIFont systemFontOfSize:15],
                              @"textColor":[UIColor blackColor],
                              @"text":string,
                              @"insets":insets};
        [string release];
        KDLayouter *textLayouter = [KDCoreTextLayouter layouterWithPropertyDic:dic];
        [layouter addSubLayouter:textLayouter];
        

        if (status.replyScreenName) {
           insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 0, 15, 10));
            //(0, 0, 15, 10)
            UIImage* image = [UIImage stretchableImageWithImageName:@"quoteBgMPanel" leftCapWidth:50 topCapHeight:20];
            dic = @{@"backgroundImage":image,
                    @"insets":insets
                   };
            KDLayouter *qutedLayouter = [KDQuotedLayouter layouterWithPropertyDic:dic];
            [layouter addSubLayouter:qutedLayouter];
            
            
            insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(5, 5, 10, 15));
            BOOL isMe = [[KDManagerContext globalManagerContext].userManager isCurrentUserId:status.replyUserId];
            NSString *quotedName = isMe?@"我":status.replyScreenName;
            NSString *qtxt = [NSString stringWithFormat:@"回复%@的回复: \"%@\"", quotedName, status.replyCommentText];
            
            NSAttributedString *quotedStr = [buildQuoteAttrStr(qtxt,14.0f) copy];
            dic = @{@"font": [UIFont systemFontOfSize:15],
                    @"textColor":[UIColor blackColor],
                    @"text":quotedStr,
                    @"insets":insets};
            [quotedStr release];
            
            KDLayouter *coreTextLayouter = [KDCoreTextLayouter layouterWithPropertyDic:dic];
            [qutedLayouter addSubLayouter:coreTextLayouter];

        }
        if (status.compositeImageSource) {
            insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(10,24, 15, 10));
            NSMutableDictionary *theDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [theDic setObject:status.compositeImageSource forKey:@"imageSource"];
            [theDic setObject:insets forKey:@"insets"];
            if (status.attachments) {
                [theDic setObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 268, 100)] forKey:@"bounds"];
            }
            
            KDLayouter *thumbnailLayouter = [KDThumbnailsLayouter layouterWithPropertyDic:theDic];
            [theDic release];
            [layouter addSubLayouter:thumbnailLayouter];
        }
        if (status.attachments) {
            insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(10,20, 15, 10));
            dic = @{@"dataSource": status,@"insets":insets};
            KDLayouter *documentLayouter = [KDDocumentListLayouter layouterWithPropertyDic:dic];
            [layouter addSubLayouter:documentLayouter];
        }
        NSString *metaStr = @"";
        if (status.status.groupId) {
            metaStr = [NSString stringWithFormat:@"%@  来自小组: %@",[status.status createdAtDateAsString], status.status.groupName];
        } else {
            metaStr = [NSString stringWithFormat:@"%@  来自%@", [status  createdAtDateAsString], status.source];
        }
        //(8, 10, 10, 10)
        insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(8, 10, 10, 10));
        dic = @{@"font": [UIFont systemFontOfSize:13],
                @"textColor":[UIColor grayColor],
                @"text":metaStr,
                @"insets":insets};
        KDLayouter *footerlayouter = [KDFooterLayoutr layouterWithPropertyDic:dic];
        [layouter addSubLayouter:footerlayouter];
        
    }
    
    return layouter;
}

@end

@implementation KDRepostStatusLayouter

+ (KDLayouter *)layouter:(KDStatus *)status constrainedWidth:(CGFloat)width {
    KDLayouter *layouter = [status propertyForKey:@"layouter"];
    if (layouter == nil) {
        NSString *insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 0, 10, 0));
        NSDictionary *dic = @{@"insets":insets};
        
        layouter = [KDRepostStatusLayouter layouterWithPropertyDic:dic];
        [status setProperty:layouter forKey:@"layouter"];
        layouter.constrainedWidth = width;
        
        
        insets =NSStringFromUIEdgeInsets(UIEdgeInsetsMake(8, 0, 5, 50)); 
        NSString *text = [status.author screenName];
        dic = @{@"font": [UIFont systemFontOfSize:15],
                              @"textColor":[UIColor blackColor],
                              @"text":text,
                              @"insets":insets};
        KDLayouter *nameLayouter = [KDHeaderLayouter layouterWithPropertyDic:dic];
        [layouter addSubLayouter:nameLayouter];
        
        
        insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(-10, 0, 10, 15));
        NSAttributedString *string =  [buildAttriString(status.text,NO,15.0f) copy];
        dic = @{@"font": [UIFont systemFontOfSize:15],
                @"textColor":[UIColor blackColor],
                @"text":string,
                @"insets":insets};
        [string release];
        KDLayouter *textLayouter = [KDCoreTextLayouter layouterWithPropertyDic:dic];
        [layouter addSubLayouter:textLayouter];
        
        
        NSString *metaStr = @"";
        metaStr = [NSString stringWithFormat:@"%@  来自%@",[status  createdAtDateAsString], status.source];
    
        insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(8, 10, 10, 10));
        dic = @{@"font": [UIFont systemFontOfSize:13],
                @"textColor":[UIColor grayColor],
                @"text":metaStr,
                @"insets":insets};
        KDLayouter *footerlayouter = [KDFooterLayoutr layouterWithPropertyDic:dic];
        [layouter addSubLayouter:footerlayouter];
        
    }
    
    return layouter;
}

@end

@implementation  KDDMMessageLayouter : KDLayouter
+ (KDLayouter *)layouter:(KDDMMessage *)message constrainedWidth:(CGFloat)width shouldDisplayTimeStamp:(BOOL)should {
    KDLayouter *layouter = [message propertyForKey:@"layouter"];
    if (layouter == nil) {
        NSString *insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 0, 10, 0));
        NSDictionary *dic = @{@"insets":insets};

        layouter = [KDDMMessageLayouter layouterWithPropertyDic:dic];
        [message setProperty:layouter forKey:@"layouter"];
        layouter.constrainedWidth = width;

        if (should) {
            insets =NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 0, 5, 0));
            NSString *string = [message formatedCreateAt];
            dic = @{@"font": [UIFont systemFontOfSize:14],
                    @"textColor":[UIColor grayColor],
                    @"text":string,
                    @"alignment":@(UITextAlignmentCenter),
                    @"insets":insets};
            KDLayouter *headLayouter = [KDHeaderLayouter layouterWithPropertyDic:dic];
            [layouter addSubLayouter:headLayouter];
            
        }
        
        insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 0, 15, 0));
        UIImage* image = [UIImage stretchableImageWithImageName:@"msgBg.png" leftCapWidth:50 topCapHeight:40];
        dic = @{@"backgroundImage":image,@"insets":insets};
        KDLayouter *quotedLayouter = [KDQuotedLayouter layouterWithPropertyDic:dic];
        [layouter addSubLayouter:quotedLayouter];
        
        insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(0, 12, 8, 0));
        NSAttributedString *string =  [buildAttriString(message.message,NO,14.0f) copy];
               dic = @{@"font": [UIFont systemFontOfSize:14],
                                      @"textColor":[UIColor blackColor],
                                       @"text":string,
                       @"insets":insets};
        [string release];
        KDLayouter *textLayouter = [KDCoreTextLayouter layouterWithPropertyDic:dic];
        [quotedLayouter addSubLayouter:textLayouter];
        
       
        if (message.compositeImageSource) {
            insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(10,24, 15, 10));
            NSMutableDictionary *theDic = [[NSMutableDictionary alloc] initWithCapacity:0];
            [theDic setObject:message.compositeImageSource forKey:@"imageSource"];
            [theDic setObject:insets forKey:@"insets"];
            if (message.attachments) {
                [theDic setObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 268, 100)] forKey:@"bounds"];
            }
          
            KDLayouter *thumbnailLayouter = [KDThumbnailsLayouter layouterWithPropertyDic:theDic];
            [theDic release];
            [quotedLayouter addSubLayouter:thumbnailLayouter];
        }
        if (message.attachments) {
            insets = NSStringFromUIEdgeInsets(UIEdgeInsetsMake(10,20, 15, 10));
            dic = @{@"dataSource": message,@"insets":insets};
            KDLayouter *documentLayouter = [KDDocumentListLayouter layouterWithPropertyDic:dic];
            [quotedLayouter addSubLayouter:documentLayouter];
        }

    }
    return layouter;
}
@end