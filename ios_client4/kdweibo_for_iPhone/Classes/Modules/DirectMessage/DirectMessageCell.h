//
//  DirectMessageCell.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectMessageCellView.h"
//#import "DirectMessage.h"

#import "KDDMThreadAvatarView.h"

#import "KDDMThread.h"
#import "KDInbox.h"

#import "KDDMThreadAvatarView.h"

#import "SWTableViewCell.h"

@interface DirectMessageCell : SWTableViewCell  {
@private    
    KDDMThread *dmThread_;
    KDInbox    *dmInbox_;
    DmType     type_;
    
    KDDMThreadAvatarView *avatarView_;
    DirectMessageCellView *detailsView_;
//    id delegate_;
}

@property(nonatomic, retain) KDDMThread *dmThread;
@property(nonatomic, retain) KDInbox    *dmInbox;
@property(nonatomic, retain, readonly) KDDMThreadAvatarView *avatarView;
@property(nonatomic, assign) id delegate;

- (void)update;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons;

@end
