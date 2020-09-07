//
//  ChatBubbleCell.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChatBubbleView.h"
#import "KDUserAvatarView.h"

#import "KDChatConstant.h"

#define KD_DM_MESSAGE_DATE_FONT_SIZE     12.0 // the font size for created date of direct message

#define KD_DM_MESSAGE_FONT_SIZE          16.0 // the font size for normal direct message
#define KD_DM_SYSTEM_MESSAGE_FONT_SIZE   12.0 // the font size for system direct message

#define KD_DM_MESSAGE_TEXT_BODY          @"textBody"

@protocol ChatBubbleCellDelegate;

@interface ChatBubbleCell : UITableViewCell {
@private    
    id<ChatBubbleCellDataSource> message_;
    ChatBubbleView *detailsView_;
//    id<ChatBubbleCellDelegate> delegate_;
}

@property (nonatomic, retain) id<ChatBubbleCellDataSource> message;
@property (nonatomic, assign) id<ChatBubbleCellDelegate> delegate;
@property (nonatomic, retain, readonly) KDUserAvatarView *avatarView;
@property (nonatomic, retain, readonly) ChatBubbleView *detailsView;

+ (CGSize) directMessageSizeInCell:(id<ChatBubbleCellDataSource> )message;
+ (CGFloat)directMessageHeightInCell:(id<ChatBubbleCellDataSource> )message interval:(int)diff;

- (void)sendWarnningMessage;

@end


@protocol ChatBubbleCellDelegate <NSObject>

@optional
- (void)didTapWarnningImageInChatBubbleCell:(ChatBubbleCell *)cell;

@end