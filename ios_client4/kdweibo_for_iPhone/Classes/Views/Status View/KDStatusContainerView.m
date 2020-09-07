//
//  KDStatusContainerView.m
//  kdweibo
//
//  Created by laijiandong on 12-9-26.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDStatusContainerView.h"

#import "KDStatus.h"

#import "KDDefaultViewControllerContext.h"

@interface KDStatusContainerView ()

@property(nonatomic, retain) KDUserAvatarView *avatarView;
@property(nonatomic, retain) KDStatusContentView *contentView;

@end


@implementation KDStatusContainerView

@dynamic status;

@synthesize avatarView=avatarView_;
@synthesize contentView=contentView_;
@dynamic thumbnailView;
@dynamic dividerView;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContainerView];
    }
    
    return self;
}

- (void)setupContainerView {
    //self.backgroundColor = UIColorFromRGB(0xF0F0F0);;
    
    // content view
    contentView_ = [[KDStatusContentView alloc] initWithFrame:CGRectZero];
    //contentView_.backgroundColor = [UIColor clearColor];
    
    [self addSubview:contentView_];
    
    // avatar view
    avatarView_ = [KDUserAvatarView avatarView] ;//retain];
    //avatarView_.enabled = NO;

    [avatarView_ addTarget:self action:@selector(didTapOnAvatarView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:avatarView_];
    
    // divider view
    [self setDividerWithImage:[UIImage imageNamed:@"home_page_cell_separator_bg.png"]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // margin left and top both is 10
    CGFloat offsetX = 10.0;
    CGFloat offsetY = 10.0;
    CGRect rect = CGRectMake(offsetX, offsetY, KD_USER_AVATAR_DEFAULT_SIZE, KD_USER_AVATAR_DEFAULT_SIZE); // avatar size
    avatarView_.frame = rect;
    
    offsetX += rect.size.width + 8.0;
    rect = CGRectMake(offsetX, 0.0, self.bounds.size.width - offsetX - 14.0, self.bounds.size.height); // margin right is 5.0
    contentView_.frame = rect;
    
    rect.origin.y = self.bounds.size.height-0.5;
    rect.size.height = 0.5;
    
    dividerView_.frame = rect;
}

- (KDThumbnailView2 *)thumbnailView {
    return [contentView_.bodyView currentVisibleThumbnailView];
}

- (void)setDividerView:(UIView *)dividerView {
    if (dividerView_ != dividerView) {
        if (dividerView_ != nil) {
            if (dividerView_.superview != nil) {
                [dividerView_ removeFromSuperview];
            }
            
//            [dividerView_ release];
        }
        
        dividerView_ = dividerView;// retain];
        
        if (dividerView_ != nil) {
            [self addSubview:dividerView_];
        }
    }
}

- (UIView *)dividerView {
    return dividerView_;
}

- (void)setDividerWithImage:(UIImage *)image {
    if (image != nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView sizeToFit];
        
        self.dividerView = imageView;
//        [imageView release];
    
    } else {
        self.dividerView = nil;
    }
}

- (void)update {
    avatarView_.avatarDataSource = status_.author;
    [contentView_ updateWithStatus:status_];
    
    [self setNeedsLayout];
}

- (void)setStatus:(KDStatus *)staus {
    if(status_ != staus){
//        [status_ release];
        status_ = staus;// retain];
    }
    
    [self update];
}

- (KDStatus *)status {
    return status_;
}

- (void)didTapOnAvatarView:(id)sender {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:status_.author sender:sender];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(status_);
    
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(contentView_);
    //KD_RELEASE_SAFELY(dividerView_);
    
    //[super dealloc];
}

@end
