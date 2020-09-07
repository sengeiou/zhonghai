//
//  KWIStatusContent.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 5/8/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWIStatusContent.h"

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+WebCache.h"
#import "NSString+URLEncode.h"

#import "NSDate+RelativeTime.h"
#import "NSObject+KWDataExt.h"
#import "UITextView+SizeUtils.h"
#import "UIDevice+KWIExt.h"

#import "KWIRemoteImage.h"
#import "KWIRemoteAlbum.h"
#import "EGOPhotoViewController.h"


#import "KWIRootVCtrl.h"

#import "KDTopic.h"
//#import "KWIFullImgVCtrl.h"
#import "KWIPeopleVCtrl.h"
#import "KWIWebVCtrl.h"
#import "KWITrendStreamVCtrl.h"
#import "KWIStatusContentThumbV.h"
#import "KWIStatusVCtrl.h"
#import "TwitterText.h"

#import "KDStatus.h"
#import "KDCommonHeader.h"
#import "KDCommentStatus.h"
#import "KDCommentMeStatus.h"
#import "KDDocumentListViewController.h"
#define MIDDLEPICHEIGHT  240.0f
#define THUMBNAIL_TOP_MARGIN   0
#define QUOTED_TEXT_LEFT_MAGIN 20
#define QUOTED_TEXT_TOP_MAGIN 20

#define META_TEXT_TOP_MARGIN 10
#define META_TEXT_HEIGTH  21
#define META_TEXT_BOTTOM_MARGIN 0

@interface KWIStatusContent () <DTAttributedTextContentViewDelegate, SDWebImageManagerDelegate,UIGestureRecognizerDelegate>

//@property (retain, nonatomic) IBOutlet UITextView *textV;

@property (retain, nonatomic) IBOutlet UIView *thumbCtnV;
@property (retain, nonatomic) IBOutlet UIView *imgCtn0V;
@property (retain, nonatomic) IBOutlet UIView *imgCtn1V;

@property (retain, nonatomic) IBOutlet KWIStatusContentThumbV *img0V;
@property (retain, nonatomic) IBOutlet KWIStatusContentThumbV *img1V;


@property (retain, nonatomic) IBOutlet UIView *quotedV;
@property (retain, nonatomic) IBOutlet UIView *qThumbCtnV;
@property (retain, nonatomic) IBOutlet UIView *qImgCtn0V;
@property (retain, nonatomic) IBOutlet UIView *qImgCtn1V;
@property (retain, nonatomic) IBOutlet KWIStatusContentThumbV *qImg0V;
@property (retain, nonatomic) IBOutlet KWIStatusContentThumbV *qImg1V;


@property (retain, nonatomic) IBOutlet UILabel *metaV;

@property (retain, nonatomic) IBOutlet UIImageView *sinaQuoteIco;

//@property (retain, nonatomic) KWIFullImgVCtrl *fullImgVCtrl;
@property (retain, nonatomic) NSMutableDictionary *imgMappings;

@property (nonatomic) NSUInteger contentFontSize;
@property (nonatomic, retain)KDCompositeImageSource *currentImageSource;

@end

@implementation KWIStatusContent
{
    IBOutlet UIView *_t1;
    IBOutlet UIView *_t2;
    IBOutlet UIView *_t3;
    
    IBOutlet DTAttributedTextContentView *_contentV;
    IBOutlet DTAttributedTextContentView *_quotedTextV;
    
    IBOutlet UIView *_sinaRTImgCtn;
    IBOutlet KWIStatusContentThumbV *_sinaRTImgV;
    
    
    IBOutlet UITableView *documentTableView1_;
    
    IBOutlet UITableView *documentTableView2_;
    
    IBOutlet KDDocumentListViewController *documentTableViewController1_;
   // NSMutableArray *_picInf;
    
    IBOutlet KDDocumentListViewController *documentTableViewController2_;
    
    BOOL _textInteractionEnabled;
}

//@synthesize textV = _textV;
@synthesize thumbCtnV = _thumbCtnV;
@synthesize imgCtn0V = _imgCtn0V;
@synthesize imgCtn1V = _imgCtn1V;
@synthesize img0V = _img0V;
@synthesize img1V = _img1V;

@synthesize quotedV = _quotedV;
//@synthesize quotedTextV = _quotedTextV;
@synthesize qThumbCtnV = _qThumbCtnV;
@synthesize qImgCtn0V = _qImgCtn0V;
@synthesize qImgCtn1V = _qImgCtn1V;

@synthesize qImg0V = _qImg0V;
@synthesize qImg1V = _qImg1V;


@synthesize metaV = _metaV;
@synthesize sinaQuoteIco = _sinaQuoteIco;

@synthesize status = _status;
@synthesize comment = _comment;
@synthesize commentMeStatus = _commentMeStatus;

//@synthesize fullImgVCtrl = _fullImgVCtrl;
@synthesize imgMappings = _imgMappings;

@synthesize contentFontSize = _contentFontSize;
@synthesize currentImageSource = currentImageSource_;

