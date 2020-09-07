//
//  KDStatusFromGroupTipView.m
//  kdweibo
//
//  Created by Tan yingqi on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDStatusFromGroupTipView.h"
@interface KDStatusFromGroupTipView()
@property(nonatomic,retain)UIImageView *arrowImageView;
@end

@implementation KDStatusFromGroupTipView
@synthesize arrowImageView = arrowImageView_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *bgImage = [UIImage imageNamed:@"status_group_flag_bg"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5f topCapHeight:bgImage.size.height * 0.5f];
        background_ = [[UIImageView alloc] initWithImage:bgImage];
        background_.frame = self.bounds;
        background_.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:background_];
        
        arrowImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_group_flag_arrow"]];
        [self addSubview:arrowImageView_];
        
        
        groupNameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
        groupNameLabel_.textColor = MESSAGE_DATE_COLOR;
        groupNameLabel_.backgroundColor = [UIColor clearColor];
        groupNameLabel_.font = [UIFont systemFontOfSize:13.0f];
        [self addSubview:groupNameLabel_];
        
        lock_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_group_flag_lock"]];
        [self addSubview:lock_];
    }
    return self;
}

- (id)initWithGroupName:(NSString *)groupName {
    self = [super initWithFrame:CGRectZero];
    if(self) {
        [self setupViewWithGroupName:groupName];
    }
    
    return self;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(arrowImageView_);
    //KD_RELEASE_SAFELY(groupNameLabel_);
    //KD_RELEASE_SAFELY(lock_);
    //KD_RELEASE_SAFELY(background_);
    
    //[super dealloc];
}

- (void)setupViewWithGroupName:(NSString *)groupName {
      groupNameLabel_.text = groupName;
     //[self setNeedsLayout];
}

- (void)layoutSubviews {

    [arrowImageView_ sizeToFit];
    [groupNameLabel_ sizeToFit];
    [lock_ sizeToFit];
    
    CGRect frame = arrowImageView_.frame;
    frame.origin.x = 14;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))*0.5;
    arrowImageView_.frame = frame;
    
    
    frame = lock_.frame;
    frame.origin.x = CGRectGetWidth(self.bounds)- CGRectGetWidth(frame) - 10;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))*0.5;
    lock_.frame = frame;
    
    frame = groupNameLabel_.frame;
    frame.origin.x = CGRectGetMaxX(arrowImageView_.frame) + 14;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))*0.5;
    frame.size.width = CGRectGetWidth(self.bounds) - 70;
    groupNameLabel_.frame = frame;
}

+ (CGSize)sizeWithText:(NSString *)text constrainedWidth:(CGFloat) width {
    CGRect rect = textboundsByContrainedWidth(width - 72, [UIFont systemFontOfSize:13.0], text);
    rect.size.height = 26;
    rect.size.width +=72;
    return rect.size;
}
@end
