//
//  KDInvitePhoneContactView.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-31.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDInvitePhoneContactView.h"

@implementation KDInvitePhoneContactView
{
    KDInvitePhoneContactViewClickedBlock block_;
    
    //weak reference below
    UIButton *bgButton_;
}

- (id)initWithFrame:(CGRect)frame andClickedBlock:(KDInvitePhoneContactViewClickedBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        block_ = block;
    }
    return self;
}

- (void)dealloc
{
//    Block_release(block_);
    //[super dealloc];
}

- (void)setupView
{
    bgButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    bgButton_.backgroundColor = RGBCOLOR(32, 192, 0);
    bgButton_.layer.cornerRadius = 5.0f;
    bgButton_.layer.masksToBounds = YES;
    bgButton_.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [bgButton_ setTitle:ASLocalizedString(@"KDInvitePhoneContactView_invite_friend")forState:UIControlStateNormal];
    [bgButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bgButton_ setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 0.0f)];
    [bgButton_ addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [UIImage imageNamed:@"add_phone_contact_icon_v3.png"];
    [bgButton_ setImage:image forState:UIControlStateNormal];
    [bgButton_ setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30.0f)];
    
    [self addSubview:bgButton_];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    bgButton_.frame = self.bounds;
}

+ (CGSize)defaultSize
{
    return CGSizeMake(305.0f, 41.0f);
}

- (void)buttonClicked:(id)sender
{
    if(block_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block_(sender);
        });
    }
}

@end
