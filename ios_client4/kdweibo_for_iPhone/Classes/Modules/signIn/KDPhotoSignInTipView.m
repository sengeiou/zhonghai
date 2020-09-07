//
//  KDPhotoSignInTipView.m
//  kdweibo
//
//  Created by lichao_liu on 6/23/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDPhotoSignInTipView.h"

@interface KDPhotoSignInTipView()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy)id signInPhotoTipBlock;
@end

@implementation KDPhotoSignInTipView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title block:(SigninPhotoTipBlock)block
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor =  [UIColor clearColor];
        [self addSubview:self.contentView];
        [self addSubview:self.titleLabel];
        self.titleLabel.text = title;
        self.signInPhotoTipBlock = block;
        [self setUpVFL];
    }
    return self;
}

- (UILabel *)titleLabel
{
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _titleLabel;
}

- (UIView *)contentView
{
    if(!_contentView)
    {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor =  [UIColor colorWithHexRGB:@"0a3554"];
        _contentView.alpha = 0.5;
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentView;
}

- (void)setUpVFL
{
    NSDictionary *views = @{@"contentView":self.contentView};
    NSArray *vfls = @[@"|[contentView]|",@"V:|[contentView]|"];
    for (NSString *vflStr in vfls) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vflStr
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                      attribute:NSLayoutAttributeCenterX
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeCenterX
                                                     multiplier:1
                                                       constant:0]];
}

- (void)dealloc
{
    
}
@end
