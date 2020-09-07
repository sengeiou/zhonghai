//
//  KDStatusBodyView.m
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusBodyView.h"
#import "KDThumbnailView.h"

#import "KDUser.h"
#import "KDUtility.h"
#import "KDVoteViewController.h"
#import "KDDefaultViewControllerContext.h"
#import "KDProgressModalViewController.h"
#import "KDAttachmentViewController.h"

//#import "UILabel+ExpressionDisplay.h"

#define KD_STATUS_BODY_CONTENT_SPACING                      5.0
#define KD_STATUS_BODY_FORWARD_CONTENT_DIVIDER_SPACING      3.0




#define KD_EXTRA_MESSAGE_TYPE_VOTE           1706
#define KD_EXTRA_MESSAGE_TYPE_BULLETIN       1707
#define KD_EXTRA_MESSAGE_TYPE_FRESHMAN       1708
#define KD_EXTRA_MESSAGE_TYPE_MISSION        1709

#define KD_TEXT_LABEL_FONT_SIZE              16.0f
#define KD_FORWARD_LABEL_FONT_SIZE           15.0f

static UIEdgeInsets kKDStatusBodyContentEdgeInsets = {10.0, 10.0, 10.0, 10.0};

//@interface KDStatusFromGroupTipView : UIView
//{
//    UILabel     *groupNameLabel_;
//    UIImageView *lock_;
//    UIImageView *background_;
//}
//
//@end
//
//@implementation KDStatusFromGroupTipView
//
//- (id)initWithGroupName:(NSString *)groupName {
//    self = [super initWithFrame:CGRectZero];
//    if(self) {
//        [self setupViewWithGroupName:groupName];
//    }
//    
//    return self;
//}
//
//- (void)dealloc {
//    //KD_RELEASE_SAFELY(groupNameLabel_);
//    //KD_RELEASE_SAFELY(lock_);
//    //KD_RELEASE_SAFELY(background_);
//    
//    //[super dealloc];
//}
//
//- (void)setupViewWithGroupName:(NSString *)groupName {
//    UIImage *bgImage = [UIImage imageNamed:@"status_from_group_bg.png"];
//    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5f topCapHeight:bgImage.size.height * 0.5f];
//    background_ = [[UIImageView alloc] initWithImage:bgImage];
//    [self addSubview:background_];
//    
//    groupNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
//    groupNameLabel_.text = groupName;
//    groupNameLabel_.backgroundColor = [UIColor clearColor];
//    groupNameLabel_.font = [UIFont systemFontOfSize:13.0f];
//    [groupNameLabel_ sizeToFit];
//    [self addSubview:groupNameLabel_];
//    
//    lock_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_from_group_lock.png"]];
//    [self addSubview:lock_];
//    
//    self.bounds = CGRectMake(0.0f, 0.0f, groupNameLabel_.bounds.size.width + 54.0f, 21.0f);
//    background_.frame = self.bounds;
//    groupNameLabel_.frame = CGRectMake(27.0f, 2.0f, groupNameLabel_.bounds.size.width, 17.0f);
//    lock_.frame = CGRectMake(CGRectGetMaxX(groupNameLabel_.frame) + (27 - lock_.image.size.width) * 0.5f, (21 - lock_.image.size.height) * 0.5f, lock_.image.size.width, lock_.image.size.height);
//}
//
//@end

@interface KDStatusBodyView ()

@property(nonatomic, retain) UIImageView *backgroundView;

@property(nonatomic, retain) KDExpressionLabel *textLabel;
@property(nonatomic, retain) KDExpressionLabel *forwardTextLabel;
@property(nonatomic, retain) UIImageView *dividerView;

@property(nonatomic, retain) KDStatusBodyView *extraContentView;
@property(nonatomic, retain) KDThumbnailView2 *thumbnailView;
@property(nonatomic, retain) UIView *extraMessageTypeView;
@property(nonatomic, retain) KDLocationView *locationVeiw;
@property(nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property(nonatomic, retain) KDDocumentIndicatorView *documentIndicatorView;

@end


@implementation KDStatusBodyView

@dynamic status;
@synthesize thumbnailDelegate=thumbnailDelegate_;
@synthesize style=style_;
@synthesize position = position_;

@synthesize backgroundView=backgroundView_;

@synthesize textLabel=textLabel_;
@synthesize forwardTextLabel=forwardTextLabel_;
@synthesize dividerView=dividerView_;

@synthesize extraContentView=extraContentView_;
@synthesize thumbnailView=thumbnailView_;
@synthesize extraMessageTypeView=extraMessageTypeView_;

@synthesize contentEdgeInsets=contentEdgeInsets_;
@synthesize locationVeiw = locationView_;

@synthesize documentIndicatorView = documentIndicatorView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        contentEdgeInsets_  = UIEdgeInsetsZero;
        style_ = KDStatusBodyViewDisplayStyleNone;
        
        self.autoresizesSubviews = YES;
        [self setupBodyView];
    }
    
    return self;
}

