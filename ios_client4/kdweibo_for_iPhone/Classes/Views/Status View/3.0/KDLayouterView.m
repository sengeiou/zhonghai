//
//  KDLayouterView.m
//  kdweibo
//
//  Created by Tan yingqi on 13-11-26.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDLayouterView.h"
#import "KDLayouter.h"
#import "KDDefaultViewControllerContext.h"
#import "KDTopic.h"
#import "TrendStatusViewController.h"
#import "KDWeiboAppDelegate.h"

@implementation KDLayouterView
@synthesize layouter = layouter_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setLayouter:(KDLayouter *)layouter {
    if (layouter_ != layouter) {
        //        [layouter_ release];
        layouter_ = layouter ;//retain];
    }
    [self updateContent];
}

- (void)updateContent {
    self.frame = layouter_.frame;
    [self setNeedsLayout];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(layouter_);
    //[super dealloc];
}
@end

@interface KDCoreTextLayouterView()<KDExpressionLabelDelegate>

@end
@implementation KDCoreTextLayouterView
@synthesize textView = textView_;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    if (layouter_) {
        KDCoreTextLayouter *layouter = (KDCoreTextLayouter *)layouter_;
        textView_.text = layouter.text;
        textView_.frame = self.bounds;
        textView_.delegate = self;
        [super updateContent];
    }
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickUserWithName:(NSString *)userName {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewControllerByName:userName sender:self];
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickTopicWithName:(NSString *)topicName {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showTopicViewControllerByName:topicName andStatue:layouter_.data sender:self];
}

- (void)expressionLabel:(KDExpressionLabel *)label didClickUrl:(NSString *)urlString {
    //[[KDWeiboAppDelegate getAppDelegate] openWebView:urlString];
    [[KDDefaultViewControllerContext defaultViewControllerContext] showWebViewControllerByUrl:urlString sender:self];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(textView_);
    //[super dealloc];
}

@end


@interface KDLikedCoreTextLayouterView()

@end
@implementation KDLikedCoreTextLayouterView
@synthesize likedLabel = likedLabel_;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    if (layouter_) {
        KDLikedCoreTextLayouter *layouter = (KDLikedCoreTextLayouter *)layouter_;
        
        NSMutableAttributedString *allAttrStr = [[NSMutableAttributedString alloc] init];
        
        //创建带有图片的富文本
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = [UIImage imageNamed:@"icon_praise"];
        attch.bounds = CGRectMake(0, 0, 15, 15);
        NSAttributedString *imgString = [NSAttributedString attributedStringWithAttachment:attch];
        
        NSAttributedString *emptyString = [[NSAttributedString alloc] initWithString:@" "];
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:layouter.text];
        NSRange range = NSMakeRange(0, attrStr.length-5);
        [attrStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x586c94) range:range];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:layouter.fontSize] range:NSMakeRange(0, attrStr.length)];
        
        [allAttrStr appendAttributedString:imgString];
        [allAttrStr appendAttributedString:emptyString];
        [allAttrStr appendAttributedString:attrStr];
        
        likedLabel_.attributedText = allAttrStr;
        likedLabel_.frame = self.bounds;
        [super updateContent];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(textView_);
    //[super dealloc];
}

@end



@interface KDMicroCommentCoreTextLayouterView()

@end
@implementation KDMicroCommentCoreTextLayouterView
@synthesize microCommentLabel = microCommentLabel_;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    if (layouter_) {
        KDMicroCommentsCoreTextLayouter *layouter = (KDMicroCommentsCoreTextLayouter *)layouter_;
        NSDictionary *commentDic = (NSDictionary *)layouter.commentDic;
        
        NSMutableAttributedString *allAttrStr = [[NSMutableAttributedString alloc] init];
        NSDictionary *colorDic = @{NSForegroundColorAttributeName:UIColorFromRGB(0x586c94)};
        
        
        NSAttributedString *nameAttr = [[NSAttributedString alloc] initWithString:[[commentDic objectForKey:@"user"] objectForKey:@"name"] attributes:colorDic];
        
        NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] init];
        NSMutableArray *contentArray = [NSMutableArray array];
        [self getMessageRange:[NSString stringWithFormat:@": %@", [commentDic objectForKey:@"text"]] array:contentArray];
        for (NSString *obj in contentArray) {
            if ([obj hasSuffix:@"]"] && [obj hasPrefix:@"["]) {
                if ([[KDExpressionCode allCodeString] containsObject:obj]) {
                    //如果是表情
                    NSTextAttachment *imageStr = [[NSTextAttachment alloc] init];
                    imageStr.image = [UIImage imageNamed:[KDExpressionCode  codeStringToImageName:obj]];
                    CGFloat height = microCommentLabel_.font.lineHeight;
                    imageStr.bounds = CGRectMake(0, -3, height, height);
                    NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:imageStr];
                    [textAttr appendAttributedString:imageAttr];
                } else {
                    [textAttr appendAttributedString:[[NSAttributedString alloc] initWithString:obj]];
                }
            } else {
                [textAttr appendAttributedString:[[NSAttributedString alloc] initWithString:obj]];
            }
        }
        
        
        if ([[commentDic objectForKey:@"in_reply_to_screen_name"] isEqual:[NSNull null]]) {
            [allAttrStr appendAttributedString:nameAttr];
            [allAttrStr appendAttributedString:textAttr];
        }else {
            NSAttributedString *replyAttr = [[NSAttributedString alloc] initWithString:@" 回复 "];
            NSAttributedString *replyNameAttr = [[NSAttributedString alloc] initWithString:[commentDic objectForKey:@"in_reply_to_screen_name"] attributes:colorDic];
            [allAttrStr appendAttributedString:nameAttr];
            [allAttrStr appendAttributedString:replyAttr];
            [allAttrStr appendAttributedString:replyNameAttr];
            [allAttrStr appendAttributedString:textAttr];
        }
        
        [allAttrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:layouter.fontSize] range:NSMakeRange(0, allAttrStr.length)];
        
        
        
        microCommentLabel_.attributedText = allAttrStr;
        microCommentLabel_.frame = self.bounds;
        [super updateContent];
    }
}

