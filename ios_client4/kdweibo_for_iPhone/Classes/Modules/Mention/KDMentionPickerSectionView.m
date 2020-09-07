//
//  KDMentionPickerSectionView.m
//  kdweibo
//
//  Created by laijiandong on 12-11-2.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDMentionPickerSectionView.h"

@implementation KDMentionPickerSectionView

@synthesize backgroundImageView=backgroundImageView_;
@synthesize sectionLabel=sectionLabel_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupMentionPickerSectionView];
    }
    
    return self;
}

- (void)_setupMentionPickerSectionView {
    // background image view
    CGRect frame = self.bounds;
    frame.size.height = 0.5;
    UIImage *image = [UIImage imageNamed:@"home_page_cell_separator_bg"];
    UIImageView *topSeparatorView = [[UIImageView alloc] initWithImage:image];
    topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    topSeparatorView.frame = frame;
    [self addSubview:topSeparatorView];
//    [topSeparatorView release];
    
    frame.origin.y = self.bounds.size.height - 0.5;
    UIImageView *bottomSeparatorView =[[UIImageView alloc] initWithImage:image];
    bottomSeparatorView.frame = frame;
    bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:bottomSeparatorView];
//    [bottomSeparatorView release];
    
    // section label
    sectionLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionLabel_.backgroundColor = [UIColor clearColor];
    sectionLabel_.textColor = [UIColor grayColor];
    sectionLabel_.font = [UIFont systemFontOfSize:15.0];
    
    [self addSubview:sectionLabel_];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    sectionLabel_.frame = CGRectMake(10.0, 0.0, self.bounds.size.width, self.bounds.size.height);
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(backgroundImageView_);
    //KD_RELEASE_SAFELY(sectionLabel_);
    
    //[super dealloc];
}

@end