- (void)setupBodyView {
    // text label
    textLabel_ = [[KDExpressionLabel alloc] initWithFrame:CGRectZero andType:KDExpressionLabelType_Expression urlRespondFucIfNeed:NULL];
    textLabel_.backgroundColor = [UIColor clearColor];
    textLabel_.textColor = UIColorFromRGB(0x1c232a);
    textLabel_.font = [UIFont systemFontOfSize:KD_TEXT_LABEL_FONT_SIZE];
    
    [self addSubview:textLabel_];
    
    // forward text label
    forwardTextLabel_ = [[KDExpressionLabel alloc] initWithFrame:CGRectZero andType:KDExpressionLabelType_Expression urlRespondFucIfNeed:NULL];
    forwardTextLabel_.backgroundColor = [UIColor clearColor];
    forwardTextLabel_.textColor = UIColorFromRGB(0x1c232a);
    forwardTextLabel_.font = [UIFont systemFontOfSize:KD_FORWARD_LABEL_FONT_SIZE];
    
    [self addSubview:forwardTextLabel_];
    
    // divider view
    //dividerView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_separator.png"]];
    
    dividerView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_page_cell_separator_bg"]];
    [dividerView_ sizeToFit];
    dividerView_.hidden = YES;
    [self addSubview:dividerView_];
    
    locationView_ = [[KDLocationView alloc] initWithFrame:CGRectZero];
    [self addSubview:locationView_];
    locationView_.hidden = YES;
    UITapGestureRecognizer *rgnzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationViewTapped:)];
    [locationView_ addGestureRecognizer:rgnzr];
//    [rgnzr release];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect stageRect = self.bounds;
    
    CGFloat x = stageRect.origin.x + contentEdgeInsets_.left; // offset x
    CGFloat y = stageRect.origin.y + contentEdgeInsets_.top; // offset y
    CGFloat width = stageRect.size.width - (contentEdgeInsets_.left + contentEdgeInsets_.right); // width
    CGFloat height = stageRect.size.height - (contentEdgeInsets_.top + contentEdgeInsets_.bottom); // height
    
    CGFloat offsetX = x;
    CGFloat offsetY = y;
    CGRect rect = CGRectZero;
    
    //from group tip
    if(groupTipView) {
        groupTipView.frame = CGRectMake(offsetX, offsetY, groupTipView.bounds.size.width, groupTipView.bounds.size.height);
        offsetY += groupTipView.frame.size.height;
        
        //spacing
        offsetY += 12.0f;
    }
    
    // text label
    rect = textLabel_.bounds;
    rect.origin = CGPointMake(offsetX, offsetY);
    textLabel_.frame = rect;
    
    offsetY += rect.size.height;
    
    // background view
    if (backgroundView_ != nil && !backgroundView_.hidden) {
        backgroundView_.frame = stageRect;
    }
    
    // divider image view
    if (!dividerView_.hidden) {
//        rect = dividerView_.bounds;
        rect = CGRectMake(offsetX, offsetY, width, 0.5);
        dividerView_.frame = rect;
        
        offsetY += rect.size.height + KD_STATUS_BODY_FORWARD_CONTENT_DIVIDER_SPACING;
    }
    
    // forward weibo text label
    if (!forwardTextLabel_.hidden) {
        rect = forwardTextLabel_.bounds;
        rect.origin = CGPointMake(offsetX, offsetY);
        forwardTextLabel_.frame = rect;
        
        offsetY += rect.size.height;
    }
    
    BOOL hasThumbnail = thumbnailView_ != nil && !thumbnailView_.hidden;
    BOOL hasExtraMessage = extraMessageTypeView_ != nil && !extraMessageTypeView_.hidden;
    
    CGFloat bottomDistance = 0.0;
 
    if (hasExtraMessage) {
        // the default status extra message type placeholder height
        bottomDistance += [KDStatusBodyView defaultStatusExtraMessageTypeHeight] + KD_STATUS_BODY_CONTENT_SPACING;
    }
    
    // extra content view
    if (extraContentView_ != nil && !extraContentView_.hidden) {
        offsetY += KD_STATUS_BODY_CONTENT_SPACING; // content spacing
        
        rect = CGRectMake(x, offsetY, width, height - offsetY - bottomDistance);
        extraContentView_.frame = rect;
        
        // offsetY += rect.size.height;
    }
    
    // extra type badge view
    if (hasExtraMessage) {
        rect = extraMessageTypeView_.bounds;
        rect.origin = CGPointMake(x, CGRectGetMaxY(textLabel_.frame) + KD_STATUS_BODY_CONTENT_SPACING);
        extraMessageTypeView_.frame = rect;
        
        offsetY += extraMessageTypeView_.frame.size.height;
    }
    
    // thumbnail view
    if (hasThumbnail) {
        offsetY +=KD_STATUS_BODY_CONTENT_SPACING;
        rect = thumbnailView_.bounds;
        rect.origin = CGPointMake(x, offsetY);
        thumbnailView_.frame = rect;
        
        offsetY +=(rect.size.height + KD_STATUS_BODY_CONTENT_SPACING);
    }
    
    if (locationView_ && !locationView_.hidden) {
        rect.size.width = width;
        rect.size.height = 27;
        rect.origin.x = offsetX;
        rect.origin.y = offsetY;
        locationView_.frame = rect;
        offsetY += rect.size.height;
    }
    
    if(documentIndicatorView_ && !documentIndicatorView_.hidden) {
        documentIndicatorView_.frame = CGRectMake(0.0f, offsetY + 5.0f, self.frame.size.width, [KDDocumentIndicatorView heightForDocumentsCount:documentIndicatorView_.documents.count]);
    }
}

