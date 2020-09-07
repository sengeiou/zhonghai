//
//  KDTimelineStatusCell.m
//  kdweibo
//
//  Created by laijiandong on 12-9-27.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDTimelineStatusCell.h"

@interface KDStatusContainerView ()

@property(nonatomic, retain) KDStatusContainerView *containerView;

@end

@implementation KDTimelineStatusCell

@dynamic status;

@synthesize containerView=containerView_;
@dynamic avatarView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        containerView_ = [[KDStatusContainerView alloc] initWithFrame:CGRectZero];
        [super.contentView addSubview:containerView_];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    containerView_.frame = super.contentView.bounds;
}

- (void)setStatus:(KDStatus *)status {
    containerView_.status = status;
}

- (KDStatus *)status {
    return containerView_.status;
}

- (KDUserAvatarView *)avatarView {
    return containerView_.avatarView;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(containerView_);
    
    //[super dealloc];
}

@end