#pragma mark -
+ (KWIStatusContent *)viewForStatus:(KDStatus *)status frame:(CGRect)frame
{
    return [self viewForStatus:status frame:frame contentFontSize:16];
}

+ (KWIStatusContent *)viewForStatus:(KDStatus *)status frame:(CGRect)frame contentFontSize:(NSUInteger)contentFontSize
{
    return [self viewForStatus:status frame:frame contentFontSize:contentFontSize textInteractionEnabled:NO];
}

+ (KWIStatusContent *)viewForStatus:(KDStatus *)status frame:(CGRect)frame contentFontSize:(NSUInteger)contentFontSize textInteractionEnabled:(BOOL)textInteractionEnabled
{
    KWIStatusContent *view = [self view:frame contentFontSize:contentFontSize textInteractionEnabled:textInteractionEnabled];
    view.status = status;
    return view;
}

+ (KWIStatusContent *)viewForComment:(KDCommentStatus *)comment 
                               frame:(CGRect)frame
{
    return [self viewForComment:comment frame:frame contentFontSize:16];
}

+ (KWIStatusContent *)viewForComment:(KDCommentStatus *)comment 
                               frame:(CGRect)frame 
                     contentFontSize:(NSUInteger)contentFontSize
{
    return [self viewForComment:comment frame:frame contentFontSize:contentFontSize textInteractionEnabled:NO];
}

+ (KWIStatusContent *)viewForComment:(KDCommentStatus *)comment
                               frame:(CGRect)frame 
                     contentFontSize:(NSUInteger)contentFontSize 
              textInteractionEnabled:(BOOL)textInteractionEnabled
{
    KWIStatusContent *view = [self view:frame contentFontSize:contentFontSize textInteractionEnabled:textInteractionEnabled];
    view.comment = comment;
    return view;
}

+ (KWIStatusContent *)view:(CGRect)frame contentFontSize:(NSUInteger)contentFontSize textInteractionEnabled:(BOOL)textInteractionEnabled
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:self.description owner:nil options:nil];
    KWIStatusContent *view = (KWIStatusContent *)[nib objectAtIndex:2];
    
    [view initWithFrame:frame contentFontSize:contentFontSize textInteractionEnabled:textInteractionEnabled];
    
    return view;
}

+ (KWIStatusContent *)viewForCommentMeStatus:(KDCommentMeStatus *)commentMeStatus
                                       frame:(CGRect)frame{
    return [self viewForCommentMeStatus:commentMeStatus frame:frame contentFontSize:16];
}

+ (KWIStatusContent *)viewForCommentMeStatus:(KDCommentMeStatus *)commentMeStatus
                                       frame:(CGRect)frame
                             contentFontSize:(NSUInteger)contentFontSize{
   // KWIStatusContent *view = [self view:frame contentFontSize:contentFontSize textInteractionEnabled:NO];
    KWIStatusContent *view = [self viewForCommentMeStatus:commentMeStatus frame:frame contentFontSize:contentFontSize textInteractionEnabled:NO];
    return view;
}
+ (KWIStatusContent *)viewForCommentMeStatus:(KDCommentMeStatus *)commentMeStatus
                               frame:(CGRect)frame
                     contentFontSize:(NSUInteger)contentFontSize
              textInteractionEnabled:(BOOL)textInteractionEnabled {
    KWIStatusContent *view = [self view:frame contentFontSize:contentFontSize textInteractionEnabled:textInteractionEnabled];
    view.commentMeStatus = commentMeStatus;
    return view;
    
}


- (id)initWithFrame:(CGRect)frame contentFontSize:(NSUInteger)contentFontSize textInteractionEnabled:(BOOL)textInteractionEnabled
{   
    if (self) {
        self.frame = frame;
        self.imgMappings = [NSMutableDictionary dictionary];
        self.contentFontSize = contentFontSize;
        _textInteractionEnabled = textInteractionEnabled;
        if (textInteractionEnabled) {
            _contentV.userInteractionEnabled = YES;
            _contentV.shouldLayoutCustomSubviews = YES;
            _contentV.delegate = self;
        }
       // _picInf = [[NSMutableArray array] retain];
    }    
    return self;
}

- (void)dealloc
{
    //[_textV release];
    [_thumbCtnV release];
    [_img0V release];
    [_img1V release];
    [_quotedV release];
    [_quotedTextV release];
    [_metaV release];
    
    [_status release];
    [_comment release];
    [_commentMeStatus release];
    
    [_qThumbCtnV release];
    [_qImg0V release];
    [_qImg1V release];
    
//    [_fullImgVCtrl release];
    [_imgMappings release];
    
    [_imgCtn0V release];
    [_imgCtn1V release];
    [_qImgCtn0V release];
    [_qImgCtn1V release];
    
    [_sinaQuoteIco release];
    [_t1 release];
    [_t2 release];
    [_t3 release];
    [_contentV release];
    //[_picInf release];
    [_sinaRTImgCtn release];
    [_sinaRTImgV release];
    KD_RELEASE_SAFELY(currentImageSource_);
    [documentTableView1_ release];
    [documentTableView2_ release];
    [documentTableViewController1_ release];
    [documentTableViewController2_ release];
    [super dealloc];
}

