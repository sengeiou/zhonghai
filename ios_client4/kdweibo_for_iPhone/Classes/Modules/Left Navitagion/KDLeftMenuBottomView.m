//
//  KDLeftMenuBottomView.m
//  KDLeftMenu
//
//  Created by 王 松 on 14-4-16.
//  Copyright (c) 2014年 Song.wang. All rights reserved.
//

#import "KDLeftMenuBottomView.h"


@interface KDLeftMenuBottomView ()

@property (nonatomic, retain) UIButton *actionButton;

@property (nonatomic, retain) UILabel *versionLabel;

@end

@implementation KDLeftMenuBottomView

+ (instancetype)bottomView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.x = 10.f;
    rect.origin.y = rect.size.height - 50.f;
    rect.size.height = 50.f;
    rect.size.width -= ScreenFullWidth / 5;
    KDLeftMenuBottomView *bottemView = [[KDLeftMenuBottomView alloc] initWithFrame:rect];// autorelease];
    return bottemView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    [_actionButton setImage:[UIImage imageNamed:@"recommend_normal"] forState:UIControlStateNormal];
    [_actionButton setImage:[UIImage imageNamed:@"recommend_press"] forState:UIControlStateHighlighted];
    [_actionButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    _actionButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5.f, 0, 0);
    [_actionButton setTitle:ASLocalizedString(@"KDLeftMenuBottomView_recommand")forState:UIControlStateNormal];
//    [_actionButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.75f] forState:UIControlStateNormal];
//    [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_actionButton setTitleColor:UIColorFromRGB(0x818ea5) forState:UIControlStateNormal];
    [_actionButton setTitleColor:UIColorFromRGB(0x686d7d) forState:UIControlStateHighlighted];
    [_actionButton sizeToFit];
    
    _versionLabel.backgroundColor = [UIColor clearColor];
    _versionLabel.textColor = UIColorFromRGB(0x818ea5);
    _versionLabel.font = [UIFont systemFontOfSize:14.f];
    _versionLabel.text = [NSString stringWithFormat:@"V%@", [KDCommon visibleClientVersion]];
    _versionLabel.textAlignment = NSTextAlignmentRight;
    [_versionLabel sizeToFit];

    [self addSubview:_actionButton];
    [self addSubview:_versionLabel];
    
    CGFloat width = 13;
    if (isAboveiPhone6) {
        width = 0;
    }
    if (isiPhone6Plus) {
        width = -10;
    }
    _versionLabel.frame = CGRectMake( CGRectGetWidth(self.frame) - CGRectGetWidth(_versionLabel.frame) - 5 + width, (CGRectGetHeight(self.frame) - CGRectGetHeight(_versionLabel.frame)) * 0.5f, CGRectGetWidth(_versionLabel.frame), CGRectGetHeight(_versionLabel.frame));
    _actionButton.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - CGRectGetHeight(_actionButton.frame)) * 0.5f, CGRectGetWidth(_actionButton.frame) + 10, CGRectGetHeight(_actionButton.frame));
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [_actionButton addTarget:target action:action forControlEvents:controlEvents];
}

@end
