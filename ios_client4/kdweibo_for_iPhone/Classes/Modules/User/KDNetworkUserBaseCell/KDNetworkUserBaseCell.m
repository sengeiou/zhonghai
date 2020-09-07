//
//  KDNetworkUserBaseCell.m
//  kdweibo
//
//  Created by Guohuan Xu on 5/10/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDNetworkUserBaseCell.h"
#import "KDUser.h"

#import "ResourceManager.h"
#import "KDDefaultViewControllerContext.h"

@interface KDNetworkUserBaseCell ()

@property (nonatomic, retain) KDUserAvatarView *avatarView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *departmentLabel;

@end

@implementation KDNetworkUserBaseCell

@dynamic user;

@synthesize avatarView=avatarView_;
@synthesize nameLabel=nameLabel_;
@synthesize separatorView=separatorView_;
@synthesize departmentLabel = departmentLabel_;

@dynamic allowedShowUserProfile;


- (void) setupUserCell {
    avatarView_ = [KDUserAvatarView avatarView];// retain];
    [avatarView_ addTarget:self action:@selector(showUserProfile:) forControlEvents:UIControlEventTouchUpInside];
    avatarView_.enabled = allowedShowUserProfile_;
    
    [super.contentView addSubview:avatarView_];
    
	nameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
	nameLabel_.backgroundColor=[UIColor clearColor];
	nameLabel_.font = [UIFont systemFontOfSize:16];
	nameLabel_.textColor = [UIColor blackColor];
    nameLabel_.highlightedTextColor = [UIColor whiteColor];
	
    [super.contentView addSubview:nameLabel_];
    
    departmentLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    departmentLabel_.textColor = MESSAGE_ACTNAME_COLOR;
    departmentLabel_.highlightedTextColor = [UIColor whiteColor];
    departmentLabel_.font = [UIFont systemFontOfSize:14.0f];
    departmentLabel_.backgroundColor = [UIColor clearColor];
    
    [super.contentView addSubview:departmentLabel_];
    
//    separatorView_ = [[UIView alloc] initWithFrame:CGRectZero];
//    separatorView_.backgroundColor = RGBCOLOR(203, 203, 203);
//    [super.contentView addSubview:separatorView_];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        allowedShowUserProfile_ = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self setBackgroundColor:[ResourceManager defaultRowBackGroudColor]];
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 45, 0, 0);
        [self setupUserCell];
    }
    
    return self;
}
#define avatarView_WH 48.0
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    CGFloat offsetX = 10.0;
    CGFloat offsetY = 10.0;
    rect = CGRectMake(offsetX, (CGRectGetHeight(self.bounds) - avatarView_WH) * 0.5, avatarView_WH, avatarView_WH);
    avatarView_.frame = rect;
    
    offsetX += CGRectGetWidth(avatarView_.frame) +10.f;
    rect = CGRectMake(offsetX, offsetY, CGRectGetWidth(self.frame) - offsetX, 16.0);
    nameLabel_.frame = rect;
    
    offsetY += CGRectGetHeight(nameLabel_.frame) + 12.f;
    rect = CGRectMake(offsetX, offsetY, 195.f, 15.f);
    departmentLabel_.frame = rect;
    separatorView_.frame = CGRectMake(0.0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5);
}

- (void)setUser:(KDUser*)user {
    if(user_ != user){
//        [user_ release];
        user_ = user;// retain];
        
        avatarView_.avatarDataSource = user_;
        
        nameLabel_.text = user_.username;
        departmentLabel_.text = user_.department;
    }
}

- (KDUser *)user {
    return user_;
}

- (void)setAllowedShowUserProfile:(BOOL)allowedShowUserProfile {
    if(!!allowedShowUserProfile_ != !!allowedShowUserProfile){
        allowedShowUserProfile_ = allowedShowUserProfile;
        
        avatarView_.enabled = allowedShowUserProfile_;
    }
}

- (BOOL)allowedShowUserProfile {
    return allowedShowUserProfile_;
}

- (void)showUserProfile:(id)sender {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:user_  sender:sender];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    nameLabel_.highlighted = selected;
    departmentLabel_.highlighted = selected;
}

- (void)dealloc {
	//KD_RELEASE_SAFELY(user_);
    
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(nameLabel_);
    //KD_RELEASE_SAFELY(departmentLabel_);
    //KD_RELEASE_SAFELY(separatorView_);
    
    //[super dealloc];
}

@end
