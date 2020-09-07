//
//  ChatBubbleView.m
//  kdweibo
//
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "ChatBubbleView.h"

#import "ChatBubbleCell.h"

#import "KDWeiboAppDelegate.h"
#import "ResourceManager.h"

#import "KDCache.h"
#import "KDDefaultViewControllerContext.h"
#import "NSDate+Additions.h"
#import "KDUtility.h"
#import <QuartzCore/QuartzCore.h>


#define MAP_IMAGE_BASE_URL   @"http://st.map.soso.com/api"
#define MAP_IMAGE_SIZE_X2  @"440*340"
#define MAP_IMAGE_SIZE     @"220*170"

#define MAP_RENDER_VIEW_WIDTH   220.0f
#define MAP_RENDER_VIEW_HEIGHT  170.0f

@interface ChatBubbleView()

@property(nonatomic, retain) KDUserAvatarView *avatarView;
@property(nonatomic, retain) UILabel *createdAtLabel;
@property(nonatomic, retain) KDExpressionLabel *detailsLabel;
@property(nonatomic, retain) UILabel *nameLabel;

@property(nonatomic, retain) KDThumbnailView *thumbnailView;
@property(nonatomic, retain) KDThumbnailView2*thumbnailView2;
@property(nonatomic, retain) UIImageView *multipleImageFlagView;
@property(nonatomic, retain) KDAttachmentIndicatorView *attachmentIndicatorView;
@property(nonatomic, retain) KDMapRenderView *mapRenderView;
@property(nonatomic, retain) UILabel         *mapAddressLabel;

@property (nonatomic, retain) UIImageView *bgImageView;


- (void) addMenuControllerHideNotification;
- (void) removeMenuControllerHideNotification;

@end


@implementation ChatBubbleView

@synthesize cell=cell_;

@synthesize avatarView=avatarView_;
@synthesize createdAtLabel=createdAtLabel_;
@synthesize detailsLabel=detailsLabel_;
@synthesize nameLabel = nameLabel_;

@synthesize thumbnailView=thumbnailView_;
@synthesize thumbnailView2=thumbnailView2_;
@synthesize multipleImageFlagView=multipleImageFlagView_;
@synthesize attachmentIndicatorView=attachmentIndicatorView_;
@synthesize mapRenderView = mapRenderView_;
@synthesize mapAddressLabel = mapAddressLabel_;

@synthesize bgImageView=bgImageView_;

void buttonClicked(NSString *url) {
    [[KDWeiboAppDelegate getAppDelegate] openWebView:url];
}

