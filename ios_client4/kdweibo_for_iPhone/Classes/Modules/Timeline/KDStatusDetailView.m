//
//  KDStatusDetailView.m
//  kdweibo
//
//  Created by shen kuikui on 12-12-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDStatusDetailView.h"

#import "KDThumbnailView2.h"
#import "KDGifView.h"
#import "KDAttachmentIndicatorView.h"
#import "KDExtendStatusDetailView.h"
#import "KDDocumentIndicatorView.h"

#import "TwitterText.h"
#import "NSDate+Additions.h"
#import "ResourceManager.h"

#import "KDStatusContentDetailView.h"

#import "KDMapRenderView.h"
#import "KDLocationView.h"
#import "KDTaskDetailView.h"

#import "KDDefaultViewControllerContext.h"
#import "KDUtility.h"
#import "KDCompositeImageSource.h"

#import "BOSSetting.h"

//MARK:font size: 16.0f, 14.0f, 11.0f
#define KD_FONTSIZE_MAINBODY             16.0f
#define KD_FONTSIZE_FORWARDMAIN          15.0f
#define KD_FONTSIZE_COMMENTANDFORWARD    11.0f
#define KD_FONTSIZE_STAMPLABEL           12.0f

#define KD_SDV_IMAGEPADDING          10.0f
#define KD_SDV_H_PADDING             8.0f
#define KD_SDV_V_SPACING             8.0f
#define KD_SDV_V_PADDING             2.0f

#define KD_FORWARD_TEXT_PADDING      3.0f

#define KD_FORWARD_BUTTONS_HEIGHT    20.0f

#define KD_TAG_STATUSCONTENTVIEW     3510
#define KD_TAG_SUBDETAILTWITTERVIEW  3511
#define KD_TAG_EXTENDSTATUSVIEW      3512
#define KD_TAG_PHOTORENDERVIEW       3513
#define KD_TAG_EXTRAIMAGEVIEW        3514
#define KD_TAG_DOCUMENTVIEW          3515
#define KD_TAG_TIMELINE              3516

#define KD_TAG_COMMENTBUTTON         3517
#define KD_TAG_FORWARDBUTTON         3518
#define KD_TAG_PRAISEBUTTON          3519
#define KD_TAG_COMMENTICON           3520
#define KD_TAG_FORWARDICON           3521
#define KD_TAG_PRAISEICON            3522
#define KD_TAG_COMMENTLABEL          3523
#define KD_TAG_FORWARDLABEL          3524
#define KD_TAG_PRAISELABEL           3525
#define KD_TAG_MAPVIEW               3526
#define KD_TAG_LOCATION              3527
#define KD_TAG_TASK_DETAIL_VIEW      3528

#define KD_TAG_BACKGROUNDVIEW        3537

#define MAP_IMAGE_BASE_URL   @"http://st.map.soso.com/api"
#define MAP_IMAGE_SIZE_X2  @"600*100"
#define MAP_IMAGE_SIZE     @"300*50"

@interface KDStatusDetailView ()<KDMapRenderViewDelegate, KDDocumentIndicatorViewDelegate, KDGifViewDelegate>
{
    KDStatus *status_;
//    id<KDStatusDetailViewDelegate> delegate_;
    
    BOOL isForwarding_;
    BOOL showGroupName_;
}

- (void)setUp;
- (void)setUpCoreTextView;
- (void)setUpExtraMessage;
- (void)setUpNextDetailTwitterView;
- (void)setUpImagesView;
- (void)setUpDocumentView;
- (void)setUpTimeStampView;
- (void)setUpIfForwarding;
- (void)setUpIfExternalStatus;

- (void)setBackgroundColor;

@end


@implementation KDStatusDetailView

@synthesize delegate = delegate_;
@synthesize status = status_;
@synthesize isForwarding = isForwarding_;
@synthesize showGroupName = showGroupName_;
@synthesize showDigit = showDigit_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isForwarding_ = NO;
        showGroupName_ = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(menuHiddenAction)
                                                     name:UIMenuControllerDidHideMenuNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
//    [status_ release];
    status_ = nil;
    
    delegate_ = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    //[super dealloc];
}

