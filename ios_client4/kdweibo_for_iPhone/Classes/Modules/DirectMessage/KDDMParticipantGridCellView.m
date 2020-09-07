//
//  KDDMParticipantGridCellView.m
//  kdweibo
//
//  Created by Tan yingqi on 12-11-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDDMParticipantGridCellView.h"
#import "KDUserAvatarView.h"


@interface KDDMParticipantGridCellView () {
    BOOL loadedImage_;
}
@property(nonatomic,retain)UILabel *label;
@property(nonatomic,retain)KDUserAvatarView *avatarView;
@property(nonatomic,retain)UIButton *deleteBtn;

@end
@implementation KDDMParticipantGridCellView

@synthesize label = label_;
@synthesize user = user_;
@synthesize avatarView = avatarView_;
@synthesize deleteBtn = deleteBtn_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.clipsToBounds = NO;
        //        CGRect rect = self.bounds;
        //        rect.size.height = 47;
        //        rect.origin.y = 14;
        KDUserAvatarView *aAvatarView = [KDUserAvatarView avatarView];
        //aAvatarView.frame = rect;
        aAvatarView.contentMode = UIViewContentModeScaleAspectFit;
        [aAvatarView addTarget:self action:@selector(avatarViewTappped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:aAvatarView];
        
        self.avatarView = aAvatarView;
        
        //        rect = self.bounds;
        //        rect.origin.y = rect.size.height - 20;
        //        rect.size.height = 20;
        UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        aLabel.font = [UIFont systemFontOfSize:14];
        aLabel.backgroundColor = [UIColor clearColor];
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        aLabel.textColor = RGBCOLOR(62.f, 62.f, 62.f);
        [self addSubview:aLabel];
        self.label = aLabel;
//        [aLabel release];
        
        //rect = self.bounds;
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dm_paticipant_delete"]];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"dm_paticipant_delete"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.deleteBtn = btn;
        [btn sizeToFit];
        //btn.center = CGPointMake(CGRectGetWidth(rect)-2, 2);
        [self addSubview:btn];
        btn.hidden = YES;
        
    }
    return self;
}

- (void)layoutSubviews {
    CGRect rect = self.bounds;
    rect.size.height = 48;
    rect.size.width = 48;
    rect.origin.y = 14;
    rect.origin.x = 6;
    self.avatarView.frame = rect;
    
    rect = self.bounds;
    rect.origin.y = CGRectGetMaxY(self.avatarView.frame) +4;
    rect.size.height = 20;
    rect.size.width-=14;
    rect.origin.x = 6;
    self.label.frame = rect;
    
    
    [self.deleteBtn sizeToFit];
    
    rect = self.deleteBtn.bounds;
    self.deleteBtn.center= CGPointMake(CGRectGetWidth(self.bounds)-CGRectGetWidth(rect)*0.5, CGRectGetHeight(rect)*0.5);
}

- (void)btnTapped:(id)sender {
    DLog(@"btn tapped");
    //[self avatarViewTappped:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:KDDMParticipantShouldDeleted object:self userInfo:nil];
}



- (void)setUser:(KDUser *)user {
    if (user_ != user) {
//        [user_ release];
        user_ = user;// retain];
        
        self.avatarView.avatarDataSource = user_;
        if(!self.avatarView.hasAvatar){
            [self.avatarView setLoadAvatar:YES];
        }
        
        label_.text = user_.screenName;
    }
}

- (void)avatarViewTappped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:KDDMPaticipantGridCellAvatarDidTouched object:self userInfo:nil];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(user_);
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(label_);
    //KD_RELEASE_SAFELY(deleteBtn_);
    
    //[super dealloc];
}

- (void)changedToEdited {
    self.deleteBtn.hidden = NO;
}

- (void)recoveredFromEdited {
    self.deleteBtn.hidden = YES;
}
@end