- (void)setupBackgroundView:(UIImage *)image {
    BOOL visible = image != nil;
    if (image != nil) {
        if (backgroundView_ == nil) {
            backgroundView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self insertSubview:backgroundView_ atIndex:0x00];
        }
        
        backgroundView_.image = image;
    }
    
    backgroundView_.hidden = !visible;
}

- (void)setupThumbnailView:(id<KDImageDataSource>)imageDataSource visibility:(BOOL)visibility delegate:(id<KDThumbnailViewDelegate2>)delegate {
    if (visibility) {
        if (thumbnailView_ == nil) {
            thumbnailView_ = [KDThumbnailView2 thumbnailViewWithStatus:status_];// retain];
            thumbnailView_.delegate = delegate;
            [thumbnailView_ addTarget:self action:@selector(didTapOnThumbnailView:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:thumbnailView_];
        }
        
        thumbnailView_.imageDataSource = imageDataSource;
        
        // The specificed image height will be return, So ignore the image data source is okay.
        CGSize size = [KDThumbnailView2 thumbnailSizeWithImageDataSource:imageDataSource showAll:YES];
        thumbnailView_.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    }
    
    if (thumbnailView_ != nil) {
        thumbnailView_.hidden = !visibility;
    }
}
- (void)setupThumbnailView:(id<KDImageDataSource>)imageDataSource status:(KDStatus *)status visibility:(BOOL)visibility delegate:(id<KDThumbnailViewDelegate2>)delegate {
    if (visibility) {
        if (thumbnailView_ == nil) {
            thumbnailView_ = [KDThumbnailView2 thumbnailViewWithStatus:status];// retain];
            thumbnailView_.delegate = delegate;
            [thumbnailView_ addTarget:self action:@selector(didTapOnThumbnailView:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:thumbnailView_];
        }
        
        thumbnailView_.imageDataSource = imageDataSource;
        
        // The specificed image height will be return, So ignore the image data source is okay.
        CGSize size = [KDThumbnailView2 thumbnailSizeWithImageDataSource:imageDataSource showAll:YES];
        thumbnailView_.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    }
    
    if (thumbnailView_ != nil) {
        thumbnailView_.hidden = !visibility;
    }
}
- (void)setupExtraMessageTypeView:(UIImage *)image target:(id)target extraMessageType:(NSInteger)type{
    BOOL visible = image != nil;
    if (image != nil) {
        if (extraMessageTypeView_ == nil) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
            [btn addTarget:target action:@selector(didTapOnExtraBadgeView:) forControlEvents:UIControlEventTouchUpInside];
            
            extraMessageTypeView_ = btn;
            [self addSubview:extraMessageTypeView_];
        }
        
        [(UIButton *)extraMessageTypeView_ setImage:image forState:UIControlStateNormal];
        [(UIButton *)extraMessageTypeView_ setTag:type];
        [extraMessageTypeView_ sizeToFit];
    }
    
    extraMessageTypeView_.hidden = !visible;
}

// assign the values from object to another
- (void)_updateAttributes:(KDStatusBodyView *)toBodyView fromExtraContentView:(KDStatusBodyView *)fromBodyView {
    toBodyView.thumbnailDelegate = fromBodyView.thumbnailDelegate;
}

- (void)setExtraContentViewVisibility:(BOOL)visibility parentView:(KDStatusBodyView *)pv atLayer:(NSInteger)layer {
    if (visibility && pv.extraContentView == nil) {
        KDStatusBodyView *bodyView = [[KDStatusBodyView alloc] initWithFrame:CGRectZero];
        pv.extraContentView = bodyView;
//        [bodyView release];
        
        pv.extraContentView.textLabel.font = [UIFont systemFontOfSize:15.0];
        pv.extraContentView.contentEdgeInsets = kKDStatusBodyContentEdgeInsets;
        
        [self _updateAttributes:pv.extraContentView fromExtraContentView:pv];
        
        pv.extraContentView.userInteractionEnabled = YES;
        [pv addSubview:pv.extraContentView];
    }
    
    if (visibility) {
        CGRect rect = CGRectZero;
        rect.size.width = [KDStatusBodyView textDisplayWidthAtLayer:layer];
        pv.extraContentView.textLabel.bounds = rect;
        pv.extraContentView.forwardTextLabel.bounds = rect;
    }
    
    if (pv.extraContentView != nil) {
        pv.extraContentView.hidden = !visibility;
    }
}

- (void)reset {
    KDStatusBodyView *cv = nil;
    KDStatusBodyView *target = self;
    while ((cv = target.extraContentView) != nil) {
        cv.textLabel.text = nil;
        cv.forwardTextLabel.text = nil;
        
        cv.textLabel.hidden = YES;
        cv.forwardTextLabel.hidden = YES;
        cv.dividerView.hidden = YES;
        
        cv.backgroundView.hidden = YES;
        
        cv.thumbnailView.hidden = YES;
        cv.thumbnailView.imageDataSource = nil;
        
        cv.extraMessageTypeView.hidden = YES;
        cv.locationVeiw.hidden = YES;
        cv.documentIndicatorView.hidden = YES;
        
        target = cv;
    }
    
    CGRect rect = CGRectZero;
    rect.size.width = [KDStatusBodyView textDisplayWidthAtLayer:0];
    textLabel_.bounds = rect;
    
    if (thumbnailView_ != nil) {
        thumbnailView_.hidden = YES;
        thumbnailView_.imageDataSource = nil;
    }
    
    if (extraContentView_ != nil) {
        extraContentView_.hidden = YES;
    }
    locationView_.hidden = YES;
    documentIndicatorView_.hidden = YES;
}

- (void)changeBackgroundImage:(BOOL)isThridPart parentView:(KDStatusBodyView *)pv {
    UIImage *bgImage = nil;
//    if (isThridPart) {
//        bgImage = [UIImage imageNamed:@"sina.png"];
//        bgImage = [bgImage stretchableImageWithLeftCapWidth:(0.1 * bgImage.size.width) topCapHeight:(0.1 * bgImage.size.height)];
//        
//    } else {
        bgImage = [UIImage imageNamed:@"repost_frame_v2.png"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width*0.5 topCapHeight:bgImage.size.height*0.5];
   // }
    
    [pv setupBackgroundView:bgImage];
}

- (void)updateExtraContentWithStatus:(KDStatus *)status {
    BOOL visible = NO;
    NSString *secondExtraText = nil;
    NSString *secondExtraForwardText = nil;
    
    // thrid part weibo (like sina weibo etc.)
    if (status.extendStatus != nil) {
        [self setExtraContentViewVisibility:YES parentView:self atLayer:1];
        [self changeBackgroundImage:YES parentView:extraContentView_];
        
        secondExtraText = [KDStatusBodyView formatExtStatusText:status.extendStatus];
        if (status.extendStatus.forwardedContent) {
            secondExtraForwardText = [KDStatusBodyView formatForwardExtStatusText:status.extendStatus];
        }
    }
    
    // extra forward content
    if (status.hasForwardedStatus) {
        [self setExtraContentViewVisibility:YES parentView:self atLayer:1];
        [self changeBackgroundImage:NO parentView:extraContentView_];
        
        KDStatus *replyStatus = status.forwardedStatus;
        
        //TODO: format text. need confirm
       // secondExtraText = [NSString stringWithFormat:@"%@: %@", NOT_NULL(replyStatus.author.screenName), replyStatus.text];
        secondExtraText = FORMATE_FORWARD_STATUS_TEXT(replyStatus.author.screenName,[replyStatus taskFormatContet]);
        // set the vote in reply hidden
        UIImage *voteTypeImage = nil;
        NSInteger type = 0;
        if ([replyStatus.extraMessage isVote]) {
            voteTypeImage = [UIImage imageNamed:@"vote.png"];
            type = KD_EXTRA_MESSAGE_TYPE_VOTE;
        }
//        else if([replyStatus.extraMessage isFreshman]) {
//            voteTypeImage = [UIImage imageNamed:@"freshman.png"];
//            type = KD_EXTRA_MESSAGE_TYPE_FRESHMAN;
//        }
//        else if([replyStatus.extraMessage isBulletin]) {
//            voteTypeImage = [UIImage imageNamed:@"bulletin.png"];
//            type = KD_EXTRA_MESSAGE_TYPE_BULLETIN;
//        }else if([replyStatus hasTask]) {
//            voteTypeImage = [UIImage imageNamed:@"mission.png"];
//            type = KD_EXTRA_MESSAGE_TYPE_MISSION;
//        }
//        extraContentView_.status = status_.forwardedStatus;
        [extraContentView_ setupExtraMessageTypeView:voteTypeImage target:self extraMessageType:type];
        if (extraContentView_) {
            if ([replyStatus hasAddress]) {
                extraContentView_.locationVeiw.hidden = NO;
                [extraContentView_.locationVeiw setAddrText:replyStatus.address];
            }
        }
        // thrid part weibo (like sina weibo etc.)
        if (replyStatus.extendStatus != nil) {
            [self setExtraContentViewVisibility:YES parentView:extraContentView_ atLayer:2];
            [self changeBackgroundImage:YES parentView:extraContentView_.extraContentView];
            
            NSString *thirdPartExtraText = [KDStatusBodyView formatExtStatusText:replyStatus.extendStatus];
            NSString *thirdPartExtraForwardText = nil;
            if (replyStatus.extendStatus.forwardedContent) {
                thirdPartExtraForwardText = [KDStatusBodyView formatForwardExtStatusText:replyStatus.extendStatus];
            }
            
            if (thirdPartExtraText != nil) {
                extraContentView_.extraContentView.textLabel.text = thirdPartExtraText ? thirdPartExtraText : @"";
                [extraContentView_.extraContentView.textLabel sizeToFit];
            }
            extraContentView_.extraContentView.textLabel.hidden = (thirdPartExtraText == nil) ? YES : NO;
            
            if (thirdPartExtraForwardText != nil) {
                extraContentView_.extraContentView.forwardTextLabel.text = thirdPartExtraForwardText ? thirdPartExtraForwardText : @"";
                [extraContentView_.extraContentView.forwardTextLabel sizeToFit];
            }
            
            visible = (thirdPartExtraForwardText != nil) ? YES : NO;
            extraContentView_.extraContentView.forwardTextLabel.hidden = !visible;
            extraContentView_.extraContentView.dividerView.hidden = !visible;
        }
        
        if([replyStatus hasAttachments]) {
            if(!extraContentView_.documentIndicatorView) {
                extraContentView_.documentIndicatorView = [[KDDocumentIndicatorView alloc] initWithFrame:CGRectMake(0, 0, extraContentView_.bounds.size.width, [KDDocumentIndicatorView heightForDocumentsCount:replyStatus.attachments.count])];// autorelease];
                extraContentView_.documentIndicatorView.delegate = self;
                extraContentView_.documentIndicatorView.userInteractionEnabled = YES;
                [extraContentView_ addSubview:extraContentView_.documentIndicatorView];
            }
            
            extraContentView_.documentIndicatorView.documents = replyStatus.attachments;
            extraContentView_.documentIndicatorView.hidden = NO;
        }
    }
    
    if (secondExtraText != nil) {
        extraContentView_.textLabel.text = secondExtraText ? secondExtraText : @"";
        [extraContentView_.textLabel sizeToFit];
    }
    extraContentView_.textLabel.hidden = (secondExtraText == nil) ? YES : NO;
    
    if (secondExtraForwardText != nil) {
        extraContentView_.forwardTextLabel.text = secondExtraForwardText ? secondExtraForwardText : @"";
        [extraContentView_.forwardTextLabel sizeToFit];
    }
    
    visible = (secondExtraForwardText != nil) ? YES : NO;
    extraContentView_.forwardTextLabel.hidden = !visible;
    extraContentView_.dividerView.hidden = !visible;
    
    
}

- (void)reload {
    [self updateWithStatus:status_];
}

- (void)updateWithStatus:(KDStatus *)status {
    [self reset];
    
    if(groupTipView) {
        [groupTipView removeFromSuperview];
        groupTipView = nil;
    }
    
    if([status respondsToSelector:@selector(isGroup)] && [status isGroup] && position_ != KDStatusBodyViewDisplayPositionGroup) {
        groupTipView = [[KDStatusFromGroupTipView alloc] initWithGroupName:status.groupName];
        [self addSubview:groupTipView];
    }
    
    // status text
    NSString *text  = @"";
    text = [status taskFormatContet];
    textLabel_.text = text;
    [textLabel_ sizeToFit];
    
    // update extra content
    [self updateExtraContentWithStatus:status];
    
    // thumbnail
    if (style_ & KDStatusBodyViewDisplayStyleThumbnail) {
        NSUInteger atLayer = 0;
        KDCompositeImageSource *compositeImageSource = [status actuallyCompositeImageSourceAndType:&atLayer];
        BOOL visibility = (compositeImageSource != nil && [compositeImageSource hasImageSource]);
        
        KDStatus *status = nil;
        KDStatusBodyView *parentView = nil;
        if (0x01 == atLayer) {
            parentView = self; // original weibo with an image
            status = status_;
        } else if (0x02 == atLayer) {
            // forwarded weibo with an image
            // or third part weibo with an image (like sina etc.)
            parentView = extraContentView_;
            //parentView.status = self.status.forwardedStatus;
            status = status_.forwardedStatus;
        } else if (0x03 == atLayer) {
            // third part weibo with an image (like sina etc.)
            parentView = extraContentView_.extraContentView;
           
        }
        
       // [parentView setupThumbnailView:compositeImageSource visibility:visibility delegate:thumbnailDelegate_];
        [parentView setupThumbnailView:compositeImageSource status:status visibility:visibility delegate:thumbnailDelegate_];
    }
    
    // vote
    UIImage *voteTypeImage = nil;
    NSInteger type = 0;
  
    if ([status.extraMessage isVote]) {
        voteTypeImage = [UIImage imageNamed:@"vote.png"];
        type = KD_EXTRA_MESSAGE_TYPE_VOTE;
    }
//    else if([status.extraMessage isFreshman ]) {
//        voteTypeImage = [UIImage imageNamed:@"freshman.png"];
//        type = KD_EXTRA_MESSAGE_TYPE_FRESHMAN;
//    }else if([status.extraMessage isBulletin]) {
//        voteTypeImage = [UIImage imageNamed:@"bulletin.png"];
//        type = KD_EXTRA_MESSAGE_TYPE_BULLETIN;
//    }else if([status hasTask]) {
//           voteTypeImage = [UIImage imageNamed:@"mission.png"];
//        type = KD_EXTRA_MESSAGE_TYPE_MISSION;
//    }
    
    [self setupExtraMessageTypeView:voteTypeImage target:self extraMessageType:type];
    
    //set address
    if ([status hasAddress]) {
        locationView_.hidden = NO;
        [locationView_ setAddrText:status.address];
        
    }
    
    //document
    if([status hasAttachments]) {
        if(!documentIndicatorView_) {
            documentIndicatorView_ = [[KDDocumentIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, [KDDocumentIndicatorView heightForDocumentsCount:status.attachments.count])];
            documentIndicatorView_.delegate = self;
            [self addSubview:documentIndicatorView_];
        }
        documentIndicatorView_.documents = status_.attachments;
        documentIndicatorView_.hidden = NO;
    }

    [self setNeedsLayout];
}

- (void)setStatus:(KDStatus *)status {
    if (status_ != status) {
//        [status_ release];
        status_ = status;// retain];
    }
   
    [self updateWithStatus:status_];
}

- (KDStatus *)status {
    return status_;
}

- (KDThumbnailView2 *)currentVisibleThumbnailView {
    KDThumbnailView2 *tv = nil;
    
    KDStatusBodyView *temp = self;
    while (YES) {
        if (temp.thumbnailView != nil && !temp.thumbnailView.hidden) {
            tv = temp.thumbnailView;
            if (self == temp) {
                tv.status = temp.status;
            }else {
                tv.status = self.status.forwardedStatus;
            }
            break;
        }
        
        if (temp.extraContentView == nil) {
            break;
        }
        
        temp = temp.extraContentView;
    }
    
    return tv;
}


- (void)didTapOnThumbnailView:(KDThumbnailView2 *)thumbnailView {
    if (thumbnailDelegate_ != nil && [thumbnailDelegate_ respondsToSelector:@selector(didTapOnThumbnailView:userInfo:)]) {
        [thumbnailDelegate_ didTapOnThumbnailView:thumbnailView userInfo:nil];
    }
}

- (void)didTapOnExtraBadgeView:(id)sender {
    NSInteger type = [(UIButton *)sender tag];
    
    if(KD_EXTRA_MESSAGE_TYPE_VOTE != type) return;
    
    NSString *voteId = (status_.forwardedStatus != nil) ? status_.forwardedStatus.extraMessage.referenceId : status_.extraMessage.referenceId;
    [[KDDefaultViewControllerContext defaultViewControllerContext] showVoteControllerWithVoteId:voteId sender:sender];
}

- (void)locationViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    KDStatus *status = nil;
    if ([status_ hasAddress]) {
        status = status_;
    }else {
        KDStatusBodyView *bodyview = (KDStatusBodyView *)[self superview];
        status = bodyview.status.forwardedStatus;
    }
    if (status) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showMapViewController:status sender:self];
    }
}

