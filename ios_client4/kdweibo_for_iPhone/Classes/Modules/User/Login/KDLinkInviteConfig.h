//
//  KDLinkInviteConfig.h
//  kdweibo
//
//  Created by bird on 14-9-23.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, LinkInviteErrorCode) {
    LinkInviteErrorCode_Success = 0,
    LinkInviteErrorCode_InvaildToken = 1,
    LinkInviteErrorCode_CompanyAlreadyIn,
    LinkInviteErrorCode_WaitingForApproval,
    LinkInviteErrorCode_Undefine
};


@protocol KDLinkInviteDataSource <NSObject>
- (BOOL)checkInvitedCompany:(NSString *)eid;
- (NSString *)invitedPersonInfo;
@end

@protocol KDLinkInviteDelegate <NSObject>
- (void)inviteFinishedBecauseOfAlreadyInCompany:(NSString *)eid;
@end

@interface KDLinkInviteConfig : NSObject
@property (nonatomic, assign, readonly) BOOL isExistInvite;
@property (nonatomic, retain) id extraInfo;
@property (nonatomic, assign) id<KDLinkInviteDelegate> delegate;
@property (nonatomic, retain) NSString *openId;
@property (nonatomic, assign) LinkInviteErrorCode code;

@property (nonatomic, assign) BOOL presented;

+ (KDLinkInviteConfig *)sharedInstance;
- (BOOL)isAvailableInviteFromUrl:(NSURL *)url;
- (void)goToInviteFormType:(Invite_From)type;
- (NSString *)eid;

- (void)cancelInvite;
- (void)inviteFinished;
- (void)waitForCheck:(id)data;
@end
