//
//  KDTeamPageViewController.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const KDTeamInvitationFinishedNotification;
UIKIT_EXTERN NSString *const KDTeamInvitationOnceNotification;

typedef NS_ENUM(NSInteger, KDTeamPageContentType) {
    KDTeamPageContentType_CreatAndJoin = 0x01 << 0,
    KDTeamPageContentType_InviteMe = 0x01 << 1,
    KDTeamPageContentType_MyTeams  = 0x01 << 2,
    KDTeamPageContentType_MyApplyingTeams = 0x01 << 3
};

@interface KDTeamPageViewController : UIViewController

@property (nonatomic, retain, readonly) NSMutableArray *allMyTeams;
@property (nonatomic, retain, readonly) NSMutableArray *allInvitation;
@property (nonatomic, retain, readonly) NSMutableArray *allMyApplyingTeams;

- (id)initWithContentType:(KDTeamPageContentType)ct;

@end
