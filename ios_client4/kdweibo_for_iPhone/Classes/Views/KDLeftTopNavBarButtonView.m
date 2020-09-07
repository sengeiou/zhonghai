//
//  KDLeftTopNavBarButtonView.m
//  kdweibo
//
//  Created by Tan yingqi on 12-12-18.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDLeftTopNavBarButtonView.h"

@interface KDLeftTopNavBarButtonView()
@property(nonatomic, retain)KDBadgeIndicatorView *badgeImageView;
@end

@implementation KDLeftTopNavBarButtonView
@synthesize badgeImageView = badgeImageView_;
@synthesize button = button_;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(communityDidChanged) name:kKDCommunityDidChangedNotification object:nil];
        [[[KDManagerContext globalManagerContext] unreadManager] addUnreadListener:self];
        [[[KDManagerContext globalManagerContext] unreadManager] addXTUnreadListener:self];
        UIImage  *image = [UIImage imageNamed:@"navigationItem_menu"];
        UIImage *selectedImage = [UIImage imageNamed:@"navigationItem_menu_hl"];
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        aBtn.center = CGPointMake(15, 10);
       
        aBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [aBtn setImage:image forState:UIControlStateNormal];
        [aBtn setImage:selectedImage forState:UIControlStateHighlighted];
        [aBtn setImageEdgeInsets:UIEdgeInsetsMake(-3, 0, 3, 0)];
        [aBtn sizeToFit];
        [self addSubview:aBtn];
        self.button = aBtn;
        
        badgeImageView_ = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
        [badgeImageView_ setBadgeBackgroundImage:[KDBadgeIndicatorView redLeftBadgeBackgroundImag]];
        [self addSubview:badgeImageView_];
        
//        KDUnread *unread = [[[KDManagerContext globalManagerContext] unreadManager] unread];
        
        [self unreadManager:[[KDManagerContext globalManagerContext] unreadManager] unReadType:KDUnreadTypeWeibo];
    }
    
    return self;
}
- (void)setbadgeCount:(NSInteger)count{
    badgeImageView_.badgeValue = count;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kKDMessageNoticeNumChangeNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:count],@"count", nil]];
}
- (void)showBadge {
    self.badgeImageView.hidden = NO;
}

- (void)hideBadge {
    self.badgeImageView.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame;
    frame = self.button.frame;
    frame.origin.x = 0;
    self.button.frame = frame;
   
    frame.origin.x = CGRectGetMaxX(frame)-17;
    frame.origin.y= 7;
    frame.size = [badgeImageView_ getBadgeContentSize];
    if(!badgeImageView_.hidden && badgeImageView_.badgeValue == 0) {
        frame.size = [KDBadgeIndicatorView redLeftBadgeBackgroundImag].size;
    }
    
    badgeImageView_.frame = frame;
}

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self){
        return self.button;
    }
    else {
        return hitView;
    }
}

static NSInteger kdCount = 0;
static NSInteger xtCount = 0;


- (void)unreadManager:(KDUnreadManager *)unreadManager unReadType:(KDUnreadType)unReadType{
    if(unReadType == KDUnreadTypeWeibo){
        NSInteger count = 0;
        kdCount = [unreadManager.unread otherCommunityNoticesCount];
        count += xtCount + kdCount;
        
        [self setbadgeCount:count];
        
        [self setNeedsLayout];
    }
    else if(unReadType == KDUnreadTypeXuntong){
        NSInteger count = kdCount;
        xtCount = 0;
        
        NSArray *joinedCommunity = [[KDManagerContext globalManagerContext] communityManager].joinedCommpanies;
        for (CompanyDataModel *community in joinedCommunity) {
            if (![community.eid isEqualToString:[[KDManagerContext globalManagerContext] communityManager].currentCompany.eid]) {
                xtCount += community.unreadCount ;
            }
        }
        count += xtCount;
        
        [self setbadgeCount:count];
        
        [self setNeedsLayout];
    }
}

- (void)communityDidChanged
{
    NSArray *joinedCommunity = [[KDManagerContext globalManagerContext] communityManager].joinedCommpanies;
    kdCount = 0;
    xtCount = 0;
    for (CompanyDataModel *community in joinedCommunity) {
        if (![community.eid isEqualToString:[[KDManagerContext globalManagerContext] communityManager].currentCompany.eid]) {
            kdCount += community.wbUnreadCount;
            xtCount += community.unreadCount;
        }
    }
    NSInteger count = kdCount + xtCount;
    
    [self setbadgeCount:count];
    
    [self setNeedsLayout];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[KDManagerContext globalManagerContext] unreadManager] removeUnreadListener:self];
    [[[KDManagerContext globalManagerContext] unreadManager] removeXTUnreadListener:self];
    //KD_RELEASE_SAFELY(badgeImageView_);
    //KD_RELEASE_SAFELY(button_);
    //[super dealloc];
}

@end
