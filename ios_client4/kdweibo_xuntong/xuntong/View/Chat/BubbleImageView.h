//
//  BubbleImageView.h
//  ContactsLite
//
//  Created by Gil on 13-3-8.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTRoundProgressView.h"

@class BubbleImageView;
@class BubbleTableViewCell;
@protocol BubbleImageViewDelegate <NSObject>
@optional
- (void)bubbleDidDeleteMsg:(BubbleImageView *)bubbleImageView cell:(BubbleTableViewCell *)cell;
//撤回
- (void)cancelMsg:(BubbleImageView *)bubbleImageView cell:(BubbleTableViewCell *)cell;

//多选模式下勾选
- (void)bubbleDidCheckInMultiSelect:(BubbleImageView *)bubbleImageView cell:(BubbleTableViewCell *)cell isCheck:(BOOL)isCheck;


@end

@protocol ForwardDelegate <NSObject>
- (void)forward:(id)sender;
- (void)collect:(id)sender;
- (void)changeToTask:(id)sender;
- (void)forwardText:(id)sender;
- (void)forwardPicture:(id)sender;
- (void)forwardNew:(id)sender;
- (void)forwardLocation:(id)sender;
- (void)mark:(id)sender;
@end

@class RecordDataModel;
@interface BubbleImageView : UIImageView <XTRoundProgressViewDelegate>

@property (nonatomic,weak) BubbleTableViewCell *cell;
@property (nonatomic,strong) RecordDataModel *record;
@property (nonatomic,weak) id<BubbleImageViewDelegate> delegate;
@property (nonatomic,weak) id<ForwardDelegate> forwardDelegate;

//得到ticket数据
@property (nonatomic, strong) MCloudClient *mCloudClient;//KDWebViewTypeTicket

- (void)copyText:(id)sender;

- (void)changeToTask:(id)sender;

- (void)changeToBidaTask:(id)sender;

- (void)forward:(id)sender;

- (void)forwardText:(id)sender;

- (void)forwardPicture:(id)sender;

- (void)forwardNew:(id)sender;

- (void)forwardLocation:(id)sender;

- (void)forwardShortVideo:(id)sender;

- (void)shareToCommunity:(id)sender;

- (void)shareToOther:(id)sender;

- (void)collect:(id)sender;

- (void)deleteBubbleCell:(id)sender;

- (void)cancelMsg:(id)sender;

- (void)reply:(id)sender;

- (void)mark:(id)sender;
@end