- (void) setupDirectMessageDetailsView {
    // background image view

    bgImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:bgImageView_];
    
    // avatar view
    avatarView_ = [KDUserAvatarView avatarView];// retain];
    avatarView_.showVipBadge = NO;
    avatarView_.layer.cornerRadius = 6;
    avatarView_.layer.masksToBounds = YES;
    
    [avatarView_ addTarget:self action:@selector(showUserProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:avatarView_];
    
    // created at label
    createdAtLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    createdAtLabel_.backgroundColor = RGBCOLOR(203.0, 203.0, 203.0);
    createdAtLabel_.textColor = [UIColor whiteColor];
    createdAtLabel_.font = [UIFont systemFontOfSize:KD_DM_SYSTEM_MESSAGE_FONT_SIZE];
    createdAtLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    createdAtLabel_.textAlignment = NSTextAlignmentCenter;
    createdAtLabel_.alpha = 0.8;
    createdAtLabel_.layer.masksToBounds = YES;
    createdAtLabel_.layer.cornerRadius = 5.0;
    
    [self addSubview:createdAtLabel_];
    
    // message details label
    detailsLabel_ = [[KDExpressionLabel alloc] initWithFrame:CGRectZero andType:KDExpressionLabelType_URL | KDExpressionLabelType_Expression urlRespondFucIfNeed:buttonClicked];
    detailsLabel_.backgroundColor = [UIColor blackColor];
    
    detailsLabel_.textColor = [UIColor blackColor];
    detailsLabel_.font = [UIFont systemFontOfSize:KD_DM_MESSAGE_FONT_SIZE];
    
    [self addSubview:detailsLabel_];
    
    //name label (screen name or user name)
    nameLabel_ = [[UILabel alloc] init];
    nameLabel_.textColor = MESSAGE_NAME_COLOR;
    nameLabel_.backgroundColor = [UIColor clearColor];
    nameLabel_.font = [UIFont systemFontOfSize:12.0f];
    
    [self addSubview:nameLabel_];
    
    // thumbnail view
    thumbnailView_ = [KDThumbnailView thumbnailViewWithSize:[KDImageSize defaultThumbnailImageSize]];// retain];
    [self addSubview:thumbnailView_];
    
    thumbnailView2_ = [KDThumbnailView2 thumbnailViewWithSize:[KDImageSize defaultThumbnailImageSize]]; //retain];
    [self addSubview:thumbnailView2_];
    
    // multiple image flag view
    UIImage *image = [UIImage imageNamed:@"many_thumbnail_in_cell.png"];
    multipleImageFlagView_ = [[UIImageView alloc] initWithImage:image];
    multipleImageFlagView_.bounds = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    [self addSubview:multipleImageFlagView_];
    
    // attachments indicator view
    attachmentIndicatorView_ = [[KDAttachmentIndicatorView alloc] initWithFrame:CGRectZero];
    attachmentIndicatorView_.hidden = YES;
    
    image = [UIImage imageNamed:@"attachments_divider.png"];
    image = [image stretchableImageWithLeftCapWidth:(image.size.width * 0.5) topCapHeight:0];
    [attachmentIndicatorView_ setDividerImage:image];
    
    [self addSubview:attachmentIndicatorView_];
    
    indicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView_.hidden = YES;
    [self addSubview:indicatorView_];
    
    messageSendFailedImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dm_audio_cell_warning_v2"]];
    [messageSendFailedImageView_ sizeToFit];
    messageSendFailedImageView_.hidden = YES;
    [self addSubview:messageSendFailedImageView_];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
//    [tap release];
    
    // long press gesture recognizer
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    gestureRecognizer.minimumPressDuration = 0.35;
    [self addGestureRecognizer:gestureRecognizer];
//    [gestureRecognizer release];
    
    [self setClipsToBounds:YES];
}

- (void)setupMapRenderView {
    
    if(!mapRenderView_) {
        mapRenderView_ = [[KDMapRenderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MAP_RENDER_VIEW_WIDTH, MAP_RENDER_VIEW_HEIGHT)];
        mapRenderView_.delegate = self;
        mapRenderView_.layer.cornerRadius = 20.0f;
        mapRenderView_.layer.masksToBounds = YES;
        
        [self addSubview:mapRenderView_];
    }
    
    KDImageSource *source = [[KDImageSource alloc] init];
    source.thumbnail = [NSString stringWithFormat:@"%@?size=%@&center=%f,%f&zoom=%d&markers=%f,%f,red",MAP_IMAGE_BASE_URL,[[KDUtility defaultUtility] isHighResolutionDevice]?MAP_IMAGE_SIZE_X2:MAP_IMAGE_SIZE,cell_.message.longitude,cell_.message.latitude,[[KDUtility defaultUtility] isHighResolutionDevice]?16:13,cell_.message.longitude,cell_.message.latitude];
    KDCompositeImageSource *imageSource = [[KDCompositeImageSource alloc] initWithImageSources:@[source]];
//    [source release];
    mapRenderView_.imageDataSource = imageSource;
//    [imageSource release];
    
    if(!mapAddressLabel_) {
        mapAddressLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 170.0f, 18.0f)];
        mapAddressLabel_.backgroundColor = [UIColor clearColor];
        mapAddressLabel_.font = [UIFont systemFontOfSize:16.0f];
        mapAddressLabel_.numberOfLines = 1.f;
        mapAddressLabel_.textAlignment = NSTextAlignmentCenter;
    }
    

    mapAddressLabel_.textColor = [UIColor blackColor];
    
    mapAddressLabel_.text = [cell_.message address];
    [mapAddressLabel_ sizeToFit];
    
    UITapGestureRecognizer *rgzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapRenderViewTapped:)];
    [mapRenderView_ addGestureRecognizer:rgzr];
