//
//  KDPersonHeaderView.m
//  kdweibo
//
//  Created by wenbin_su on 15/9/8.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPersonHeaderView.h"

@interface KDPersonHeaderView ()
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation KDPersonHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.backgroundView];
        [self.scrollView addSubview:self.photoView];
        [self.scrollView addSubview:self.nameLabel];
    }
    return self;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    }
    return _scrollView;
}

- (UIImageView *)photoView {
    if (_photoView == nil) {
        _photoView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_scrollView.bounds) - 70.0) / 2, 71.0, 70.0, 70.0)];
        _photoView.layer.cornerRadius = 6.0;
        _photoView.layer.masksToBounds = YES;
        _photoView.layer.borderWidth = 2.0;
        _photoView.layer.borderColor = FC6.CGColor;
        _photoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return _photoView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(_photoView.frame) + [NSNumber kdDistance1], CGRectGetWidth(_scrollView.bounds), 18.0)];
        _nameLabel.font = FS2;
        _nameLabel.textColor = FC6;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.autoresizingMask = _photoView.autoresizingMask;
    }
    return _nameLabel;
}

- (UIImageView *)backgroundView {
    if (_backgroundView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [UIImage imageNamed:@"profile_bg_top_male"];
        _backgroundView = imageView;
    }
    return _backgroundView;
}

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset {
    CGRect frame = self.scrollView.frame;
    
    if (offset.y > 0) {
        frame.origin.y = MAX(offset.y * 0.5, 0);
        self.scrollView.frame = frame;
        self.clipsToBounds = YES;
    }
    else {
        CGFloat delta = 0.0f;
        CGRect rect = self.bounds;
        delta = fabs(MIN(0.0f, offset.y));
        rect.origin.y -= delta;
        rect.size.height += delta;
        self.scrollView.frame = rect;
        self.clipsToBounds = NO;
    }
}

@end