- (void)setStatus:(KDStatus *)status {
//    [status retain];
//    [status_ release];
    status_ = status;
    if(status_) {
        [self setUp];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
//@brief
- (void)setUp {
    
    [self setUpCoreTextView];
    
    if(status_.extraMessage)
        [self setUpExtraMessage];
    
    [self setUpTaskDetailView];
    if(status_.compositeImageSource && status_.compositeImageSource.imageSources.count)
        [self setUpImagesView];
    if ([status_ hasAddress]) {
        [self setUpMapImageView];
        [self setupLoactionView];
    }
    if([status_ hasForwardedStatus])
        [self setUpNextDetailTwitterView];
    else if(status_.extendStatus) {
        [self setUpIfExternalStatus];
    }
    
    if(isForwarding_)
        [self setUpIfForwarding];
    //    else
    //       // [self setUpTimeStampView];
    
    if([status_ hasAttachments])
        [self setUpDocumentView];
    
}

- (void)setUpTaskDetailView {
    KDTask *task = [status_ propertyForKey:@"task"];
    if (!task && !(status_.extraMessage && [status_.extraMessage isTask])) {
        return;
    }
    KDTaskDetailView *taskDetailView = (KDTaskDetailView *)[self viewWithTag:KD_TAG_TASK_DETAIL_VIEW];
    if (!taskDetailView) {
        taskDetailView = [[KDTaskDetailView alloc ] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 2 * KD_SDV_H_PADDING,152)];
        taskDetailView.tag = KD_TAG_TASK_DETAIL_VIEW;
        taskDetailView.nocationSender = self.delegate;
        [self addSubview:taskDetailView];
//        [taskDetailView release];
    }
    if (task) {
        taskDetailView.task = task;
    }else  if(status_.extraMessage) {
        KDStatusExtraMessage *message = status_.extraMessage;
        NSNumber *canAccessTaskNum = [message propertyForKey:@"access"]; //标志是否有权限查看任务详情
        if (!canAccessTaskNum) {
            canAccessTaskNum = @(YES);
            if([status_ hasTask]) {
                [message setProperty:canAccessTaskNum forKey:@"access"];
            }
            
        }
        taskDetailView.extraMessage = message;
    }
    
}

- (void)setUpMapImageView {
    KDMapRenderView *mapRenderView = (KDMapRenderView *)[self viewWithTag:KD_TAG_MAPVIEW];
    if (!mapRenderView) {
        mapRenderView = [[KDMapRenderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width - 2 * KD_SDV_H_PADDING, 50.0f)];
        mapRenderView.tag = KD_TAG_MAPVIEW;
        mapRenderView.delegate = self;
        
        [self addSubview:mapRenderView];
//        [mapRenderView release];
//
        UITapGestureRecognizer *rgzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapRenderViewTapped:)];
        [mapRenderView addGestureRecognizer:rgzr];
//        [rgzr release];
    }
    KDImageSource *source = [[KDImageSource alloc] init];
    // source.thumbnail = @"http://st.map.soso.com/api?size=85*100&center=113.954924,22.534101&zoom=16";
    source.thumbnail = [NSString stringWithFormat:@"%@?size=%@&center=%f,%f&zoom=%d&markers=%f,%f,red",MAP_IMAGE_BASE_URL,[[KDUtility defaultUtility] isHighResolutionDevice]?MAP_IMAGE_SIZE_X2:MAP_IMAGE_SIZE,status_.longitude,status_.latitude,[[KDUtility defaultUtility] isHighResolutionDevice]?16:13,status_.longitude,status_.latitude];
    KDCompositeImageSource *imageSource = [[KDCompositeImageSource alloc] initWithImageSources:@[source]];
//    [source release];
    mapRenderView.imageDataSource = imageSource;
//    [imageSource release];
    //thumbnailView
}

- (void)setupLoactionView {
    KDLocationView *locationView = (KDLocationView *)[self viewWithTag:KD_TAG_LOCATION];
    if (!locationView) {
        
        CGFloat width = textboundsByContrainedWidth(self.bounds.size.width - 2 * KD_SDV_H_PADDING - 73, [UIFont systemFontOfSize:13.0], status_.address).size.width + 73;
        locationView = [[KDLocationView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 26.0f)];
        locationView.tag = KD_TAG_LOCATION;
        [self addSubview:locationView];
        UITapGestureRecognizer *rgzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locatonViewTapped:)];
        [locationView addGestureRecognizer:rgzr];
//        [rgzr release];
//        [locationView release];
    }
    [locationView setAddrText:status_.address];
}

- (void)longPress:(id)sender
{
    //假如后台配置不允许复制
    if(![[BOSSetting sharedSetting] allowMsgInnerMobileShare])
        return;
    
    KDStatusContentDetailView *coreTextView = (KDStatusContentDetailView *)[self viewWithTag:KD_TAG_STATUSCONTENTVIEW];
    if(coreTextView) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if([menuController isMenuVisible]) return;
        
        [menuController setTargetRect:CGRectMake(coreTextView.bounds.size.width * 0.5f, 0.0f, 0.0f, 0.0f) inView:coreTextView];
        [self becomeFirstResponder];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(copy:)) {
        return YES;
    }
    
    return NO;
}

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:status_.text];
}