//+(CGFloat )optimalHeightByConstrainedWidth:(CGFloat)width commentStatus:(KDCommentStatus *)comment {
//    CGFloat height = 0;
//    CGSize size = CGSizeZero;
//    if (comment.text.length >0) {
////             size = [comment.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(width,MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
//        
//        
//        NSAttributedString *string = [KWIStatusContent _buildContentAttrStr:comment textInteractionEnabled:NO];
//       CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)string);
//        size  = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL,                                                                        CGSizeMake(width, CGFLOAT_MAX),
//                                                                         NULL);
//       height+= size.height;
//        
//    }
//    if (comment.compositeImageSource) {
//        height+= 100;
//    }
//    if (comment.replyScreenName) {
//        //[self _configQuoteWithText:[NSString stringWithFormat:@"%@: %@", comment.in_reply_to_screen_name, comment.in_reply_to_comment_text]];
//        BOOL isMe = [[KDManagerContext globalManagerContext].userManager isCurrentUserId:comment.replyUserId];
//        NSString *quotedName = isMe?@"我":comment.replyScreenName;
//        NSString *qtxt = [NSString stringWithFormat:@"回复%@的回复: \"%@\"", quotedName, comment.replyCommentText];
//        
//        NSAttributedString *string = [KWIStatusContent _buildQuoteAttrStr:qtxt];
//        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)string);
//        size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL,                                                                        CGSizeMake(width-25, CGFLOAT_MAX),
//                                                                         NULL);
//        height+=size.height;
//        
////        size = [qtxt sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(width-2*QUOTED_TEXT_LEFT_MAGIN,MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
//       // height+=size.height;
//        height+=2*QUOTED_TEXT_LEFT_MAGIN;
//    }
//
//    height+=(META_TEXT_TOP_MARGIN+ META_TEXT_HEIGTH+META_TEXT_BOTTOM_MARGIN);
//    return height;
//}
#pragma mark -
- (void)setStatus:(KDStatus *)status
{
    [status retain];
    [_status release];
    _status = status;
    
    //[self _configText:status.text mentions:status.mentions];
    [self configTextView:status];
    
    // either pics or repost, never both
//    if (status.pictures && status.pictures.count) 
//    {
//        [self _configThumbs:status.pictures];
//    }
//    else if (status.retweeted_status) 
//    {
//        [self _configQuoteWithStatus:status.retweeted_status];
//    } else if ([self _hasSinaQuote]) {
//        [self _configSinaQuote:status];
//    }
    if (status.compositeImageSource) {
        //[self _configThumbs:<#(NSArray *)#>]
        [self _configThumbs:status.compositeImageSource];
    }
    else if (_status.forwardedStatus) {
        [self _configQuoteWithStatus:_status.forwardedStatus];
    }
    else if ([self _hasSinaQuote]) {
        [self _configSinaQuote:_status.extendStatus];
    }
    NSString *metaStr;
    if (_status.groupId) {
        metaStr = [NSString stringWithFormat:@"%@  来自小组: %@", 
                                             [_status createdAtDateAsString],
                                             _status.groupName];
    } else {
        metaStr = [NSString stringWithFormat:@"%@  来自%@",
                                             [_status createdAtDateAsString], 
                                             _status.source];
    }
    
    [self configDocumentTableView:_status documentTalbeViewController:documentTableViewController1_];

    [self _configMeta:metaStr];
    
    [self _adjustFrame:_status];
}

- (void)configDocumentTableView:(KDStatus * )status documentTalbeViewController:(KDDocumentListViewController*)vc{
        vc.documentDataSource = status;
}

- (void)_configText:(NSString *)str mentions:(NSDictionary *)array {
    
}


- (void)setComment:(KDCommentStatus *)comment
{
    [comment retain];
    [_comment release];
    _comment = comment;
    
    [self configTextView:comment];
    //暂时无图
//    if (_comment.compositeImageSource) {
//        [self _configThumbs:_comment.compositeImageSource];
//    }
    if (_comment.replyScreenName) {
        //[self _configQuoteWithText:[NSString stringWithFormat:@"%@: %@", comment.in_reply_to_screen_name, comment.in_reply_to_comment_text]];
        BOOL isMe = [[KDManagerContext globalManagerContext].userManager isCurrentUserId:_comment.replyUserId];
        NSString *quotedName = isMe?@"我":_comment.replyScreenName;
        NSString *qtxt = [NSString stringWithFormat:@"回复%@的回复: \"%@\"", quotedName, comment.replyCommentText];
        [self _configQuoteWithText:qtxt imageSource:nil];
    } 
    if (_comment.status.groupId) {
        [self _configMeta:[NSString stringWithFormat:@"%@  来自小组: %@",[_comment.status createdAtDateAsString], _comment.status.groupName]];
    } else {
        [self _configMeta:[NSString stringWithFormat:@"%@  来自%@", [_comment  createdAtDateAsString], comment.source]];
    }
    
    [self configDocumentTableView:_comment documentTalbeViewController:documentTableViewController1_];
    documentTableView1_.hidden = YES;
    documentTableView2_.hidden = YES;
    [self setNeedsLayout];
    //[self _adjustFrame:_comment];
}

