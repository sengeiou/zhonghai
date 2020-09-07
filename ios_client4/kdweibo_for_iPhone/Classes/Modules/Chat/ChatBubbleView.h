//
//  ChatBubbleView.h
//  kdweibo
//
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "KDUserAvatarView.h"
#import "KDThumbnailView.h"
#import "KDAttachmentIndicatorView.h"
#import "KDMapRenderView.h"
#import "KDExpressionLabel.h"
#import "KDDMMessage.h"
#import "KDThumbnailView2.h"
#import "ChatBubbleCellDataSource.h"

@class ChatBubbleCell;
@class KDAttachmentIndicatorView;

@interface ChatBubbleView : UIView<KDMapRenderViewDelegate> {
@private
//    ChatBubbleCell *cell_; // weak reference
    
    KDUserAvatarView *avatarView_;
    UILabel *createdAtLabel_;
    KDExpressionLabel *detailsLabel_;
    
    KDThumbnailView *thumbnailView_;
    KDThumbnailView2 *thumbnailView2_;
    UIImageView *multipleImageFlagView_;
    KDAttachmentIndicatorView *attachmentIndicatorView_;
    
    KDMapRenderView *mapRenderView_;
    UILabel         *mapAddressLabel_;
    
    UIActivityIndicatorView *indicatorView_;
    UIImageView  *messageSendFailedImageView_;
    
    UIImageView *bgImageView_;
    
    BOOL postByMe_;
    BOOL monitoringMenuControllerHide_;
}

@property(nonatomic, assign) ChatBubbleCell *cell;
@property(nonatomic, retain, readonly) KDUserAvatarView *avatarView;
@property(nonatomic, retain, readonly) KDThumbnailView *thumbnailView;
@property(nonatomic, retain, readonly) KDThumbnailView2 *thumbnailView2;
@property(nonatomic, retain, readonly) KDAttachmentIndicatorView *attachmentIndicatorView;
@property(nonatomic, retain, readonly) KDMapRenderView *mapRenderView;

- (id) initWithFrame:(CGRect)frame cell:(ChatBubbleCell *)cell;

- (void) refresh;

- (void)setShowLoadingOrNot:(BOOL)loading;

+ (CGFloat)dmAttachmentsIndicatorButtonHeight;
- (void)determinUploading;
@end