#pragma mark - KDDocumentIndicatorViewDelegate Methods
- (void)documentIndicatorView:(KDDocumentIndicatorView *)div didClickedAtAttachment:(KDAttachment *)attachment {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showProgressModalViewController:attachment inStatus:status_ sender:self];
}

- (void)didClickMoreInDocumentIndicatorView:(KDDocumentIndicatorView *)div {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showAttachmentViewController:status_ sender:self];
}
////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Utlity methods

+ (NSString *)formatExtStatusText:(KDExtendStatus *)extStatus {
    NSString *extraText = nil;
    if (extStatus != nil) {
        //extraText = [NSString stringWithFormat:@"%@:%@", NOT_NULL(extStatus.senderName), extStatus.content];
        extraText = FORMATE_FORWARD_STATUS_TEXT(extStatus.senderName,extStatus.content);
    }
    
    return extraText;
}

+ (NSString *)formatForwardExtStatusText:(KDExtendStatus *)extStatus {
    NSString *extraForwardText = nil;
    if ([extStatus forwardedSenderName]) {
       // extraForwardText = [NSString stringWithFormat:@"%@:%@", NOT_NULL(extStatus.forwardedSenderName), extStatus.forwardedContent];
         extraForwardText = FORMATE_FORWARD_STATUS_TEXT(extStatus.forwardedSenderName,extStatus.forwardedContent);
    }
    
    return extraForwardText;
}