- (void)setCommentMeStatus:(KDCommentMeStatus *)commentMeStatus {
    [commentMeStatus retain];
    [_commentMeStatus release];
    _commentMeStatus = commentMeStatus;

    [self configTextView:_commentMeStatus];
    
    if (commentMeStatus.compositeImageSource) {
        [self _configThumbs:commentMeStatus.compositeImageSource];
    }
    
    if (_commentMeStatus.status) {
        //[self _configQuoteWithStatus:comment.status];
        KDStatus *status = _commentMeStatus.status;
        BOOL isMe = [[KDManagerContext globalManagerContext].userManager isCurrentUserId:status.author.userId];
        NSString *quotedName = isMe?@"我":status.author.screenName;
        NSString *qtxt = [NSString stringWithFormat:@"回复%@的微博: \"%@\"", quotedName, status.text];
        // not comment
        [self _configQuoteWithText:qtxt imageSource:status.compositeImageSource];
        
    }

    if (_comment.status.groupId) {
        [self _configMeta:[NSString stringWithFormat:@"%@  来自小组: %@",[_commentMeStatus.status createdAtDateAsString], _commentMeStatus.status.groupName]];
    } else {
        [self _configMeta:[NSString stringWithFormat:@"%@  来自%@", [_commentMeStatus  createdAtDateAsString], _commentMeStatus.source]];
    }
    [self configDocumentTableView:_comment documentTalbeViewController:documentTableViewController1_];
    documentTableView1_.hidden = YES;
    documentTableView2_.hidden = YES;
    [self _adjustFrame:_commentMeStatus];
    
}
- (void)configTextView:(KDStatus *)status
{
   // _contentV.attributedString = [self _buildContentAttrStr:text mentions:mentions];

    _contentV.attributedString = [self _buildContentAttrStr:status textInteractionEnabled:_textInteractionEnabled];
 
    CGRect frame = _contentV.frame;
    frame.size = [_contentV suggestedFrameSizeToFitEntireStringConstraintedToWidth:CGRectGetWidth(frame)];
    _contentV.frame = frame;
}


- (NSAttributedString *)_buildContentAttrStr:(KDStatus *)status textInteractionEnabled:(BOOL)enable {
    NSString *markString = status.text;
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
    
    /*
        if(type_ == KDStatusContentDetailViewTypeForwarding) {
            markString = [NSString stringWithFormat:@"<a style=\"text-decoration:none; color:#198eb6;\" href=\"user:%@\">%@</a>: %@",
                          (status_.author.username) ? status_.author.username : @"",
                          (status_.author.screenName) ? status_.author.screenName : @"",
                          markString];
        }
        else if(KDStatusContentDetailViewTypeReply == type_) {
            if([status_ isKindOfClass:[KDCommentStatus class]] && [(KDCommentStatus *)status_ replyUserId]) {
                markString = [NSString stringWithFormat:@"回复<a style=\"text-decoration:none; color:#198eb6;\" href=\"user:%@\">@%@</a>: %@", [(KDCommentStatus *)status_ replyUserScreenName], [(KDCommentStatus *)status_ replyUserScreenName], markString];
            }
            
            if(status_.compositeImageSource && status_.compositeImageSource.imageSources.count) {
                markString = [markString stringByAppendingFormat:@" [%d图片]", status_.compositeImageSource.imageSources.count];
            }
            
            if([status_ hasAttachments]) {
                markString = [markString stringByAppendingFormat:@" [%d文档]", status_.attachments.count];
            }
        }
     */
    
    markString = [NSString stringWithFormat:@"<p style=\"font-size:%dpx; font-family:sans-serif; line-height:1.2;\">%@</p>",(int)self.contentFontSize, markString];
   
    
    NSData *data = [markString dataUsingEncoding:NSUTF8StringEncoding];
//    NSAttributedString *attString = [[NSAttributedString alloc] initWithHTMLData:html documentAttributes:NULL];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
    

//    NSData *data = [ctnStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithHTMLData:data
//                                                                           documentAttributes:nil] autorelease];
    if (6 <= [UIDevice curSysVer]) {
        NSMutableParagraphStyle *ps = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        ps.lineHeightMultiple = 1.8;
       ps.maximumLineHeight = ps.minimumLineHeight = (int)self.contentFontSize * ps.lineHeightMultiple;
        [attString addAttributes:[NSDictionary dictionaryWithObject:ps
                                                          forKey:NSParagraphStyleAttributeName]
                        range:NSMakeRange(0, attString.length)];
    }


    return [attString autorelease];
}

