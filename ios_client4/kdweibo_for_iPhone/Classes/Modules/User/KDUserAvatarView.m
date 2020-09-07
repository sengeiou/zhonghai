//
//  KDUserAvatarView.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-21.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDUserAvatarView.h"

#import "KDUser.h"
#import "KDManagerContext.h"

@implementation KDUserAvatarView

// Override
- (void) didChangeAvatarDataSource {
    if(!super.showVipBadge) return;
    
    UIImage *badgeImage = nil;
    id dataSource = super.avatarDataSource;
    if ([dataSource isKindOfClass:[KDUser class]]) {
        KDUser *user = (KDUser *)super.avatarDataSource;
        
//if([[KDManagerContext globalManagerContext].communityManager isCompanyDomain])
//{
        if(user.isTeamUser){
            badgeImage = [UIImage imageNamed:@"vip_blue_badge.png"];
        }
//        }
//        else {
//            if (![[KDManagerContext globalManagerContext].communityManager isTeamDomain]) {
//                if(!user.isPublicUser){
//                    badgeImage = [UIImage imageNamed:@"vip_orange_badge.png"];
//                }
//            }
//          
//        }
    }
    [super updateVipBadgeWithImage:badgeImage];
     
}

/*
- (void)layoutAvatar {
    maskView_.frame = CGRectInset(self.bounds, 2.0, 2.0);
    avatarView_.frame = maskView_.bounds;
}
*/

/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAvatarLoader delegate methods

// Override
- (UIImage *)defaultAvatar {
    return [UIImage imageNamed:@"user_default_portrait.png"];
}

- (void) dealloc {
    //[super dealloc];
}

@end