+ (CGFloat)defaultStatusExtraMessageTypeHeight {
    // default extra message type icon height (at now, Just support vote)
    return 40.0;
}

+ (CGFloat)textDisplayWidthAtLayer:(NSInteger)layer {
    static CGFloat width = 0.0;
    if (width < 0.01) {
        // margin left (10.0), avatar width (47.0), spacing (10.0), margin right (5.0)
        width = [UIScreen mainScreen].bounds.size.width - 72.0;
    }
    
    return width - layer * 12.0; // extra content margin left (10.0) and margin right (10.0)
}

+ (CGFloat)calculateStatusBodyHeight:(KDStatus *)status bodyViewPosition:(KDStatusBodyViewDisplayPosition)p {
    CGFloat height = 0.0;
    UIFont *font = [UIFont systemFontOfSize:KD_TEXT_LABEL_FONT_SIZE];
    
    CGSize constrainedToSize = CGSizeMake([KDStatusBodyView textDisplayWidthAtLayer:0], CGFLOAT_MAX);
    
    NSString *text = [status taskFormatContet];
    //    CGSize size = [text sizeWithFont:font constrainedToSize:constrainedToSize];
    //    height += size.height;
    
    //support for expression
    CGSize size = [KDExpressionLabel sizeWithString:text constrainedToSize:constrainedToSize withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionLeft textColor:[UIColor darkTextColor] textFont:font];
    height += size.height;
    
    
    font = [UIFont systemFontOfSize:KD_FORWARD_LABEL_FONT_SIZE];
    
    NSString *secondExtraText = nil;
    NSString *secondExtraForwardText = nil;
    
    // extra status content (third part weibo)
    if (status.extendStatus != nil) {
        secondExtraText = [KDStatusBodyView formatExtStatusText:status.extendStatus];
        if (status.extendStatus.forwardedContent) {
            secondExtraForwardText = [KDStatusBodyView formatForwardExtStatusText:status.extendStatus];
        }
    }
    
    // extra forward content
    if (status.hasForwardedStatus) {
        KDStatus *replyStatus = status.forwardedStatus;
        //secondExtraText = [NSString stringWithFormat:@"%@: %@", NOT_NULL(replyStatus.author.screenName), replyStatus.text];
        secondExtraText = FORMATE_FORWARD_STATUS_TEXT(replyStatus.author.screenName,[replyStatus taskFormatContet]);
        
        if (replyStatus.extendStatus != nil) {
            NSString *thirdPartExtraText = [KDStatusBodyView formatExtStatusText:replyStatus.extendStatus];
            NSString *thirdPartExtraForwardText = nil;
            if (replyStatus.extendStatus.forwardedContent) {
                thirdPartExtraForwardText = [KDStatusBodyView formatForwardExtStatusText:replyStatus.extendStatus];
            }
            
            if (thirdPartExtraText != nil) {
                height += KD_STATUS_BODY_CONTENT_SPACING; // content spacing
                
                constrainedToSize.width = [KDStatusBodyView textDisplayWidthAtLayer:2];
                //                size = [thirdPartExtraText sizeWithFont:font constrainedToSize:constrainedToSize];
                
                //support for expression
                size = [KDExpressionLabel sizeWithString:thirdPartExtraText constrainedToSize:constrainedToSize withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionLeft textColor:[UIColor darkTextColor] textFont:font];
                
                height += size.height;
                
                if (thirdPartExtraForwardText != nil) {
                    // forward content divider spacing
                    height += KD_STATUS_BODY_FORWARD_CONTENT_DIVIDER_SPACING;
                    
                    //                    size = [thirdPartExtraForwardText sizeWithFont:font constrainedToSize:constrainedToSize];
                    
                    //support for expression
                    size = [KDExpressionLabel sizeWithString:thirdPartExtraForwardText constrainedToSize:constrainedToSize withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionLeft textColor:[UIColor darkTextColor] textFont:font];
                    height += 5.f;
                    height += size.height;
                }
            }
            
            // extra content margin
            height += kKDStatusBodyContentEdgeInsets.top + kKDStatusBodyContentEdgeInsets.bottom;
            
            height += KD_STATUS_BODY_CONTENT_SPACING; // bottom spacing
        }
        
        //        if ([replyStatus isHasVote] || [replyStatus isHasBulletin] || [replyStatus isHasFreshMan])
        if ([replyStatus.extraMessage isVote]) {
            height += KD_STATUS_BODY_CONTENT_SPACING;
            height += [KDStatusBodyView defaultStatusExtraMessageTypeHeight];
            height += KD_STATUS_BODY_CONTENT_SPACING;
        }
        if ([replyStatus hasAddress]) {
            height +=27;
        }
        
        if([replyStatus hasAttachments]) {
            height += [KDDocumentIndicatorView heightForDocumentsCount:replyStatus.attachments.count] + 5.0f;
        }
    }
    
    if (secondExtraText != nil) {
        height += KD_STATUS_BODY_CONTENT_SPACING; // content spacing
        
        constrainedToSize.width = [KDStatusBodyView textDisplayWidthAtLayer:1];
        
        //        size = [secondExtraText sizeWithFont:font constrainedToSize:constrainedToSize];
        
        //support for expression
        size = [KDExpressionLabel sizeWithString:secondExtraText constrainedToSize:constrainedToSize withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionLeft textColor:[UIColor darkTextColor] textFont:font];
        
        height += size.height;
        
        if (secondExtraForwardText != nil) {
            // forward content divider spacing
            height += KD_STATUS_BODY_FORWARD_CONTENT_DIVIDER_SPACING;
            
            //            size = [secondExtraForwardText sizeWithFont:font constrainedToSize:constrainedToSize];
            
            //support for expression
            size = [KDExpressionLabel sizeWithString:secondExtraForwardText constrainedToSize:constrainedToSize withType:KDExpressionLabelType_Expression textAlignment:UITextLayoutDirectionLeft textColor:[UIColor darkTextColor] textFont:font];
            
            height += size.height;
        }
        
        // extra content margin
        height += kKDStatusBodyContentEdgeInsets.top + kKDStatusBodyContentEdgeInsets.bottom;
    }
    
    // vote
    //    if ([status isHasVote] || [status isHasFreshMan] || [status isHasBulletin])

    if ([status.extraMessage isVote]) {
      
        height += KD_STATUS_BODY_CONTENT_SPACING;
        height += [KDStatusBodyView defaultStatusExtraMessageTypeHeight];
    }
    
    if ([status hasAddress]) {
        height += 27;
    }
    
    //if come from group. 21 -> tip's height, 12 -> spacing.
    if([status isGroup] && p != KDStatusBodyViewDisplayPositionGroup)
        height += (21 + 12);
    
    if([status hasAttachments]) {
        height += [KDDocumentIndicatorView heightForDocumentsCount:status.attachments.count] + 5.0f;
    }
    
    return height;
}