/*
- (void)_configThumbs:(NSArray *)pics
{
    for (NSDictionary *inf in pics) {
        [_picInf addObject:[[inf mutableCopy] autorelease]];
    }
    
    self.thumbCtnV.hidden = NO;
    
    if(_picInf && _picInf.count >0) {
        NSDictionary *picInfoDict = [_picInf objectAtIndex:0];
        NSURL *url = nil;
        
        if(_textInteractionEnabled) {
            url = [NSURL URLWithString:[picInfoDict objectForKey:@"bmiddle_pic"]];
            
            //修改图片的位置，及相关几层视图的frame的大小
            CGRect thumFrame = _thumbCtnV.frame;
            _thumbCtnV.frame = (CGRect){thumFrame.origin, {thumFrame.size.width, MIDDLEPICHEIGHT + 10.0f}};
            
            _img0V.frame = CGRectMake(0.0f, 0.0f, MIDDLEPICHEIGHT, MIDDLEPICHEIGHT);
            _img0V.superview.frame = _img0V.frame;
            
            if(_picInf.count > 1) {
                CGFloat origin_x = (thumFrame.size.width - 10.0f - MIDDLEPICHEIGHT - _img1V.frame.size.width) * 0.5f;
                _imgCtn0V.frame = CGRectMake(origin_x, 5.0f, MIDDLEPICHEIGHT, MIDDLEPICHEIGHT);
            }else {
                _imgCtn0V.frame = CGRectMake(0.0f, 0.0f, MIDDLEPICHEIGHT, MIDDLEPICHEIGHT);
                _imgCtn0V.center = CGPointMake(thumFrame.size.width * 0.5f, 5.0f + MIDDLEPICHEIGHT * 0.5f);
            }
            
            _imgCtn1V.frame = CGRectMake(_imgCtn0V.frame.origin.x + 10.0f + MIDDLEPICHEIGHT, _imgCtn0V.frame.origin.y + _imgCtn0V.frame.size.height - _img1V.frame.size.height, _img1V.frame.size.width, _img1V.frame.size.height);
        } else
            url = [NSURL URLWithString:[picInfoDict objectForKey:@"thumbnail_pic"]];
        
        
        [self.img0V setImageWithURL:url placeholderImage:[UIImage imageNamed:@"picture_PH.png"]];
        self.imgCtn0V.hidden = NO;
        
        UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleImageTapped:)] autorelease];
        [self.img0V addGestureRecognizer:tgr];
        
        UITapGestureRecognizer *tgr2 = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleImageTapped:)] autorelease];
        [self.img1V addGestureRecognizer:tgr2];
        
        self.imgCtn1V.hidden = (_picInf.count <= 1);
    }
}
*/
- (void)_configThumbs:(KDCompositeImageSource *)imageSource
{

    //KDCompositeImageSource *imageSource = _status.compositeImageSource;
    self.currentImageSource = imageSource;
    self.thumbCtnV.hidden = NO;
    NSURL *url = nil;
        if(_textInteractionEnabled) {
           // url = [NSURL URLWithString:[picInfoDict objectForKey:@"bmiddle_pic"]];
            url = [NSURL URLWithString:[imageSource firstMiddleURL]];
            
            //修改图片的位置，及相关几层视图的frame的大小
            CGRect thumFrame = _thumbCtnV.frame;
            _thumbCtnV.frame = (CGRect){thumFrame.origin, {thumFrame.size.width, MIDDLEPICHEIGHT + 10.0f}};
            
            _img0V.frame = CGRectMake(0.0f, 0.0f, MIDDLEPICHEIGHT, MIDDLEPICHEIGHT);
            _img0V.superview.frame = _img0V.frame;
            
            if([imageSource.imageSources count] > 1) {
                CGFloat origin_x = (thumFrame.size.width - 10.0f - MIDDLEPICHEIGHT - _img1V.frame.size.width) * 0.5f;
                _imgCtn0V.frame = CGRectMake(origin_x, 5.0f, MIDDLEPICHEIGHT, MIDDLEPICHEIGHT);
            }else {
                _imgCtn0V.frame = CGRectMake(0.0f, 0.0f, MIDDLEPICHEIGHT, MIDDLEPICHEIGHT);
                _imgCtn0V.center = CGPointMake(thumFrame.size.width * 0.5f, 5.0f + MIDDLEPICHEIGHT * 0.5f);
            }
            
            _imgCtn1V.frame = CGRectMake(_imgCtn0V.frame.origin.x + 10.0f + MIDDLEPICHEIGHT, _imgCtn0V.frame.origin.y + _imgCtn0V.frame.size.height - _img1V.frame.size.height, _img1V.frame.size.width, _img1V.frame.size.height);
        }
        else
            url = [NSURL URLWithString:[imageSource firstThumbnailURL]];
        
        [self.img0V setImageWithURL:url placeholderImage:[UIImage imageNamed:@"picture_PH.png"]];
        self.imgCtn0V.hidden = NO;
        
        UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleImageTapped:)] autorelease];
        [self.img0V addGestureRecognizer:tgr];
        
        UITapGestureRecognizer *tgr2 = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleImageTapped:)] autorelease];
        [self.img1V addGestureRecognizer:tgr2];
        
        self.imgCtn1V.hidden = ([imageSource.imageSources count] <= 1);
    }