//分析一个字符串中哪些是文字，哪些是表情然后加入一个数组中待用
- (void)getMessageRange:(NSString *)message array:(NSMutableArray *)array {
    NSRange range = [message rangeOfString:@"["];
    NSRange range1 = [message rangeOfString:@"]"];
    if (range.length>0 && range1.length>0) {
        if (range.location>0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str = [message substringFromIndex:range1.location+1];
            [self getMessageRange:str array:array];
        } else {
            NSString *nextstr = [message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str = [message substringFromIndex:range1.location+1];
                [self getMessageRange:str array:array];
            } else {
                return;
            }
        }
    } else if (message != nil){
        [array addObject:message];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(textView_);
    //[super dealloc];
}

@end


@interface KDMoreCoreTextLayouterView()

@end
@implementation KDMoreCoreTextLayouterView
@synthesize moreLabel = moreLabel_;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    if (layouter_) {
        KDMoreCoreTextLayouter *layouter = (KDMoreCoreTextLayouter *)layouter_;
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:layouter.text];
        NSRange range = NSMakeRange(0, attrStr.length);
        [attrStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x586c94) range:range];
        
        moreLabel_.attributedText = attrStr;
        moreLabel_.frame = self.bounds;
        [super updateContent];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(textView_);
    //[super dealloc];
}

@end


@interface KDEmptyCoreTextLayouterView()

@end
@implementation KDEmptyCoreTextLayouterView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateContent {
    if (layouter_) {
        [super updateContent];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(textView_);
    //[super dealloc];
}

@end


@interface KDThumbnailsLayouterView()<KDThumbnailViewDelegate3>
@end

@implementation KDThumbnailsLayouterView

@synthesize thumbnailView = thumbnailView_;

- (void)updateContent {
    if (layouter_) {
        thumbnailView_ = [KDThumbnailView3 thumbnailViewWithStatus:layouter_.data];// retain];
        thumbnailView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:thumbnailView_];
        thumbnailView_.delegate = self;
        [super updateContent];
    }
}

- (void)didTapOnThumbnailView:(KDThumbnailView2 *)thumbnailView userInfo:(id)userInfo {
    NSUInteger index = 0;
    NSArray *imageViews = nil;
    if ([userInfo isKindOfClass:[NSArray class]]) {
        //
        if (((NSArray *)userInfo).count >1) {
            index  = [[((NSArray *)userInfo) objectAtIndex:0] intValue];
            imageViews = [((NSArray *)userInfo) objectAtIndex:1];
        }
    }
    
    KDCompositeImageSource *imageSource = ((KDThumbnailsLayouter *)layouter_).imageSource;
    NSArray *attachemtns = [imageSource propertyForKey:@"attachments"];
    if (attachemtns)
        [[KDDefaultViewControllerContext defaultViewControllerContext] showImagesOrVideos:((KDThumbnailsLayouter *)layouter_).imageSource startIndex:index sender:self];
    else
        [[KDDefaultViewControllerContext defaultViewControllerContext] showImages:((KDThumbnailsLayouter *)layouter_).imageSource startIndex:index srcImageViews:imageViews window:self.window];
}

- (void)loadThumbailsImage {
    if(layouter_ ){
        [thumbnailView_ setLoadThumbnail:YES];
    }
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(thumbnailView_);
    //[super dealloc];
}
@end

@interface KDDocumentListLayouterView ()<KDDocumentIndicatorViewDelegate>

@end

@implementation KDDocumentListLayouterView
@synthesize docListView  = docListView_;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        docListView_ = [[KDDocumentIndicatorView alloc] initWithFrame:frame];
        docListView_.delegate = self;
        [self addSubview:docListView_];
        docListView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)documentIndicatorView:(KDDocumentIndicatorView *)div didClickedAtAttachment:(KDAttachment *)attachment {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showProgressModalViewController:attachment inStatus:layouter_.data sender:self];
}

- (void)didClickMoreInDocumentIndicatorView:(KDDocumentIndicatorView *)div {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showAttachmentViewController:layouter_.data sender:self];
}

- (void)updateContent {
    if (layouter_) {
        [docListView_ setDocuments:((KDDocumentListLayouter *)layouter_).docs];
        [super updateContent];
    }
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(docListView_);
    //[super dealloc];
}

@end

@implementation KDLocationLayouterView
@synthesize locationView = locationView_;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        locationView_ = [[KDLocationView alloc] initWithFrame:frame];
        [self addSubview:locationView_];
        UITapGestureRecognizer *rgzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationViewTapped:)];
        [locationView_ addGestureRecognizer:rgzr];
        //        [rgzr release];
        locationView_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)locationViewTapped:(UIGestureRecognizer *)rgzr {
    UIView *view = rgzr.view;
    [[KDDefaultViewControllerContext defaultViewControllerContext] showMapViewController:layouter_ sender:view];
}

- (void)updateContent {
    if (layouter_) {
        [locationView_ setAddrText:((KDLocationLayouter *)layouter_).address];
        [super updateContent];
    }
    
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(locationView_);
    //[super dealloc];
}

@end

