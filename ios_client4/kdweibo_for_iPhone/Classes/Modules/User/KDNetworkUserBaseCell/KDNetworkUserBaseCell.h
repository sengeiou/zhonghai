//
//  KDNetworkUserBaseCell.h
//  kdweibo
//
//  Created by Guohuan Xu on 5/10/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KDUserAvatarView.h"

@class KDUser;

@interface KDNetworkUserBaseCell : KDTableViewCell {
@private
    KDUser *user_;
    
    KDUserAvatarView *avatarView_;
    UILabel *nameLabel_;
    UILabel *departmentLabel_;
	UIView *separatorView_;
    
    BOOL allowedShowUserProfile_;
}

@property (nonatomic, retain) KDUser *user;
@property (nonatomic, retain, readonly) KDUserAvatarView *avatarView;
@property (nonatomic, retain, readonly) UILabel *nameLabel;
@property (nonatomic, retain, readonly) UILabel *departmentLabel;
@property (nonatomic, retain, readonly) UIView *separatorView;

@property (nonatomic, assign) BOOL allowedShowUserProfile;

@end