- (void)_configQuoteWithStatus:(KDStatus *)status {
    UITapGestureRecognizer *grzr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onQuotedStatuesTapped:)] autorelease];
    grzr.delegate = self;
    [self.quotedV addGestureRecognizer:grzr];
    
     [self _configQuoteWithText:[NSString stringWithFormat:@"%@: %@", status.author.screenName, status.text] imageSource:status.compositeImageSource];
   //[self configDocumentTableView:status];
    [self configDocumentTableView:status documentTalbeViewController:documentTableViewController2_];
    CGRect frame = documentTableView2_.frame;
    if (status.attachments) {
        frame.size.height = [KDDocumentListViewController heightOfTableViewByStatus:status];
        CGFloat origntY = 0;
        origntY=CGRectGetMaxY(_quotedTextV.frame)+8;
        origntY=(_qThumbCtnV.hidden?origntY:CGRectGetMaxY(_qThumbCtnV.frame)+8);
        frame.origin.y = origntY;
        documentTableView2_.frame = frame;
        frame = _quotedV.frame;
        frame.size.height = CGRectGetMaxY(documentTableView2_.frame) +10;
        _quotedV.frame = frame;
    }else {
        frame.size.height =  0;
        documentTableView2_.frame = frame;
    }
  
    
}

- (void)_configQuoteWithText:(NSString *)text imageSource:(KDCompositeImageSource *)imageSource {
    self.quotedV.hidden = NO;
   CGRect txtFrm = _quotedTextV.frame;
    _quotedTextV.attributedString = [self _buildQuoteAttrStr:text];
//        [_quotedTextV initWithAttributedString:[self _buildQuoteAttrStr:text] width:CGRectGetWidth(txtFrm)];
   txtFrm.size = [_quotedTextV suggestedFrameSizeToFitEntireStringConstraintedToWidth:CGRectGetWidth(txtFrm)];
   _quotedTextV.frame = txtFrm;
    if (6 <= [UIDevice curSysVer]) {
        _quotedTextV.backgroundColor = [UIColor clearColor];
    }
    CGRect qFrm = self.quotedV.frame;
    qFrm.size.height = CGRectGetHeight(txtFrm) + 25;
    self.quotedV.frame = qFrm;

    if (imageSource) {
        [self _configQuotedThumbs:imageSource];
    }
}

- (NSAttributedString *)_buildQuoteAttrStr:(NSString *)text
{
    if (!text || 0 == text.length) {
        return nil;
    }
    NSString *markString = text;
    markString = [markString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    
    NSString *ctnTpl = [NSString stringWithFormat: @"<p style=\"font-size:%dpx; font-family:sans-serif; line-height:1.5; color:#555; background-color:transparent;\">%@</p>",(int)self.contentFontSize,markString];
   
    
    
    NSData *data = [ctnTpl dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithHTMLData:data
                                                                           documentAttributes:nil] autorelease];
    if (6 <= [UIDevice curSysVer]) {
        NSMutableParagraphStyle *ps = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        ps.lineHeightMultiple = 1.5;
        ps.maximumLineHeight = ps.minimumLineHeight = (int)self.contentFontSize * ps.lineHeightMultiple;
        [attrStr addAttributes:[NSDictionary dictionaryWithObject:ps
                                                           forKey:NSParagraphStyleAttributeName]
                         range:NSMakeRange(0, attrStr.length)];
   }
    return attrStr;
    
}

- (BOOL)_hasSinaQuote {


    return (_status.extendStatus != nil);
}


//新浪微博
- (void)_configSinaQuote:(KDExtendStatus *)status
{
    
    documentTableView1_.hidden = YES;
    documentTableView2_.hidden = YES;

    [self _configQuoteWithText:[NSString stringWithFormat:@"%@: %@", status.senderName,status.content] imageSource:status.compositeImageSource];
    self.sinaQuoteIco.hidden = NO;

    NSString *forwardedContent = [status forwardedContent];
    NSString *forwardedSenderName = [status forwardedSenderName];
    
    if (forwardedContent && forwardedContent.length) {
     
        UIView *hr = [[[UIView alloc] initWithFrame:CGRectMake(12, CGRectGetHeight(self.quotedV.frame) - 8, CGRectGetWidth(self.quotedV.frame) - 20, 1)] autorelease];
        hr.backgroundColor = [UIColor colorWithHTMLName:@"#ccc"];
        [self.quotedV addSubview:hr];
        
        CGRect sinaRTFrm = CGRectMake(12, CGRectGetHeight(self.quotedV.frame), CGRectGetWidth(self.quotedV.frame) - 20, 400);
        DTAttributedTextContentView *sinaRTTextV = [[[DTAttributedTextContentView alloc] initWithFrame:sinaRTFrm] autorelease];
        sinaRTTextV.backgroundColor = [UIColor clearColor];
        sinaRTTextV.opaque = YES;
        sinaRTTextV.attributedString = [self _buildQuoteAttrStr:[NSString stringWithFormat:@"<img src=\"%@\" />&nbsp;%@: %@", [[NSBundle mainBundle] URLForResource:@"sinaRTIco" withExtension:@"png"], forwardedSenderName, forwardedContent]];
        sinaRTFrm.size = [sinaRTTextV suggestedFrameSizeToFitEntireStringConstraintedToWidth:CGRectGetWidth(sinaRTFrm)];
        sinaRTFrm.size = CGSizeMake(sinaRTFrm.size.width, sinaRTFrm.size.height + 5.0f);
        sinaRTTextV.frame = sinaRTFrm;
        [self.quotedV addSubview:sinaRTTextV];
        
        CGRect quotedVFrm = self.quotedV.frame;
        quotedVFrm.size.height = CGRectGetMaxY(sinaRTFrm) + 10;
        self.quotedV.frame = quotedVFrm;
        
    }
}