//    [rgzr release];
    
    [self addSubview:mapAddressLabel_];
}


- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        cell_ = nil;
        postByMe_ = NO;
        monitoringMenuControllerHide_ = NO;
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame cell:(ChatBubbleCell *)cell {
    self = [self initWithFrame:frame];
    if (self) {
        cell_ = cell;
        
        [self setupDirectMessageDetailsView];
    }
    
    return self;
}


#define KD_DM_DETAILS_AVATAR_SIZE_WH    40.0
#define KD_DM_DETAILS_AVATAR_PADDING    8.0

#define KD_DM_DETAILS_BACKGOUND_IMAGE_CALLOUT_W    30.0

- (void) layoutBackgroundImageView {
    CGFloat offsetX = 0.0;
    CGFloat bgHeight = 0;
    id<ChatBubbleCellDataSource> message = cell_.message;
   
    CGFloat messageTextWidth = [ChatBubbleCell directMessageSizeInCell:message].width;
    
    CGFloat bgWidth = messageTextWidth;
    
    if(!thumbnailView_.hidden){
        // if there are many images in this direct message,
        // An multiple image identifier occur at right side
        CGFloat padding = (message.compositeImageSource != nil && [message.compositeImageSource imageSources].count > 0) ? 20.0 : 0.0;
        CGFloat multiPadding = (message.compositeImageSource != nil && [message.compositeImageSource imageSources].count > 1) ? 20.0 : 0.0;
        
        CGFloat imageWith = thumbnailView_.bounds.size.width;
        
        if(bgWidth < imageWith + padding){
            bgWidth = imageWith + padding + multiPadding;
        }
    }
    else if(!thumbnailView2_.hidden)
    {
        CGFloat padding = (message.compositeImageSource != nil && [message.compositeImageSource imageSources].count > 0) ? 20.0 : 0.0;
        
        CGFloat imageWith = thumbnailView2_.bounds.size.width;
        
        if(bgWidth < imageWith + padding){
            bgWidth = imageWith + padding;
        }

    }
    
    if(!attachmentIndicatorView_.hidden){
        if(bgWidth < 160.0){
            bgWidth = 160.0;
        }
    }
    
    bgWidth += 36.0;
    
     CGSize textSize = [ChatBubbleCell directMessageSizeInCell:message];
       bgHeight +=(textSize.height + 22);
    
     if (!attachmentIndicatorView_.hidden) {
        bgHeight+= 60;
     }
    
    if(!thumbnailView_.hidden && multipleImageFlagView_.hidden && [message.message isEqualToString:ASLocalizedString(@"ChatBubbleView_tips_1")]) {
        CGSize imageSize = thumbnailView_.thumbnailView.image.size;
        CGFloat aspectRatio = imageSize.height / imageSize.width;
        
        if(imageSize.height > imageSize.width) {
            imageSize.height = 100;
            imageSize.width = imageSize.height / aspectRatio;
        }else {
            imageSize.width = 100;
            imageSize.height = imageSize.width * aspectRatio;
        }

       
        bgWidth = imageSize.width + 35.0f;
        bgHeight = imageSize.height + 25.0f;
    }else if(!thumbnailView_.hidden || !thumbnailView2_.hidden) {
        
        CGSize size = thumbnailView_.hidden?thumbnailView2_.bounds.size:thumbnailView_.thumbnailView.image.size;
        
        CGSize imageSize = aspectScaleConstrainedSize(size, CGSizeMake(100.0f, 100.0f));
        
        bgHeight += (imageSize.height + 10.0f);
    }
    
    if ([message hasLocationInfo]) {
        bgHeight = MAP_RENDER_VIEW_HEIGHT + 20 + 23.0f;
    }
    CGRect rect = CGRectZero;
    CGFloat avatarAnchorX = avatarView_.frame.origin.x;
    
    offsetX = postByMe_ ? (avatarAnchorX - KD_DM_DETAILS_AVATAR_PADDING - bgWidth)
                        : (avatarAnchorX + avatarView_.bounds.size.width + KD_DM_DETAILS_AVATAR_PADDING);
    
    bgHeight = MAX(bgHeight, avatarView_.bounds.size.height + (postByMe_ ? 8.0f : 4.0f));
    
    rect = CGRectMake(offsetX, CGRectGetMaxY(nameLabel_.frame) + 5.0f, bgWidth, bgHeight);
    bgImageView_.frame = rect;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0;
    CGFloat width = self.bounds.size.width;
    CGFloat stageWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGRect rect = CGRectZero;
    offsetX = postByMe_ ? (width - KD_DM_DETAILS_AVATAR_PADDING - KD_DM_DETAILS_AVATAR_SIZE_WH) : KD_DM_DETAILS_AVATAR_PADDING;
    
    // creation date label
    if(!createdAtLabel_.hidden){
        rect = createdAtLabel_.bounds;
        rect.size.width += 10.0;
        rect.origin = CGPointMake(3.0 + (stageWidth - rect.size.width) * 0.5, offsetY);
        
        createdAtLabel_.frame = rect;
        
        offsetY = 36.0;
    }
    
    if(cell_.message.isSystemMessage){
        offsetY += 5.0;
        
        rect.size = [ChatBubbleCell directMessageSizeInCell:cell_.message];
        rect.origin = CGPointMake((stageWidth - rect.size.width) * 0.5, offsetY);
        detailsLabel_.frame = rect;
        
        return;
    }
    
    // avatar view
    rect = CGRectMake(offsetX, offsetY, KD_DM_DETAILS_AVATAR_SIZE_WH, KD_DM_DETAILS_AVATAR_SIZE_WH);
    avatarView_.frame = rect;
    
    [nameLabel_ sizeToFit];
    
    
    offsetX = postByMe_ ? (avatarView_.frame.origin.x - KD_DM_DETAILS_AVATAR_PADDING * 2 - nameLabel_.bounds.size.width) : (CGRectGetMaxX(avatarView_.frame) + KD_DM_DETAILS_AVATAR_PADDING * 2);
    if(postByMe_)
    {
        nameLabel_.hidden = YES;
        offsetY -= 20;
    }else{
        nameLabel_.hidden = NO;
    }
    nameLabel_.frame = CGRectMake(offsetX, offsetY, CGRectGetWidth(nameLabel_.bounds), CGRectGetHeight(nameLabel_.bounds));
    [self layoutBackgroundImageView];
    
    // direct message text
    rect = bgImageView_.frame;
    
    if(indicatorView_) {
        if(postByMe_) {
            indicatorView_.frame = CGRectMake(CGRectGetMinX(rect) - 5.0f - indicatorView_.bounds.size.width, (self.frame.size.height - indicatorView_.bounds.size.height) * 0.5f, indicatorView_.bounds.size.width, indicatorView_.bounds.size.height);
        }else {
            indicatorView_.frame = CGRectMake(CGRectGetMaxX(rect) + 5.0f, (self.frame.size.height - indicatorView_.bounds.size.height) * 0.5f, indicatorView_.bounds.size.width, indicatorView_.bounds.size.height);
        }
    }
    
    if(messageSendFailedImageView_) {
        CGRect sendFailedImageViewFrame = CGRectMake(0.0f, (bgImageView_.frame.size.height - messageSendFailedImageView_.bounds.size.height) * 0.5f + CGRectGetMinY(bgImageView_.frame), messageSendFailedImageView_.bounds.size.width, messageSendFailedImageView_.bounds.size.height);
        if (postByMe_) {
            sendFailedImageViewFrame.origin.x = CGRectGetMinX(rect) - 5.0f - messageSendFailedImageView_.bounds.size.width;
        }else {
            sendFailedImageViewFrame.origin.x = CGRectGetMaxX(rect) + 5.0f;
        }
        
        messageSendFailedImageView_.frame = sendFailedImageViewFrame;
    }
    
    offsetX = rect.origin.x + (postByMe_ ? 16 : 20);
    offsetY = rect.origin.y + 4.0f;
    
    id<ChatBubbleCellDataSource> message = cell_.message;
   
    CGSize textSize = [ChatBubbleCell directMessageSizeInCell:message];
    CGFloat textWidth = textSize.width;
    rect = CGRectMake(offsetX, offsetY, textWidth, textSize.height);
    
    //当文本较少时，垂直居中
    if(bgImageView_.frame.size.height == (avatarView_.frame.size.height + (postByMe_ ? 8.0f : 6.0f))) {
        //当背景图的高度为最小值时，一般来说只可能包含文本，但是也不能排除用户发送的图片(height : width) -> 0.
        CGFloat thumbnailHeight = 0.0f;
        if(!thumbnailView_.hidden) {
            thumbnailHeight = aspectScaleConstrainedSize(thumbnailView_.thumbnailView.image.size, CGSizeMake(100.0f, 100.0f)).height;
        }else if(!thumbnailView2_.hidden)
            thumbnailHeight = aspectScaleConstrainedSize(thumbnailView2_.bounds.size, CGSizeMake(100.0f, 100.0f)).height;
        
        rect.origin.y = (bgImageView_.frame.size.height - thumbnailHeight - textSize.height) * 0.5f + CGRectGetMinY(bgImageView_.frame);         if (postByMe_) {
                rect.origin.y += 2.f;
            }else {
                rect.origin.y += 2.f;
            }
    }else {
        rect.origin.y += 6.0f;
    }
    
    detailsLabel_.frame = rect;
    
    if([message hasLocationInfo]) {
        detailsLabel_.hidden = YES;
        if(mapRenderView_) {
            CGSize imageSize = mapRenderView_.imageView.image.size;
            if(!CGSizeEqualToSize(imageSize, CGSizeMake(50, 50))) {
                imageSize = CGSizeMake(MAP_RENDER_VIEW_WIDTH, MAP_RENDER_VIEW_HEIGHT);
            }
            
            mapRenderView_.frame = CGRectMake(CGRectGetMinX(bgImageView_.frame) + (bgImageView_.bounds.size.width - imageSize.width) * 0.5f, (bgImageView_.bounds.size.height - imageSize.height - 23.0f) * 0.6f + CGRectGetMinY(bgImageView_.frame), imageSize.width, imageSize.height);
            mapAddressLabel_.frame = CGRectMake(CGRectGetMinX(bgImageView_.frame) + (bgImageView_.bounds.size.width - MAP_RENDER_VIEW_WIDTH) * 0.5f, CGRectGetMaxY(bgImageView_.frame) - 18.f - 5.0f, MAP_RENDER_VIEW_WIDTH, 18.0f);
        }
    }else {
        detailsLabel_.hidden = NO;
    }
    
    if(!(!thumbnailView_.hidden && multipleImageFlagView_.hidden && message.message.length > 0)) {
        offsetY += rect.size.height + 15.0f;
    }
    
    if(!thumbnailView_.hidden){
        CGSize imageSize = thumbnailView_.thumbnailView.image.size;
        CGFloat aspectRatio = imageSize.height / imageSize.width;
        
        if(aspectRatio > 1.0) {
            imageSize.height = 100;
            imageSize.width = imageSize.height / aspectRatio;
        }else {
            imageSize.width = 100;
            imageSize.height = imageSize.width * aspectRatio;
        }
        
        if(!thumbnailView_.hidden && multipleImageFlagView_.hidden && message.message.length > 0) {
            if ([message.message isEqualToString:ASLocalizedString(@"ChatBubbleView_tips_1")]) { //单图不显示文字
                detailsLabel_.hidden = YES;
                offsetY += (CGRectGetHeight(bgImageView_.frame) - imageSize.height) * 0.5;
            }else { //单图显示文字
                offsetY += rect.size.height + 15.0f;;
            }
            
            offsetX = bgImageView_.frame.origin.x + (bgImageView_.bounds.size.width - imageSize.width) * 0.5f;
        }
        
        rect.size = imageSize;
        
        rect.origin.y = offsetY;
        rect.origin.x = offsetX;
        
        thumbnailView_.frame = rect;
        
        if(!multipleImageFlagView_.hidden){
            rect = multipleImageFlagView_.frame;
            rect.origin.x = bgImageView_.frame.origin.x + bgImageView_.bounds.size.width - rect.size.width - 10.f;
            rect.origin.y = thumbnailView_.frame.origin.y + (thumbnailView_.thumbnailView.image.size.height - rect.size.height);
            multipleImageFlagView_.frame = rect;
        }
        
        offsetY += thumbnailView_.bounds.size.height + 5.0;
    }
    else if(!thumbnailView2_.hidden)
    {
        CGSize imageSize = [KDThumbnailView2 thumbnailSizeWithImageDataSource:message.compositeImageSource showAll:YES];
        rect.size = imageSize;
        
        rect.origin.y = offsetY;
        rect.origin.x = offsetX;
        
        thumbnailView2_.frame = rect;
        
        offsetY += thumbnailView2_.bounds.size.height + 5.0;
    }
    
    if(!attachmentIndicatorView_.hidden){
        width = MAX(160.0, textWidth);
        rect = CGRectMake(offsetX, offsetY, width, 1.0);
        rect.size.height = [KDAttachmentIndicatorView defaultAttachmentIndicatorViewHeight];
        attachmentIndicatorView_.frame = rect;
    }
}