+ (CGFloat)calculateStatusBodyHeight:(KDStatus *)status {
    return [self calculateStatusBodyHeight:status bodyViewPosition:KDStatusBodyViewDisplayPositionNormal];
}

+ (CGFloat)calculateStatusBodyThumbnailHeight:(KDStatus *)status {
    CGFloat height = 0.0;
    if ([status hasExtraImageSource]) {
        id<KDImageDataSource> imageDataSource = status.compositeImageSource;
        imageDataSource = imageDataSource == nil ? status.forwardedStatus.compositeImageSource : imageDataSource;
        CGSize size = [KDThumbnailView2 thumbnailSizeWithImageDataSource:imageDataSource showAll:YES];
        height = size.height + 2 * KD_STATUS_BODY_CONTENT_SPACING;
    }
    
    return height;
}

- (void)dealloc {
    thumbnailDelegate_ = nil;
    //KD_RELEASE_SAFELY(status_);
    
    
    //KD_RELEASE_SAFELY(documentIndicatorView_);
    
    //KD_RELEASE_SAFELY(backgroundView_);
    
    //KD_RELEASE_SAFELY(textLabel_);
    //KD_RELEASE_SAFELY(forwardTextLabel_);
    //KD_RELEASE_SAFELY(dividerView_);
    
    //KD_RELEASE_SAFELY(extraContentView_);
    //KD_RELEASE_SAFELY(thumbnailView_);
    //KD_RELEASE_SAFELY(extraMessageTypeView_);
    //KD_RELEASE_SAFELY(locationView_);
    //KD_RELEASE_SAFELY(groupTipView);
    
    //[super dealloc];
}

@end
