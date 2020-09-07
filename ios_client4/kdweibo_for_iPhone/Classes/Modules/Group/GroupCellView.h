//
//  GroupCellView.h
//  TwitterFon
//
//  Created by apple on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDGroup.h"
#import "GroupViewController.h"
#import "KDBadgeView.h"

#import "KDGroupAvatarView.h"


@interface GroupCellView : KDTableViewCell {
@private
    GroupViewController *groupViewController_; // weak reference
    
    KDGroup *group_;
    NSUInteger unreadCount_;
    
    KDGroupAvatarView *avatarView_;
    UILabel *nameLabel_;
    UILabel *announcementLabel_;
    
    KDBadgeView *badgeIndicatorView_;
    
//    UIImageView *cellAccessoryImageView_;
    
    UIView *separatorView_;
    
}

@property (nonatomic, strong) UIImageView *cellAccessoryImageView;
@property (nonatomic, strong) GroupViewController *groupController;

@property (nonatomic, strong) KDGroup *group;
@property (nonatomic, assign) NSUInteger unreadCount;

@property (nonatomic, strong,readonly) KDGroupAvatarView *avatarView;
@property (nonatomic, strong) UIImageView *tickImageView;

@end


@interface GroupImageButton:UIButton
{
    UIImage *profileImage;
    
}
@property(nonatomic,retain)UIImage *profileImage;
@end