- (void) changeMessageBodyBackgroundImage:(BOOL)pressed {
    NSString *imageName = nil;
    
    imageName = postByMe_ ? @"message_bg_speak_right" : @"message_bg_picture_left";
    
    UIImage *bgImage = [UIImage imageNamed:imageName];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:0.7 * bgImage.size.width topCapHeight:0.7 * bgImage.size.height];
    bgImageView_.image = bgImage;
}

- (void)toggleVisibleState:(BOOL)isSystemMessage {
    BOOL hidden = isSystemMessage ? YES : NO;
    
    avatarView_.hidden = hidden;
    thumbnailView_.hidden = hidden;
    thumbnailView2_.hidden = hidden;
    multipleImageFlagView_.hidden = hidden;
    bgImageView_.hidden = hidden;
}

- (void)determinUploading {
    
     id<ChatBubbleCellDataSource>  message = cell_.message;
    
    if([message isSending]) {
        [self setShowLoadingOrNot:YES];
        messageSendFailedImageView_.hidden = YES;
    }else {
        [self setShowLoadingOrNot:NO];
        if([message isSendFailure])
            messageSendFailedImageView_.hidden = NO;
        else
            messageSendFailedImageView_.hidden = YES;
    }
    
}
- (void) refresh {
    id<ChatBubbleCellDataSource> message = cell_.message;
    
    postByMe_ = [KDWeiboAppDelegate isLoginUserID:message.sender.userId];
    
    if([message hasLocationInfo]) {
        [self setupMapRenderView];
    }
    
    [self determinUploading];
    
    BOOL showCreationDate = [[message propertyForKey:@"kddmmessage_is_need_stamp"] boolValue];
    createdAtLabel_.hidden = !showCreationDate;
    if (showCreationDate) {
        createdAtLabel_.text = [NSDate formatMonthOrDaySince1970:message.createdAtTime];
        [createdAtLabel_ sizeToFit];
    }
    
    NSString *textBody = [message propertyForKey:KD_DM_MESSAGE_TEXT_BODY];
    if (textBody == nil) {
        textBody = message.message;
    }
    
    
    [self toggleVisibleState:message.isSystemMessage];
    
    
    
    if (message.isSystemMessage) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        detailsLabel_.layer.cornerRadius = 10.0;
        
        [CATransaction commit];
        
        detailsLabel_.alpha = 0.8;
        
        detailsLabel_.backgroundColor = RGBCOLOR(203.0, 203.0, 203.0);
        detailsLabel_.textColor = [UIColor whiteColor];
        detailsLabel_.textAlignment = NSTextAlignmentCenter;
        detailsLabel_.font = [UIFont systemFontOfSize:KD_DM_SYSTEM_MESSAGE_FONT_SIZE];
        detailsLabel_.text = textBody;
        
        multipleImageFlagView_.hidden = YES;
        thumbnailView_.hidden = YES;
        thumbnailView2_.hidden = YES;
        attachmentIndicatorView_.hidden = YES;
        
        [self setNeedsLayout];
        
        // If this message post by system, return directly
        return;
    
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        detailsLabel_.layer.cornerRadius = 0.0;
        
        [CATransaction commit];
        
        detailsLabel_.alpha = 1.0;
        
        detailsLabel_.backgroundColor = [UIColor clearColor];
        detailsLabel_.textColor = [UIColor blackColor];
        detailsLabel_.textAlignment = NSTextAlignmentLeft;
        detailsLabel_.font = [UIFont systemFontOfSize:KD_DM_MESSAGE_FONT_SIZE];
        detailsLabel_.text = textBody;
    }
    
    NSString *senderName = message.sender.screenName;
    if(!senderName) {
        senderName = message.sender.username;
    }
    nameLabel_.text = senderName;
    
    avatarView_.avatarDataSource = message.sender;
    
    [self changeMessageBodyBackgroundImage:NO];
    
    
    BOOL hasImageSource = (message.compositeImageSource != nil && [message.compositeImageSource hasImageSource]);
    
    thumbnailView2_.hidden = ![message hasVideo];
    thumbnailView_.hidden = [message hasVideo];
    
    if ([message hasVideo]) {
        
        thumbnailView2_.imageDataSource = hasImageSource?message.compositeImageSource : nil;
        thumbnailView2_.hidden = !hasImageSource;
        
        if (hasImageSource) {
            CGSize size = [KDThumbnailView2 thumbnailSizeWithImageDataSource:message.compositeImageSource];
            thumbnailView2_.frame = CGRectMake(0, 0, size.width, size.height);
        }
        
        multipleImageFlagView_.hidden = YES;
        attachmentIndicatorView_.hidden = YES;
    }
    else
    {
        thumbnailView_.imageDataSource = hasImageSource ? message.compositeImageSource : nil;
        thumbnailView_.hidden = !hasImageSource;
        
        if (hasImageSource) {
            CGSize size = [KDThumbnailView thumbnailSizeWithImageDataSource:message.compositeImageSource];
            thumbnailView_.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        }
        
        multipleImageFlagView_.hidden = (hasImageSource && [message.compositeImageSource hasManyImageSource]) ? NO : YES;
        
        NSUInteger attachmentsCount = (message.attachments != nil) ? [message.attachments count] : 0;
        attachmentIndicatorView_.attachmentsCount = attachmentsCount;
        attachmentIndicatorView_.hidden = (attachmentsCount > 0) ? NO : YES;
    }
    
    [self setNeedsLayout];
}


