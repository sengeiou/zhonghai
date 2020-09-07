//
//  KDLayouter.m
//  kdweibo
//
//  Created by Tan yingqi on 12-10-31.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDLayouter.h"
#import "KDManagerContext.h"
#import "KDExtendStatus.h"
#import "KDManagerContext.h"
#import "TwitterTextEntity.h"
#import "TwitterText.h"
#import "DTCoreText.h"
#import "UIImage+Additions.h"
#import "NSDate+Additions.h"
#import "KDThumbnailView2.h"
#import "KDDocumentIndicatorView.h"
//#import "KDDocumentListView.h"



NSAttributedString * buildAttriString(NSString *text, BOOL enable, CGFloat fontSize) {
    
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
    
    if (6.0 <= [[[UIDevice currentDevice] systemVersion] floatValue]) {
        NSMutableParagraphStyle *ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];// autorelease];
        ps.lineHeightMultiple = 1.8;
        
        ps.maximumLineHeight = ps.minimumLineHeight = (int)fontSize * ps.lineHeightMultiple;
        [attString addAttributes:[NSDictionary dictionaryWithObject:ps
                                                             forKey:NSParagraphStyleAttributeName]
                           range:NSMakeRange(0, attString.length)];
    }
    
    
    return attString;// autorelease];
}

NSAttributedString * buildQuoteAttrStr(NSString * text,CGFloat fontSize){
    NSString * markString = text;
    markString = [markString stringByReplacingOccurrencesOfString:@"<" withString:@"&#60"];
    markString = [markString stringByReplacingOccurrencesOfString:@">" withString:@"&#62"];
    markString = [markString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    NSString *ctnTpl = [NSString stringWithFormat:@"<p style=\"font-size:%dpx; font-family:sans-serif; line- height:1.5; color:#555; background-color:transparent;\">%@</p>",(int)fontSize,markString];
    
    NSData *data = [ctnTpl dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithHTMLData:data
                                                                          documentAttributes:nil] ;//autorelease];
    if (6.0 <= [[[UIDevice currentDevice] systemVersion] floatValue]) {
        NSMutableParagraphStyle *ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];// autorelease];
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
@synthesize constrainedWidth = constrainedWidth_;
@synthesize edgeInsets = edgeInsets_;
@synthesize data = data_;
- (id) init {
    self =[super init];
    if (self) {
        //
        self.frame = CGRectZero;
        self.bounds = CGRectZero;
        // self.defaultEdgeInsets = UIEdgeInsetsZero;
        //self.subLayouters = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}
- (NSMutableArray *)subLayouters {
    if (!subLayouters_) {
        subLayouters_ = [[NSMutableArray alloc] init];
    }
    return subLayouters_;
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
}

- (KDLayouter *)lastSubLayouter {
    KDLayouter *resut = nil;
    if (subLayouters_ && [subLayouters_ count] >0) {
        resut = [self.subLayouters lastObject];
    }
    return resut;
}

- (UIEdgeInsets)edgeInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(edgeInsets_, UIEdgeInsetsZero)) {
        edgeInsets_ = [self defaultEdgeInsets];
    }
    return edgeInsets_;
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsZero;
}

- (Class)viewClass {
    return Nil;
}

- (KDLayouterView *)view {
    KDLayouterView *view = nil;
    Class clazz = [self viewClass];
    if (clazz) {
        view = [[clazz alloc] init];// autorelease];
        view.backgroundColor = [UIColor kdBackgroundColor2];
        if (self.subLayouters) {
            KDLayouterView *subLayouterView = nil;
            for (KDLayouter *theLayouter in self.subLayouters) {
                subLayouterView = [theLayouter view];
                if (subLayouterView) {
                    [view addSubview:subLayouterView];
                    subLayouterView.layouter = theLayouter;
                    subLayouterView.backgroundColor =[UIColor kdBackgroundColor2];
                }
                
            }
        }
        
    }
    
    return view;
    
}

- (CGRect)frame {
    if (CGRectEqualToRect(CGRectZero, frame_)) {
        KDLayouter *pre = [self preLayouter];
        UIEdgeInsets inst = [self edgeInsets];
        CGFloat offX = inst.left;
        CGFloat offY = inst.top ;
        if (pre != nil) {
            CGRect preFrame = CGRectZero;
            preFrame = pre.frame;
            offY +=CGRectGetMaxY(preFrame)+[pre edgeInsets].bottom;
        }
        frame_ = CGRectOffset(self.bounds, offX, offY);
    }
    return frame_;
}

- (CGRect)bounds {
    if (CGRectEqualToRect(bounds_, CGRectZero)) {
        bounds_ = [self calculatedBounds];
    }
    return bounds_;
}

- (CGRect)calculatedBounds {
    CGRect rect = bounds_;
    if (subLayouters_ && [subLayouters_ count]>0) {
        KDLayouter *lastlayouter = self.lastSubLayouter;
        rect.size.height = CGRectGetMaxY(lastlayouter.frame)+[lastlayouter edgeInsets].bottom;
        // UIEdgeInsets insets = [self defaultEdgeInsets];
        rect.size.width =  self.constrainedWidth ;
    }
    return rect;
}

- (CGFloat)constrainedWidth {
    if (!isnormal(constrainedWidth_)) {
        UIEdgeInsets insets = [self edgeInsets];
        if (self.superLayouter) {
            constrainedWidth_ = [self.superLayouter constrainedWidth]-insets.left-insets.right;
        }
        
    }
    return constrainedWidth_;
}

- (void)setData:(id)data {
    data_ = data;
    [self update];
}

- (void)update {
    
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(subLayouters_);
    //[super dealloc];
}
@end


#pragma - mark KDCoreTextLayouter
@implementation KDCoreTextLayouter
@synthesize text = text_;
@synthesize fontSize = fontSize_;
@synthesize type = type_;

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize]];
    //只有一行时在ios7下不准确，所以将宽度改为 constrainedWidth
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(text_);
    //[super dealloc];
}