- (void)menuHiddenAction {
    KDStatusContentDetailView  *coreTextView = (KDStatusContentDetailView *)[self viewWithTag:KD_TAG_STATUSCONTENTVIEW];
    if(coreTextView) {
        [coreTextView setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)setUpCoreTextView {
    KDStatusContentDetailView *contentView = (KDStatusContentDetailView *)[self viewWithTag:KD_TAG_STATUSCONTENTVIEW];
    if(contentView == nil) {
        KDStatusContentDetailViewType type = (!isForwarding_) ? KDStatusContentDetailViewTypeNormal : KDStatusContentDetailViewTypeForwarding;
        contentView = [[KDStatusContentDetailView alloc] initWithFrame:CGRectMake(KD_SDV_H_PADDING, 0.0f, self.bounds.size.width - 2 * KD_SDV_H_PADDING, 1.0f) andMode:KDStatusContentDetailViewCompleteMode andType:type];
        contentView.delegate = delegate_;
        contentView.backgroundColor = [UIColor clearColor];
        contentView.tag = KD_TAG_STATUSCONTENTVIEW;
        contentView.font = [UIFont systemFontOfSize:isForwarding_ ? KD_FONTSIZE_FORWARDMAIN : KD_FONTSIZE_MAINBODY];
        if (isForwarding_) {
            contentView.textColor = RGBCOLOR(109, 109, 109);
        }
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [contentView addGestureRecognizer:longPress];
//        [longPress release];
        
        [self addSubview:contentView];
//        [contentView release];
    }
    [contentView setStatus:status_];
}

- (void)setUpExtraMessage {
    KDStatusExtraMessage *statusExtraMessage = status_.extraMessage;
    
    //UIImage *image = nil;
    //    if(statusExtraMessage.isConnector) {
    //
    //    }else
    //    if(statusExtraMessage.isBulletin) {
    //        image = [UIImage imageNamed:@"bulletin.png"];
    //    }else
    //    if(statusExtraMessage.isPraise) {
    //
    //    }else
    //    if(statusExtraMessage.isFreshman) {
    //        image = [UIImage imageNamed:@"freshman.png"];
    //    }else
    //    if([statusExtraMessage isVote]) {
    //        image = [UIImage imageNamed:@"status_vote_btn.png"];
    //    }
    //
    //    if(image) {
    if ([statusExtraMessage isVote]) {
        UIButton *voteBtn = (UIButton *)[self viewWithTag:KD_TAG_EXTRAIMAGEVIEW];
        if (!voteBtn) {
            voteBtn = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
            [voteBtn setImage:[UIImage imageNamed:@"status_vote_btn"] forState:UIControlStateNormal];
            [voteBtn setImage:[UIImage imageNamed:@"status_vote_btn_hl"] forState:UIControlStateHighlighted];
            [voteBtn setTitleColor:MESSAGE_DATE_COLOR forState:UIControlStateNormal];
            [voteBtn setTitleEdgeInsets:UIEdgeInsetsMake(32, 10, 0, 0)];
            voteBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
            [voteBtn setTitle:ASLocalizedString(@"KDStatusDetailView_voteBtn_title")forState:UIControlStateNormal];
            voteBtn.bounds = CGRectMake(0, 0, 120, voteBtn.imageView.image.size.height);
            voteBtn.tag = KD_TAG_EXTRAIMAGEVIEW;
            [voteBtn addTarget:self action:@selector(extraMessageImageViewClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:voteBtn];
        }
    }
    
}

- (void)setUpNextDetailTwitterView {
    KDStatusDetailView *subDetailView = (KDStatusDetailView *)[self viewWithTag:KD_TAG_SUBDETAILTWITTERVIEW];
    if(!subDetailView) {
        subDetailView = [[KDStatusDetailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - 2 * KD_SDV_H_PADDING, 1.0f)] ;//autorelease];
        subDetailView.tag = KD_TAG_SUBDETAILTWITTERVIEW;
        subDetailView.isForwarding = YES;
        subDetailView.delegate = delegate_;
        subDetailView.status = status_.forwardedStatus;
        [self addSubview:subDetailView];
    }
}

- (void)setUpImagesView {
    
    int count = (int)[ status_.compositeImageSource.imageSources count];
    if (count == 1) {
        
        if ([[status_.compositeImageSource getTimeLineImageSourceAtIndex:0] isGifImage]) {
            
            KDGifView *renderView = (KDGifView *)[self viewWithTag:KD_TAG_PHOTORENDERVIEW];
            if (!renderView) {
                renderView = [[KDGifView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - 2 * KD_SDV_H_PADDING, 80.0f)];
                renderView.demoDelegate = self;
                renderView.tag = KD_TAG_PHOTORENDERVIEW;
                [renderView.control addTarget:self action:@selector(showImagesGallery:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:renderView];
//                [renderView release];
            }
            renderView.imageSource = status_.compositeImageSource;
        }
        else
        {
            KDStatusPhotoRenderView *renderView = (KDStatusPhotoRenderView *)[self viewWithTag:KD_TAG_PHOTORENDERVIEW];
            
            if(!renderView) {
                renderView = [KDStatusPhotoRenderView photoRenderViewWithStatus:self.status];
                renderView.tag = KD_TAG_PHOTORENDERVIEW;
                [renderView addTarget:self action:@selector(showImagesGallery:) forControlEvents:UIControlEventTouchUpInside];
                renderView.delegate = self;
                [renderView setFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - 2 * KD_SDV_H_PADDING, 80.0f)];
                [self addSubview:renderView];
            }
            
            renderView.imageSource = status_.compositeImageSource;
        }
    } else if (count > 1) {
        KDThumbnailView2 *renderView = (KDThumbnailView2 *)[self viewWithTag:KD_TAG_PHOTORENDERVIEW];
        
        if(!renderView) {
            renderView = [KDThumbnailView2 thumbnailViewWithSize:[KDImageSize defaultThumbnailImageSize]];
            renderView.tag = KD_TAG_PHOTORENDERVIEW;
            renderView.status = self.status;
            [renderView setImageDataSource:self.status.compositeImageSource withType:SDWebImageScaleMiddle];
            [renderView addTarget:self action:@selector(showImagesGallery:) forControlEvents:UIControlEventTouchUpInside];
            renderView.delegate = self.delegate;
            CGRect frame = CGRectZero;
            
            frame.size = [KDThumbnailView2 thumbnailSizeWithImageDataSource:status_.compositeImageSource showAll:(count > 1)];
            frame.origin.x = (self.frame.size.width - frame.size.width) / 2.0f;
            [renderView setFrame:frame];
            [self addSubview:renderView];
        }
        
    }
    
    //    KDThumbnailView2 * thumbnailView =  (KDThumbnailView2 * )[self viewWithTag:KD_TAG_PHOTORENDERVIEW];
    //    if (!thumbnailView) {
    //         thumbnailView = [KDThumbnailView2 thumbnailViewWithStatus:self.status];
    //        thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //        thumbnailView.tag = KD_TAG_PHOTORENDERVIEW;
    //        [self addSubview:thumbnailView];
    //        thumbnailView.delegate = self;
    //        //thumbnailView_.imageDataSource = ((KDThumbnailsLayouter *)layouter_).imageSource;
    //        [thumbnailView setImageDataSource:self.status.compositeImageSource withType:KDCacheImageTypeMiddle];
    //    }
    
}
- (void)setUpDocumentView {
    //    KDAttachmentIndicatorView *documentIndicatorView = (KDAttachmentIndicatorView *)[self viewWithTag:KD_TAG_DOCUMENTVIEW];
    //
    //    if(!documentIndicatorView) {
    //        documentIndicatorView = [[[KDAttachmentIndicatorView alloc] initWithFrame:CGRectZero] autorelease];
    //        documentIndicatorView.tag = KD_TAG_DOCUMENTVIEW;
    //        [documentIndicatorView.indicatorButton addTarget:self action:@selector(attachmentViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    //        [documentIndicatorView addTaget:self selector:@selector(attachmentViewClicked:)];
    //        [documentIndicatorView setDefaultBackgroundImageStyle];
    //        [self addSubview:documentIndicatorView];
    //    }
    //
    //    [documentIndicatorView setAttachmentsCount:status_.attachments.count];
    KDDocumentIndicatorView *documentIndicatorView = (KDDocumentIndicatorView *)[self viewWithTag:KD_TAG_DOCUMENTVIEW];
    if(!documentIndicatorView) {
        documentIndicatorView = [[KDDocumentIndicatorView alloc] initWithFrame:CGRectMake(KD_SDV_H_PADDING, 0.0f, self.frame.size.width - 2 * KD_SDV_H_PADDING, [KDDocumentIndicatorView heightForDocumentsCount:status_.attachments.count])] ;//autorelease];
        documentIndicatorView.tag = KD_TAG_DOCUMENTVIEW;
        documentIndicatorView.delegate = self;
        [self addSubview:documentIndicatorView];
    }
    
    documentIndicatorView.documents = status_.attachments;
}

- (void)setUpTimeStampView {
    UILabel *label = (UILabel *)[self viewWithTag:KD_TAG_TIMELINE];
    
    if(!label) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];// autorelease];
        label.tag = KD_TAG_TIMELINE;
        label.font = [UIFont systemFontOfSize:KD_FONTSIZE_STAMPLABEL];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
    }
    
    //both the time and source in one label.
    NSString *source = status_.source;
    label.text = [NSString stringWithFormat:@"%@  %@",
                  [NSDate formatMonthOrDaySince1970:[status_.createdAt timeIntervalSince1970]],
                  [NSString stringWithFormat:ASLocalizedString(@"Wb_From"), source]
                  ];
}

- (void)setUpIfForwarding {
    UIButton *commentBtn = (UIButton *)[self viewWithTag:KD_TAG_COMMENTBUTTON];
    if(!commentBtn) {
        commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        commentBtn.tag = KD_TAG_COMMENTBUTTON;
        [commentBtn addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:commentBtn];
        
        UIImageView *commentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_icon_mini.png"]];// autorelease];
        commentIcon.tag = KD_TAG_COMMENTICON;
        [commentBtn addSubview:commentIcon];
        
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;//autorelease];
        commentLabel.tag = KD_TAG_COMMENTLABEL;
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.textColor = RGBCOLOR(170, 170, 170);
        [commentBtn addSubview:commentLabel];
        commentLabel.font = [UIFont systemFontOfSize:KD_FONTSIZE_COMMENTANDFORWARD];
    }
    
    UILabel *commentLabel = (UILabel *)[self viewWithTag:KD_TAG_COMMENTLABEL];
    commentLabel.text = @"...";
    
    UIButton *forwardBtn = (UIButton *)[self viewWithTag:KD_TAG_FORWARDBUTTON];
    if(!forwardBtn) {
        forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        forwardBtn.tag = KD_TAG_FORWARDBUTTON;
        [forwardBtn addTarget:self action:@selector(forwardButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:forwardBtn];
        
        UIImageView *forwardIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forward_icon_mini.png"]] ;//autorelease];
        forwardIcon.tag = KD_TAG_FORWARDICON;
        [forwardBtn addSubview:forwardIcon];
        
        UILabel *forwardLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;//autorelease];
        forwardLabel.tag = KD_TAG_FORWARDLABEL;
        forwardLabel.backgroundColor = [UIColor clearColor];
        forwardLabel.textColor = RGBCOLOR(170, 170, 170);
        forwardLabel.font = [UIFont systemFontOfSize:KD_FONTSIZE_COMMENTANDFORWARD];
        [forwardBtn addSubview:forwardLabel];
    }
    
    UILabel *forwardLabel = (UILabel *)[self viewWithTag:KD_TAG_FORWARDLABEL];
    forwardLabel.text = @"...";
    
    UIButton *praiseBtn = (UIButton *)[self viewWithTag:KD_TAG_PRAISEBUTTON];
    if(!praiseBtn) {
        praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        praiseBtn.tag = KD_TAG_PRAISEBUTTON;
        [praiseBtn addTarget:self action:@selector(praiseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:praiseBtn];
        
        UIImageView *praiseIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like_icon_mini.png"]];// autorelease];
        praiseIcon.tag = KD_TAG_PRAISEICON;
        [praiseBtn addSubview:praiseIcon];
        
        UILabel *praiseLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;//autorelease];
        praiseLabel.tag = KD_TAG_PRAISELABEL;
        praiseLabel.backgroundColor = [UIColor clearColor];
        praiseLabel.font = [UIFont systemFontOfSize:KD_FONTSIZE_COMMENTANDFORWARD];
        praiseLabel.textColor = MESSAGE_DATE_COLOR;
        [praiseBtn addSubview:praiseLabel];
    }
    
    UILabel *praiseLabel = (UILabel *)[self viewWithTag:KD_TAG_PRAISELABEL];
    praiseLabel.text = @"...";
    
    //@brief This version dont need praise. (Version2.0.0)
    praiseBtn.hidden = YES;
    praiseLabel.hidden = YES;
}

- (void)setShowDigit:(BOOL)showDigit {
    if(showDigit) {
        
        if(!isForwarding_) {
            KDStatusDetailView *subDetailView = (KDStatusDetailView *)[self viewWithTag:KD_TAG_SUBDETAILTWITTERVIEW];
            if(subDetailView) {
                subDetailView.showDigit = YES;
            }
        }else {
            UIButton *commentButton = (UIButton *)[self viewWithTag:KD_TAG_COMMENTBUTTON];
            UIButton *forwardButton = (UIButton *)[self viewWithTag:KD_TAG_FORWARDBUTTON];
            UIButton *praiseButton = (UIButton *)[self viewWithTag:KD_TAG_PRAISEBUTTON];
            
            if(commentButton && forwardButton && praiseButton) {
                UILabel *commentLabel = (UILabel *)[commentButton viewWithTag:KD_TAG_COMMENTLABEL];
                UILabel *forwardLabel = (UILabel *)[forwardButton viewWithTag:KD_TAG_FORWARDLABEL];
                UILabel *praiseLabel = (UILabel *)[praiseButton viewWithTag:KD_TAG_PRAISELABEL];
                
                commentLabel.text = [NSString stringWithFormat:@"%ld", (long)status_.commentsCount];
                forwardLabel.text = [NSString stringWithFormat:@"%ld", (long)status_.forwardsCount];
                praiseLabel.text = [NSString stringWithFormat:@"%d", 0];
                
                [self setNeedsLayout];
            }
        }
    }
    
    showDigit_ = showDigit;
}

- (void)setUpIfExternalStatus {
    KDExtendStatusDetailView *extendStatusView = (KDExtendStatusDetailView *)[self viewWithTag:KD_TAG_EXTENDSTATUSVIEW];
    
    if(!extendStatusView) {
        extendStatusView = [[KDExtendStatusDetailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - 2 * KD_SDV_H_PADDING, 1.0f)];// autorelease];
        extendStatusView.tag = KD_TAG_EXTENDSTATUSVIEW;
        extendStatusView.delegate = self;
        [self addSubview:extendStatusView];
    }
    
    extendStatusView.status = status_.extendStatus;
}

- (void)setBackgroundColor {
    if(isForwarding_) {
        UIImageView *backgroudImageView = (UIImageView *)[self viewWithTag:KD_TAG_BACKGROUNDVIEW];
        if(!backgroudImageView) {
            backgroudImageView = [[UIImageView alloc] initWithImage:[UIImage stretchableImageWithImageName:@"inbox_comment_bg" resizableImageWithCapInsets:UIEdgeInsetsMake(10, 30, 10, 10)]] ;//autorelease];
            backgroudImageView.tag = KD_TAG_BACKGROUNDVIEW;
            [self insertSubview:backgroudImageView atIndex:0];
        }
        [backgroudImageView setFrame:self.bounds];
    }
    //    }else
    //        self.backgroundColor = [UIColor clearColor];
}

/////////////////////////////////////////////////////////////////////////////////
- (void)showImagesGallery:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedPhotoRenderViewWithImageDataSources:)])
        [delegate_ statusDetailView:self clickedPhotoRenderViewWithImageDataSources:status_.compositeImageSource];
}

