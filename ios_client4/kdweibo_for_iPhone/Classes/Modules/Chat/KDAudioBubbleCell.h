//
//  KDAudioBubbleCell.h
//  kdweibo
//
//  Created by shen kuikui on 13-5-13.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDDMMessage.h"
#import "KDUserAvatarView.h"
#import "KDChatConstant.h"
#import "KDDownloadManager.h"

typedef enum {
    KDAudioBubbleCellStateNormal = 0 << 0,
    KDAudioBubbleCellStateLoading = 1 << 0, //uploading or downloading
    KDAudioBubbleCellStatePlaying = 1 << 1,
    KDAudioBubbleCellStateSendFailed = 1 << 2,
}KDAudioBubbleCellState;

@protocol KDAudioBubbleCellDelegate;

@interface KDAudioBubbleCell : UITableViewCell<KDDownloadListener>
{
@private
    KDDMMessage *message_;
    KDUserAvatarView *avatarView_;
    
    UILabel     *createdAtLabel_;
    UILabel     *timeLabel_;
    UILabel     *nameLabel_;
    UIImageView *bgImageView_;
    UIImageView *speakerImageView_;
    UIImageView *warningImageView_;
    UIImageView *unreadImageView_;
    UIActivityIndicatorView *loadingIndicatorView_;
    
    BOOL postByMyself_;
    KDAudioBubbleCellState state_;
    
//    id<KDAudioBubbleCellDelegate> delegate_;
    
    KDMockDownloadListener *listener_;
    
    Float64 duration_;
}

@property (nonatomic, retain) KDDMMessage *message;
@property (nonatomic, retain, readonly) KDUserAvatarView *avatarView;
@property (nonatomic, assign) id<KDAudioBubbleCellDelegate> delegate;

- (void)setSpeakerLevel:(CGFloat)lvl;

- (void)turnOnState:(KDAudioBubbleCellState)st;
- (void)turnOffState:(KDAudioBubbleCellState)st;

- (void)loadAudio;

+ (CGFloat)heightForAudioInMessage:(KDDMMessage *)message interval:(NSTimeInterval)interval;

@end

@protocol KDAudioBubbleCellDelegate <NSObject>

- (void)audioBubbleCellTapInSpeaker:(KDAudioBubbleCell *)audioBubbleCell;
- (void)audioBubbleCellTapInWarning:(KDAudioBubbleCell *)audioBubbleCell;

@end