- (void)setShowLoadingOrNot:(BOOL)show {
    if(indicatorView_) {
        if(show) {
            indicatorView_.hidden = NO;
            [indicatorView_ startAnimating];
        }else {
            indicatorView_.hidden = YES;
            [indicatorView_ stopAnimating];
        }
    }
}

- (void) showUserProfile:(id)sender{
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:cell_.message.sender sender:sender];
}


////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark UIMenuController show/dismiss

- (void) didLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(!cell_.message.isSystemMessage &&cell_.message.message.length>0&& ![cell_.message.message isEqualToString:NSLocalizedString(@"SHARING_PHOTOS", @"")]&&![cell_.message.message isEqualToString:NSLocalizedString(@"SHARING_LOCATION", @"")]&& UIGestureRecognizerStateBegan == gestureRecognizer.state){
        CGPoint anchorPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
        CGRect containerRect = bgImageView_.frame;
        if(CGRectContainsPoint(containerRect, anchorPoint)){
            // show menu controller
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            if([self becomeFirstResponder] && !menuController.menuVisible){
                UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY_TEXT", @"") action:@selector(copyText:)];// autorelease];
//                UIMenuItem *menuItem2 = [[[UIMenuItem alloc] initWithTitle:ASLocalizedString(@"KDDefaultViewControllerContext_to_task")  action:@selector(convertToTask:)] autorelease];
                NSArray *menuItems = @[menuItem];//,menuItem2];
                
                menuController.menuItems = menuItems;
                
                CGRect anchorRect = CGRectMake(containerRect.origin.x + containerRect.size.width * 0.5,
                                               anchorPoint.y,
                                               0.0, 0.0);
                
                [menuController setTargetRect:anchorRect inView:self];
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                CGPoint toWindowPoint = [window convertPoint:anchorPoint fromView:self];
                menuController.arrowDirection = UIMenuControllerArrowUp;
                if (toWindowPoint.y > 110) {
                    menuController.arrowDirection = UIMenuControllerArrowDown;
                }
               
                [menuController setMenuVisible:YES animated:YES];
                
                [self changeMessageBodyBackgroundImage:YES];
                
                [self addMenuControllerHideNotification];
            }
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)recog {
    CGPoint p = [recog locationInView:self];
    
    if(messageSendFailedImageView_.hidden == NO) {
        if(CGRectContainsPoint(messageSendFailedImageView_.frame, p)){
            [cell_ sendWarnningMessage];
        }
    }
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copyText:) ||(action == @selector(convertToTask:))) ? YES : NO;
}