- (void)_configQuotedThumbs:(KDCompositeImageSource *)imageSource{
    self.currentImageSource = imageSource;
    self.qThumbCtnV.hidden = NO;
    
    if([imageSource.imageSources count] >0) {
        NSURL *url = nil;
        if(_textInteractionEnabled) {
            url = [NSURL URLWithString:[imageSource firstMiddleURL ]];
            
            //config the frame
            CGFloat height = MIDDLEPICHEIGHT - 10;
            
            CGRect quotedThumbFrame = _qThumbCtnV.frame;
            _qThumbCtnV.frame = (CGRect){quotedThumbFrame.origin, {quotedThumbFrame.size.width, height}};
            
            _qImg0V.frame = CGRectMake(0.0f, 0.0f, height, height);
            _qImg0V.superview.frame = _qImg0V.frame;
            
            if([imageSource.imageSources count] > 1) {
                CGFloat origin_x = (_qThumbCtnV.frame.size.width - 10 - _qImgCtn1V.frame.size.width - height) * 0.5f;
                _qImgCtn0V.frame  = CGRectMake(origin_x, 0.0f, height, height);
            }else {
                _qImgCtn0V.frame = CGRectMake(0.0f, 0.0f, height, height);
                _qImgCtn0V.center = CGPointMake(quotedThumbFrame.size.width * 0.5f, height * 0.5f);
            }
            
            _qImgCtn1V.frame = CGRectMake(_qImgCtn0V.frame.origin.x + 10.0f +height, _qImgCtn0V.frame.origin.y + height - _qImg1V.frame.size.height, _qImg1V.frame.size.width, _qImg1V.frame.size.height);
        } else
            url = [NSURL URLWithString:[imageSource firstThumbnailURL]];
        
        [self.qImg0V setImageWithURL:url placeholderImage:[UIImage imageNamed:@"picture_PH.png"]];
        self.qImgCtn0V.hidden = NO;
        
        UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleImageTapped:)] autorelease];
        [self.qImg0V addGestureRecognizer:tgr];
        
        UITapGestureRecognizer *tgr2 = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleImageTapped:)] autorelease];
        [self.qImg1V addGestureRecognizer:tgr2];
        
        self.qImgCtn1V.hidden = ([imageSource.imageSources count] <= 1);
    }
    CGRect qtFrame = self.qThumbCtnV.frame;
    qtFrame.origin.y = CGRectGetMaxY(_quotedTextV.frame) + 15;
    self.qThumbCtnV.frame = qtFrame;
    
    CGRect qFrm = self.quotedV.frame;
    qFrm.size.height = CGRectGetMaxY(qtFrame) + 10;
    self.quotedV.frame = qFrm;
}

- (void)_configMeta:(NSString *)metastr
{
    self.metaV.text = metastr;
    [self.metaV sizeToFit];
}

- (void)_adjustFrame:(KDStatus *)status
{
 
    CGRect t1frm = _t1.frame;
    t1frm.origin.y = CGRectGetMaxY(_contentV.frame);
    
    CGRect table1Frame = documentTableView1_.frame;
    table1Frame.origin.y = self.thumbCtnV.hidden?0:CGRectGetMaxY(self.thumbCtnV.frame);
    if (_status.attachments) {
        table1Frame.size.height = [KDDocumentListViewController heightOfTableViewByStatus:_status];
    }else {
        table1Frame.size.height = 0;
    }
    
    documentTableView1_.frame = table1Frame;
    CGRect t2frm = _t2.frame;
    t2frm.origin.y = CGRectGetMaxY(table1Frame);
    //t2frm.origin.y = self.thumbCtnV.hidden?0:CGRectGetMaxY(self.thumbCtnV.frame);
    CGRect t3frm = _t3.frame;
    t3frm.origin.y = self.quotedV.hidden?0:CGRectGetMaxY(self.quotedV.frame);
    
    t2frm.size.height = CGRectGetMaxY(t3frm);
    
    t1frm.size.height = CGRectGetMaxY(t2frm);
    
    _t1.frame = t1frm;
    _t2.frame = t2frm;
    _t3.frame = t3frm;
    
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(t1frm);
    self.frame = frame;
}