- (void)attachmentViewClicked:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedAttachmentForStatus:)])
        [delegate_ statusDetailView:self clickedAttachmentForStatus:status_];
}

- (void)commentButtonClicked:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedCommentButtonForStatus:)])
        [delegate_ statusDetailView:self clickedCommentButtonForStatus:status_];
}

- (void)forwardButtonClicked:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedForwardButtonForStatus:)])
        [delegate_ statusDetailView:self clickedForwardButtonForStatus:status_];
}

- (void)praiseButtonClicked:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedPraiseButtonForStatus:)])
        [delegate_ statusDetailView:self clickedPraiseButtonForStatus:status_];
}

- (void)extraMessageImageViewClicked:(id)sender {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedExtraMessageForStatus:)])
        [delegate_ statusDetailView:self clickedExtraMessageForStatus:status_];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat originY = 0.0f;
    
    //top padding
    originY += KD_SDV_V_PADDING;
    
    if(isForwarding_)
        originY += KD_FORWARD_TEXT_PADDING;
    
    //layout core text view
    KDStatusContentDetailView *contentView = (KDStatusContentDetailView *)[self viewWithTag:KD_TAG_STATUSCONTENTVIEW];
    if(contentView && contentView.superview == self) {
        [contentView sizeToFit];
        contentView.frame = CGRectMake(KD_SDV_H_PADDING, originY, self.bounds.size.width - 2 * KD_SDV_H_PADDING, contentView.frame.size.height);
        originY += contentView.frame.size.height;
        
        originY += KD_SDV_V_SPACING;
    }
    
    //layout extra message
    UIView *extraMessageView = (UIView *)[self viewWithTag:KD_TAG_EXTRAIMAGEVIEW];
    if(extraMessageView && extraMessageView.superview == self) {
        //[extraMessageView sizeToFit];
        extraMessageView.frame = CGRectMake(KD_SDV_H_PADDING, originY, extraMessageView.bounds.size.width, extraMessageView.bounds.size.height);
        originY += extraMessageView.frame.size.height;
        
        //may need space
        originY += KD_SDV_V_SPACING;
    }
    
    KDTaskDetailView *taskDetailView = (KDTaskDetailView *)[self viewWithTag:KD_TAG_TASK_DETAIL_VIEW];
    if (taskDetailView && taskDetailView.superview == self) {
        taskDetailView.frame = CGRectMake(KD_SDV_H_PADDING, originY, self.frame.size.width - 2 * KD_SDV_H_PADDING, [taskDetailView height]);
        originY += taskDetailView.bounds.size.height;
        
        //may need space
        originY += KD_SDV_V_SPACING;
    }
    //layout images
    //TODO:uncompleted
    
    int count = (int)[ status_.compositeImageSource.imageSources count];
    if (count == 1) {
        
        if ([[status_.compositeImageSource getTimeLineImageSourceAtIndex:0] isGifImage]) {
            KDGifView *renderView = (KDGifView *)[self viewWithTag:KD_TAG_PHOTORENDERVIEW];
            
            if(renderView && renderView.superview == self) {
                renderView.frame = CGRectMake(KD_SDV_H_PADDING, originY, renderView.frame.size.width, renderView.frame.size.height);
                originY += renderView.frame.size.height;
                NSLog(@"%@",NSStringFromCGRect(renderView.frame));
                //may need space
                originY += KD_SDV_V_SPACING;
            }
        }
        else
        {
            KDStatusPhotoRenderView *photoRenderView = (KDStatusPhotoRenderView *)[self viewWithTag:KD_TAG_PHOTORENDERVIEW];
            if(photoRenderView && photoRenderView.superview == self) {
                photoRenderView.frame = CGRectMake(KD_SDV_H_PADDING, originY, photoRenderView.frame.size.width, photoRenderView.frame.size.height);
                originY += photoRenderView.frame.size.height;
                
                //may need space
                originY += KD_SDV_V_SPACING;
            }
        }
        
        
    } else if(count > 1) {
        KDThumbnailView2 *photoRenderView = (KDThumbnailView2 *)[self viewWithTag:KD_TAG_PHOTORENDERVIEW];
        if(photoRenderView && photoRenderView.superview == self) {
            int count = (int)[ status_.compositeImageSource.imageSources count];
            photoRenderView.frame = CGRectMake((self.bounds.size.width - photoRenderView.frame.size.width) / 2.0f, originY, [KDThumbnailView2 thumbnailSizeWithImageDataSource:status_.compositeImageSource showAll:(count > 1)].width, [KDThumbnailView2 thumbnailSizeWithImageDataSource:status_.compositeImageSource showAll:(count > 1)].height);
            originY += photoRenderView.frame.size.height;
            
            //may need space
            originY += KD_SDV_V_SPACING;
        }
        
    }
    
    
    
    KDMapRenderView *mapRenderView = (KDMapRenderView*)[self viewWithTag:KD_TAG_MAPVIEW];
    if (mapRenderView && mapRenderView.superview == self) {
        mapRenderView.frame = CGRectMake(KD_SDV_H_PADDING, originY, self.bounds.size.width - 2 * KD_SDV_H_PADDING, mapRenderView.frame.size.height);
        originY += mapRenderView.frame.size.height;
        
        //may need space
        originY += 3;
    }
    
    KDLocationView *locationView = (KDLocationView*)[self viewWithTag:KD_TAG_LOCATION];
    if (locationView && locationView.superview == self) {
        
        CGRect frame = locationView.frame;
        frame.origin = CGPointMake(KD_SDV_H_PADDING, originY);
        locationView.frame = frame;
        
        originY += locationView.frame.size.height;
        
        //may need space
        originY += 3;
    }
    
    //layout sub status detail view
    KDStatusDetailView *subStatusDetailView = (KDStatusDetailView *)[self viewWithTag:KD_TAG_SUBDETAILTWITTERVIEW];
    if(subStatusDetailView && subStatusDetailView != self) {
        //        CGFloat subStatusDetailViewHeight = [subStatusDetailView adaptionHeight];
        originY-=6;
        subStatusDetailView.frame = CGRectMake(KD_SDV_H_PADDING, originY, self.bounds.size.width - 2 * KD_SDV_H_PADDING, subStatusDetailView.frame.size.height);
        originY += subStatusDetailView.frame.size.height;
        
        
        //may need space
        originY += KD_SDV_V_SPACING;
    }
    
    //layout extend status (sina)
    KDExtendStatusDetailView *extendStatusDetailView = (KDExtendStatusDetailView *)[self viewWithTag:KD_TAG_EXTENDSTATUSVIEW];
    if(extendStatusDetailView && extendStatusDetailView.superview == self) {
        extendStatusDetailView.frame = CGRectMake(KD_SDV_H_PADDING, originY, extendStatusDetailView.bounds.size.width, extendStatusDetailView.bounds.size.height);
        originY += extendStatusDetailView.frame.size.height;
        
        //may need space
        originY += KD_SDV_V_SPACING;
    }
    
    //layout document view
    //    KDAttachmentIndicatorView *attachmentview = (KDAttachmentIndicatorView *)[self viewWithTag:KD_TAG_DOCUMENTVIEW];
    //    if(attachmentview && attachmentview.superview == self) {
    //        attachmentview.frame = CGRectMake(KD_SDV_H_PADDING, originY, self.frame.size.width - 2 * KD_SDV_H_PADDING, 50.0f);
    //
    //        if(isForwarding_) {
    //            UIImage *image = [UIImage imageNamed:@"attachments_divider.png"];
    //            image = [image stretchableImageWithLeftCapWidth:(image.size.width * 0.5) topCapHeight:0];
    //            [attachmentview setBackgroundImage:nil];
    //            [attachmentview setDividerImage:image];
    //            attachmentview.contentEdgeInsets = UIEdgeInsetsMake(-6.0f, 0.0f, 0.0f, 0.0f);
    //        }else {
    //            attachmentview.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
    //        }
    //
    //        originY += 50.0f;
    //
    //        //may need space
    //        originY += KD_SDV_V_SPACING;
    //    }
    KDDocumentIndicatorView *documentIndicator = (KDDocumentIndicatorView *)[self viewWithTag:KD_TAG_DOCUMENTVIEW];
    if(documentIndicator && documentIndicator.superview == self) {
        documentIndicator.frame = CGRectMake(KD_SDV_H_PADDING, originY, self.frame.size.width - 2 * KD_SDV_H_PADDING, documentIndicator.bounds.size.height);
        
        originY += documentIndicator.bounds.size.height;
        
        //may need space
        originY += KD_SDV_V_SPACING;
    }
    
    
    //layout comment and forwading button
    if(isForwarding_) {
        UIButton *commentButton = (UIButton *)[self viewWithTag:KD_TAG_COMMENTBUTTON];
        UIButton *forwardButton = (UIButton *)[self viewWithTag:KD_TAG_FORWARDBUTTON];
        UIButton *praiseButton = (UIButton *)[self viewWithTag:KD_TAG_PRAISEBUTTON];
        
        if(commentButton && forwardButton && praiseButton) {
            
            //根据tag取得对应的ImageView和label
            UIImageView *commentIconImageView = (UIImageView *)[commentButton viewWithTag:KD_TAG_COMMENTICON];
            UILabel *commentLabel = (UILabel *)[commentButton viewWithTag:KD_TAG_COMMENTLABEL];
            
            UIImageView *forwardIconImageView = (UIImageView *)[forwardButton viewWithTag:KD_TAG_FORWARDICON];
            UILabel *forwardLabel = (UILabel *)[forwardButton viewWithTag:KD_TAG_FORWARDLABEL];
            
            UIImageView *praiseIconImageView = (UIImageView *)[praiseButton viewWithTag:KD_TAG_PRAISEICON];
            UILabel *praiseLabel = (UILabel *)[praiseButton viewWithTag:KD_TAG_PRAISELABEL];
            
            //布局回复按钮
            commentIconImageView.frame = CGRectMake(2.0f, (KD_FORWARD_BUTTONS_HEIGHT - commentIconImageView.image.size.height) * 0.5f, commentIconImageView.image.size.width, commentIconImageView.image.size.height);
            CGSize commentLabelSize = [commentLabel.text sizeWithFont:commentLabel.font constrainedToSize:CGSizeMake(300.0f, commentIconImageView.frame.size.height)];
            commentLabel.frame = CGRectMake(commentIconImageView.frame.origin.x + commentIconImageView.frame.size.width + 2.0f , CGRectGetMidY(commentIconImageView.frame) - commentLabelSize.height * 0.5f, commentLabelSize.width, commentLabelSize.height);
            
            //布局转发按钮
            forwardIconImageView.frame = CGRectMake(2.0f, (KD_FORWARD_BUTTONS_HEIGHT - forwardIconImageView.image.size.height) * 0.5f, forwardIconImageView.image.size.width, forwardIconImageView.image.size.height);
            CGSize forwardLabelSize = [forwardLabel.text sizeWithFont:forwardLabel.font constrainedToSize:CGSizeMake(300.0f, forwardIconImageView.frame.size.height)];
            forwardLabel.frame = CGRectMake(forwardIconImageView.frame.origin.x + forwardIconImageView.frame.size.width + 2.0f, CGRectGetMidY(forwardIconImageView.frame) - forwardLabelSize.height * 0.5f, forwardLabelSize.width, forwardLabelSize.height);
            
            //布局‘赞'按钮
            praiseIconImageView.frame = CGRectMake(2.0f, (KD_FORWARD_BUTTONS_HEIGHT - praiseIconImageView.image.size.height) * 0.5f, praiseIconImageView.image.size.width, praiseIconImageView.image.size.height);
            CGSize praiseLabelSize = [praiseLabel.text sizeWithFont:praiseLabel.font constrainedToSize:CGSizeMake(300.0f, praiseIconImageView.frame.size.height)];
            praiseLabel.frame = CGRectMake(praiseIconImageView.frame.origin.x + praiseIconImageView.frame.size.width + 2.0f, CGRectGetMidY(praiseIconImageView.frame) - praiseLabelSize.height * 0.5f, praiseLabelSize.width, praiseLabelSize.height);
            
            CGSize forwardButtonSize = CGSizeMake(forwardIconImageView.frame.size.width + forwardLabelSize.width + 5.0f, KD_FORWARD_BUTTONS_HEIGHT);
            CGSize commentButtonSize = CGSizeMake(commentIconImageView.frame.size.width + commentLabelSize.width + 5.0f, KD_FORWARD_BUTTONS_HEIGHT);
            CGSize praiseButtonSize = CGSizeMake(praiseIconImageView.frame.size.width + praiseLabelSize.width + 5.0f, KD_FORWARD_BUTTONS_HEIGHT);
            
            commentButton.frame = CGRectMake(self.frame.size.width - commentButtonSize.width - 5.0f, originY, commentButtonSize.width, commentButtonSize.height);
            forwardButton.frame = CGRectMake(commentButton.frame.origin.x - forwardButtonSize.width - 5.0f, originY, forwardButtonSize.width, forwardButtonSize.height);
            praiseButton.frame = CGRectMake(forwardButton.frame.origin.x - praiseButtonSize.width - 5.0f, originY, praiseButtonSize.width, praiseButtonSize.height);
            
            originY += 20.0f;
            
            //may need space
            originY += KD_SDV_V_SPACING;
        }
    }
    
    //layout stampView
    UILabel *stampLable = (UILabel *)[self viewWithTag:KD_TAG_TIMELINE];
    if(stampLable) {
        CGSize stampSize = [stampLable.text sizeWithFont:stampLable.font constrainedToSize:CGSizeMake(300.0f, 20.0f)];
        stampLable.frame = CGRectMake(KD_SDV_H_PADDING, originY, self.bounds.size.width - 2 * KD_SDV_H_PADDING, stampSize.height);
        originY += stampSize.height;
    }
    
    //bottom padding
    if(!isForwarding_)
        originY += 2.0f;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, originY);
    [self setBackgroundColor];
    
    if([self.superview isKindOfClass:[KDStatusDetailView class]])
        [self.superview setNeedsLayout];
    else {
        if(delegate_ && [delegate_ respondsToSelector:@selector(update)])
            [delegate_ update];
    }
}

