//
//  KDBageImageView.m
//  kdweibo
//
//  Created by 王 松 on 13-11-20.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDBadgeImageView.h"

#import "KDDMThread.h"

#define kShowBadgeView (int)1

#define kImageSize CGSizeMake(48.f,48.f)

@interface KDBadgeImageView()

@property (nonatomic, retain) UIImageView *badgeImageView;

@property (nonatomic, retain) UILabel *badgeLabel;

@end

@implementation KDBadgeImageView

@synthesize loadingAvatars = _loadingAvatars;
@synthesize dmInbox = _dmInbox;
@synthesize dmThread = _dmThread;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupComponents];
    }
    return self;
}

- (void)setupComponents
{
    _badgeAlignment = KDBadgeViewAlignmentBottomRight;
    _imageView = [KDDMThreadAvatarView dmThreadAvatarView];// retain];
    _imageView.enabled = NO;
    [self addSubview:_imageView];
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_iconImageView];
    _badgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messag_badge.png"]];
    [self addSubview:_badgeImageView];
    _badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_badgeLabel];
    self.badgeValue = kShowBadgeView >> 1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = kImageSize;
    CGSize badgeSize = _badgeImageView.image.size;
    CGPoint center = self.center;
    self.frame = CGRectMake(0.0f, 0.0f, size.width + badgeSize.width / 2.f, size.height + badgeSize.height / 2.f);
    self.center = center;
    self.imageView.frame = self.bounds;
    self.iconImageView.frame = CGRectInset(self.bounds, 4.f, 4.f);
    [self layoutBadgeView];
}

- (void)setBadgeAlignment:(KDBadgeViewAlignment)badgeAlignment
{
    if (_badgeAlignment != badgeAlignment) {
        _badgeAlignment = badgeAlignment;
        [self setNeedsLayout];
    }
}

- (void)setBadgeValue:(NSInteger)badgeValue
{
    _badgeValue = badgeValue;
    self.badgeLabel.text = [NSString stringWithFormat:@"%ld", (long)badgeValue];
    [self showBadgeView:(_badgeValue >= kShowBadgeView)];
}

- (void)showBadgeView:(BOOL)show
{
    self.badgeLabel.hidden = !show;
    self.badgeImageView.hidden = !show;
}

- (void)layoutBadgeView
{
    CGFloat deta = 10.f;
    
    CGPoint point = CGPointMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMaxY(self.imageView.frame));
    if (self.iconImageView.image) {
        point = CGPointMake(CGRectGetMaxX(self.iconImageView.frame), CGRectGetMaxY(self.iconImageView.frame));
    }
    
    switch (_badgeAlignment) {
        case KDBadgeViewAlignmentTopLeft:
            point = CGPointMake(CGRectGetMinX(self.imageView.frame) + deta, CGRectGetMinY(self.imageView.frame) + deta);
            break;
        case KDBadgeViewAlignmentTopRight:
            point = CGPointMake(CGRectGetMaxX(self.imageView.frame) - deta, CGRectGetMinY(self.imageView.frame) + deta);
            break;
        case KDBadgeViewAlignmentTopCenter:
            point = CGPointMake(CGRectGetMidX(self.imageView.frame), CGRectGetMinY(self.imageView.frame) + deta);
            break;
        case KDBadgeViewAlignmentCenterLeft:
            point = CGPointMake(CGRectGetMinX(self.imageView.frame) + deta, CGRectGetMidY(self.imageView.frame));
            break;
        case KDBadgeViewAlignmentCenterRight:
            point = CGPointMake(CGRectGetMaxX(self.imageView.frame)  - deta, CGRectGetMidY(self.imageView.frame));
            break;
        case KDBadgeViewAlignmentBottomLeft:
            point = CGPointMake(CGRectGetMinX(self.imageView.frame) + deta, CGRectGetMaxY(self.imageView.frame)  - deta);
            break;
        case KDBadgeViewAlignmentBottomRight:
            point = CGPointMake(CGRectGetMaxX(self.imageView.frame) - deta, CGRectGetMaxY(self.imageView.frame) - deta);
            break;
        case KDBadgeViewAlignmentBottomCenter:
            point = CGPointMake(CGRectGetMidX(self.imageView.frame), CGRectGetMaxY(self.imageView.frame)  - deta);
            break;
        case KDBadgeViewAlignmentCenter:
            point = CGPointMake(CGRectGetMidX(self.imageView.frame), CGRectGetMidY(self.imageView.frame));
            break;
            
        default:
            break;
    }
    
    self.badgeImageView.center = point;
    _badgeLabel.frame = CGRectOffset(self.badgeImageView.frame, 1.f, 0.f);
    _badgeLabel.textColor = [UIColor whiteColor];
    _badgeLabel.font =  [UIFont systemFontOfSize:13.f];//[UIFont fontWithName:@"Copperplate-Light" size:14.f];
    _badgeLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setDmInbox:(KDInbox *)dmInbox
{
    self.imageView.dmInbox = dmInbox;
}

- (KDInbox *)dmInbox
{
    return self.imageView.dmInbox;
}

- (void)setDmThread:(KDDMThread *)dmThread
{
    if (_dmThread != dmThread) {
//        [_dmThread release];
        _dmThread = dmThread;//／／ retain];
        [self setBadgeValue:dmThread.unreadCount];
    }
    self.imageView.dmThread = dmThread;
}

- (KDDMThread *)dmThread
{
    return self.imageView.dmThread;
}

- (void)setLoadingAvatars:(BOOL)loadingAvatars
{
    self.imageView.loadingAvatars = loadingAvatars;
}

- (BOOL)loadingAvatars
{
    return self.imageView.loadingAvatars;
}

- (BOOL)hasUnloadAvatars
{
    return self.imageView.hasUnloadAvatars;
}


- (void)dealloc
{
    //KD_RELEASE_SAFELY(_imageView);
    //KD_RELEASE_SAFELY(_badgeLabel);
    //KD_RELEASE_SAFELY(_badgeImageView);
    //KD_RELEASE_SAFELY(_dmThread);
    //KD_RELEASE_SAFELY(_dmInbox);
    //KD_RELEASE_SAFELY(_iconImageView);
    //[super dealloc];
}

@end