- (void)convertToTask:(id)sender {
    if(cell_.message) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showCreateTaskViewController:cell_.message type:KDCreateTaskReferTypeDMMessge sender:self];
    }
}

- (void) copyText:(id)sender {
    [[UIPasteboard generalPasteboard] setString:detailsLabel_.text];
}

- (void) addMenuControllerHideNotification {
    if(!monitoringMenuControllerHide_){
        monitoringMenuControllerHide_ = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerWillHide:) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}

- (void) removeMenuControllerHideNotification {
    if(monitoringMenuControllerHide_){
        monitoringMenuControllerHide_ = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
        //iOS7 下必须手动调用，否则crash 王松 2013-11-22
        [self resignFirstResponder];
        [self changeMessageBodyBackgroundImage:NO];
    }
}

- (void) menuControllerWillHide:(NSNotification *)notification {
    [self removeMenuControllerHideNotification];
}

+ (CGFloat)dmAttachmentsIndicatorButtonHeight {
    return [KDAttachmentIndicatorView defaultAttachmentIndicatorViewHeight];
}

- (void)mapRenderViewTapped:(UIGestureRecognizer *)rgzr {
    if(cell_.message) {
        [[KDDefaultViewControllerContext defaultViewControllerContext] showMapViewController:cell_.message sender:self];
    }
}

#pragma mark -KDMapRenderViewDelegate Methods
- (void)mapRenderView:(KDMapRenderView *)view didLoadImage:(UIImage *)image {
    [self setNeedsLayout];
}



- (void)dealloc {
    [self removeMenuControllerHideNotification];
    
    cell_ = nil;
    //KD_RELEASE_SAFELY(thumbnailView2_);
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(createdAtLabel_);
    //KD_RELEASE_SAFELY(detailsLabel_);
    //KD_RELEASE_SAFELY(nameLabel_);
    
    //KD_RELEASE_SAFELY(thumbnailView_);
    //KD_RELEASE_SAFELY(multipleImageFlagView_);
    //KD_RELEASE_SAFELY(attachmentIndicatorView_);
    //KD_RELEASE_SAFELY(mapRenderView_);
    //KD_RELEASE_SAFELY(mapAddressLabel_);
    //KD_RELEASE_SAFELY(indicatorView_);
    //KD_RELEASE_SAFELY(messageSendFailedImageView_);
    
    //KD_RELEASE_SAFELY(bgImageView_);
    
    //[super dealloc];
}

@end
