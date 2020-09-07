//
//  KDInboxCell.h
//  kdweibo
//
//  Created by bird on 13-7-12.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDInbox.h"
#import "KDUserAvatarView.h"
#import "KDInboxRenderView.h"
#import "KDDMThreadAvatarView.h"
#import "KDBadgeIndicatorView.h"

@protocol KDInboxCellDelegate <NSObject>
-(void)replyWithInbox:(KDInbox *) inbox; // 回复
-(void)mentionWithInbox:(KDInbox *) inbox; // 提及
@end

@interface KDInboxCell : UITableViewCell
{
    UIView           *backgroundView_;
    KDInbox *inbox_;
    KDInboxInteractiveType type_;
    
    KDUserAvatarView *userAvatarView_;

    UILabel *nameLabel_;
    UILabel *dateLabel_;
    KDInboxRenderView *renderView_;
    UILabel *sourceLabel_;

    UIButton *statusImage_;
    
    KDBadgeIndicatorView *badgeIndicatorView_;
    
    UIView *highlightedView_;
}
@property(nonatomic, retain) KDInbox *inbox;
@property(nonatomic, assign, readonly) KDInboxInteractiveType type;
@property(nonatomic, retain, readonly) KDUserAvatarView *userAvatarView;
@property (nonatomic, assign) id<KDInboxCellDelegate> delegate;

+ (CGFloat)messageInteractiveCellHeight:(KDInbox *)inbox;
@end
