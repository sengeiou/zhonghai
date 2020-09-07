//
//  KDStatusDetailView.h
//  kdweibo
//
//  Created by shen kuikui on 12-12-10.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDStatus.h"
#import "KDStatusPhotoRenderView.h"
#import "KDExtendStatusDetailView.h"
#import "KDStatusCoreTextDelegate.h"

@protocol KDStatusDetailViewDelegate;

@interface KDStatusDetailView : UIView<KDStatusPhotoRenderViewDelegate, KDExtendStatusDetailViewDelegate>

@property (nonatomic, retain) KDStatus *status;
@property (nonatomic, assign) id<KDStatusDetailViewDelegate> delegate;
@property (nonatomic, assign) BOOL isForwarding;
@property (nonatomic, assign) BOOL showGroupName;
@property (nonatomic, assign) BOOL showDigit;

@end

@protocol KDStatusDetailViewDelegate <NSObject, KDStatusCoreTextDelegate>

- (void)update;

@optional

- (void)statusDetailView:(KDStatusDetailView *)detailView clickedCommentButtonForStatus:(KDStatus *)forwardingStatus;
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedForwardButtonForStatus:(KDStatus *)forwardingStatus;
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedPraiseButtonForStatus:(KDStatus *)forwardingStatus;

- (void)statusDetailView:(KDStatusDetailView *)detailView clickedAttachment:(KDAttachment *)attachment;
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedAttachmentForStatus:(KDStatus *)statusWithAttachments;
- (void)statusDetailView:(KDStatusDetailView *)detailView clickedPhotoRenderViewWithImageDataSources:(id<KDImageDataSource>)imageSources;

- (void)statusDetailView:(KDStatusDetailView *)detailView clickedExtraMessageForStatus:(KDStatus *)statusWithExtraMessage;

@end