- (Class)viewClass {
    return [KDCoreTextLayouterView class];
}
@end


#pragma - mark KDLikedCoreTextLayouter
@implementation KDLikedCoreTextLayouter
@synthesize text = text_;
@synthesize fontSize = fontSize_;
@synthesize type = type_;

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize]];
    //只有一行时在ios7下不准确，所以将宽度改为 constrainedWidth
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(text_);
    //[super dealloc];
}

- (Class)viewClass {
    return [KDLikedCoreTextLayouterView class];
}
@end


#pragma - mark KDMicroCommentsCoreTextLayouter
@implementation KDMicroCommentsCoreTextLayouter
@synthesize text = text_;
@synthesize fontSize = fontSize_;
@synthesize type = type_;
@synthesize commentDic = commentDic_;

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize]];
    //只有一行时在ios7下不准确，所以将宽度改为 constrainedWidth
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(text_);
    //[super dealloc];
}

- (Class)viewClass {
    return [KDMicroCommentCoreTextLayouterView class];
}
@end


#pragma - mark KDMoreCoreTextLayouter
@implementation KDMoreCoreTextLayouter
@synthesize text = text_;
@synthesize fontSize = fontSize_;
@synthesize type = type_;

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize]];
    //只有一行时在ios7下不准确，所以将宽度改为 constrainedWidth
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(text_);
    //[super dealloc];
}

- (Class)viewClass {
    return [KDMoreCoreTextLayouterView class];
}
@end

#pragma - mark KDEmptyCoreTextLayouter
@implementation KDEmptyCoreTextLayouter
@synthesize text = text_;
@synthesize fontSize = fontSize_;
@synthesize type = type_;

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    rect.size = [KDStatusExpressionLabel sizeWithString:self.text constrainedToSize:CGSizeMake(self.constrainedWidth, CGFLOAT_MAX) withType:self.type textAlignment:NSTextAlignmentLeft textColor:nil textFont:[UIFont systemFontOfSize:self.fontSize]];
    //只有一行时在ios7下不准确，所以将宽度改为 constrainedWidth
    rect.size.width = self.constrainedWidth;
    return rect;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(text_);
    //[super dealloc];
}

- (Class)viewClass {
    return [KDEmptyCoreTextLayouterView class];
}
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma  mark -  KDThumbnailsLayouter
@implementation KDThumbnailsLayouter
@synthesize imageSource = imageSource_;

- (void)dealloc {
    //KD_RELEASE_SAFELY(imageSource_);
    //[super dealloc];
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    if (self.imageSource) {
        rect.size = [KDThumbnailView3 thumbnailSizeWithImageDataSource:self.imageSource showAll:YES];
    }
    return rect;
}

- (Class)viewClass {
    return [KDThumbnailsLayouterView class];
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 10, 0);
}

@end

@implementation  KDDocumentListLayouter : KDLayouter
@synthesize docs = docs_;

- (Class)viewClass {
    return [KDDocumentListLayouterView class];
}

- (CGRect)calculatedBounds {
    CGRect rect = CGRectZero;
    if (self.docs) {
        // rect.size = [KDThumbnailView2 thumbnailSizeWithImageDataSource:self.imageSource showAll:YES];
        rect.size = CGSizeMake( self.constrainedWidth, [KDDocumentIndicatorView heightForDocumentsCount:[self.docs count]]);
    }
    return rect;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(docs_);
    //[super dealloc];
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 10, 10);
}

@end

@implementation KDLocationLayouter
@synthesize address = address_;
@synthesize latitude = latitude_;
@synthesize longitude = longitude_;

- (CGRect)calculatedBounds {
    return CGRectMake(0, 0,self.constrainedWidth,26);
}

- (void)update {
    if (self.data) {
        KDStatus *status =self.data;
        address_ = [status.address copy];
        latitude_ = status.latitude;
        longitude_ = status.longitude;
    }
}

- (Class)viewClass {
    return [KDLocationLayouterView class];
}

- (UIEdgeInsets)defaultEdgeInsets {
    return UIEdgeInsetsMake(0, 10, 10, 10);
}

-(void)dealloc {
    //KD_RELEASE_SAFELY(address_);
    //[super dealloc];
}
@end