#pragma mark -
- (void)_handleImageTapped:(UITapGestureRecognizer *)tgr{

    if (self.currentImageSource) {
        EGOPhotoViewController *fullImgVC = [[EGOPhotoViewController alloc] initwithCompositeImageDataSource:self.currentImageSource];
        UINavigationController *navVC = [[[UINavigationController alloc] initWithRootViewController:fullImgVC] autorelease];
        
        navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        
        KWIRootVCtrl *rootVC = [KWIRootVCtrl curInst];
        if ([rootVC respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [rootVC presentViewController:navVC animated:YES completion:nil];
        } else {
            [rootVC presentModalViewController:navVC animated:YES];
        }
        [fullImgVC release];
    }
 

   // [fullImgVC moveToPhotoAtIndex:idxTapped animated:NO];
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame {
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    linkButton.URL = url;
    linkButton.GUID = identifier;
    linkButton.minimumHitSize = CGSizeMake(25.0f, 25.0f);
    
    [linkButton addTarget:self action:@selector(linkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return [linkButton autorelease];
}

- (void)linkButtonClicked:(DTLinkButton *)sender {
    NSString *urlString = [sender.URL.absoluteString decodeFromURL];
    
    if([urlString hasPrefix:@"user:"]) {
        NSString *screenName = [urlString substringFromIndex:[@"user:" length]];
        KDUser *user = [[[KDUser alloc] init] autorelease];
        user.screenName = screenName;
        KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:user];
        NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
       
    } else if([urlString hasPrefix:@"topic:"]) {
        NSString *topicName = [urlString substringFromIndex:[@"topic:" length]];
        KDTopic *topic = [[[KDTopic alloc] init] autorelease];
        topic.name = topicName;
    
        KWITrendStreamVCtrl *vctrl = [KWITrendStreamVCtrl vctrlWithTopic:topic];
                NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWITrendStreamVCtrl.show" object:self userInfo:inf];

    } else if([urlString hasPrefix:@"url:"]) {
        NSString *urlStr = [urlString substringFromIndex:[@"url:" length]];
        NSURL *url = [NSURL URLWithString:urlStr];
       // KWIWebVCtrl *webvctrl = [KWIWebVCtrl vctrlWithUrl:url];
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIWebVCtrl.show" object:webvctrl];
            [UIApplication.sharedApplication openURL:url];
    }
}

//
//- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
//{
//    DTLinkButton *button = [[[DTLinkButton alloc] initWithFrame:frame] autorelease];
//	button.URL = url;
//	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
//	button.GUID = identifier;
//    
//	// use normal push action for opening URL
//	[button addTarget:self action:@selector(_linkBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
//    
//	return button;
//}
//
//- (void)_linkBtnTapped:(DTLinkButton *)button
//{
//    NSURL *url = button.URL;
//    if ([url.scheme isEqualToString:@"kwi"]) {
//        if ([@"people" isEqualToString:url.host]) {
//            KWUser *user = [[[KWUser alloc] init] autorelease];
//            user.id_ = [url.pathComponents lastObject];
//            KWIPeopleVCtrl *vctrl = [KWIPeopleVCtrl vctrlWithUser:user];
//            NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIPeopleVCtrl.show" object:self userInfo:inf];
//        } else if ([@"trend" isEqualToString:url.host]) {
//            KWTrend *trend = [[[KWTrend alloc] init] autorelease];
//            trend.full_name = [url.pathComponents lastObject];
//            trend.encoded_name = [trend.full_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            KWITrendStreamVCtrl *vctrl = [KWITrendStreamVCtrl vctrlWithTrend:trend];
//            NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", [self class], @"from", nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"KWITrendStreamVCtrl.show" object:self userInfo:inf];
//        }
//    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"] || !url.scheme) {
//        //KWIWebVCtrl *webvctrl = [KWIWebVCtrl vctrlWithUrl:url];
//        //[[NSNotificationCenter defaultCenter] postNotificationName:@"KWIWebVCtrl.show" object:webvctrl];
//        [UIApplication.sharedApplication openURL:url];
//    }
//}

- (void)_onQuotedStatuesTapped:(UITapGestureRecognizer *)tgr
{
    KWIStatusVCtrl *vctrl = [KWIStatusVCtrl vctrlWithStatus:self.status.forwardedStatus];
    NSDictionary *inf = [NSDictionary dictionaryWithObjectsAndKeys:vctrl, @"vctrl", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KWIStatusContent.retweetedStatusTapped" object:self userInfo:inf]; 
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceive = YES;
    UIView *view = gestureRecognizer.view;
    if (view == self.quotedV ) {
        CGRect frame = documentTableView2_.frame;
        if ( CGRectContainsPoint(frame, [touch locationInView:view])) {
            shouldReceive = NO;
        }
    }
    return shouldReceive;
}
@end