- (void)goToMapViewController {
    if(status_) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showMapViewController:status_ sender:self];
    }
}

- (void)mapRenderViewTapped:(UIGestureRecognizer *)rgzr {
    [self goToMapViewController];
}

- (void)locatonViewTapped:(UIGestureRecognizer *)rgzr {
    [self goToMapViewController];
}

#pragma mark -
#pragma KDStatusPhotoRenderView delegate Method
- (void)statusPhotoRenderView:(KDStatusPhotoRenderView *)photoRenderView didFinishLoadImage:(UIImage *)image {
    if(image) {
        photoRenderView.frame = (CGRect){photoRenderView.frame.origin,{photoRenderView.frame.size.width, image.size.height * 0.5f}};
        [self setNeedsLayout];
    }
}
#pragma mark -
#pragma mark KDGifViewDelegate delegate Method
- (void)gifViewLayOut
{
    [self setNeedsDisplay];
}
#pragma mark -
#pragma KDExtendStatusDetailView delegate method
- (void)extendStautsDetailView:(KDExtendStatusDetailView *)detailView showImageGallery:(id<KDImageDataSource>)imageSources {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedPhotoRenderViewWithImageDataSources:)])
        [delegate_ statusDetailView:self clickedPhotoRenderViewWithImageDataSources:imageSources];
}

#pragma mark - KDDocumentIndicatorViewDelegate method
- (void)documentIndicatorView:(KDDocumentIndicatorView *)div didClickedAtAttachment:(KDAttachment *)attachment {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedAttachment:)]) {
        [delegate_ statusDetailView:self clickedAttachment:attachment];
    }
}

- (void)didClickMoreInDocumentIndicatorView:(KDDocumentIndicatorView *)div {
    if(delegate_ && [delegate_ respondsToSelector:@selector(statusDetailView:clickedAttachmentForStatus:)]) {
        [delegate_ statusDetailView:self clickedAttachmentForStatus:status_];
    }
}


@end