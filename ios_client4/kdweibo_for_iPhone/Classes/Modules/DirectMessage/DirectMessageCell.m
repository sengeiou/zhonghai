//
//  DirectMessageCell.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "DirectMessageCell.h"

#import "KDDefaultViewControllerContext.h"

#import "UIView+Blur.h"

#import "KDBadgeIndicatorView.h"


@interface DirectMessageCell ()

@property (nonatomic, retain) KDDMThreadAvatarView *avatarView;
@property (nonatomic, retain) DirectMessageCellView *detailsView;
@property (nonatomic, retain) KDBadgeIndicatorView *badgeIndicatorView;

@end

@implementation DirectMessageCell

@dynamic dmThread;
@dynamic dmInbox;
@synthesize avatarView=avatarView_;
@synthesize detailsView=detailsView_;
@synthesize delegate = delegate_;
@synthesize badgeIndicatorView=badgeIndicatorView_;

- (void)_setupDirectMessageCell {
    self.backgroundColor = MESSAGE_BG_COLOR;
    // avatar view
    avatarView_ = [KDDMThreadAvatarView dmThreadAvatarView];// retain];
    avatarView_.userInteractionEnabled = NO;
    [super.contentView addSubview:avatarView_];
    
    // direct message details view
    detailsView_ = [[DirectMessageCellView alloc] initWithFrame:CGRectZero];
    [super.contentView addSubview:detailsView_];
    
    // badge indicator view
    badgeIndicatorView_ = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
    [badgeIndicatorView_ setBadgeBackgroundImage:[KDBadgeIndicatorView redBadgeBackgroundImage]];
    [badgeIndicatorView_ setBadgeColor:[UIColor whiteColor]];
    [badgeIndicatorView_ setbadgeTextFont:[UIFont systemFontOfSize:13]];
    [self.contentView addSubview:badgeIndicatorView_];
    
    [self addBorderAtPosition:KDBorderPositionBottom];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        type_ = KdmTypeUnknow;
        [self _setupDirectMessageCell];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons {
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier containingTableView:containingTableView leftUtilityButtons:leftUtilityButtons rightUtilityButtons:rightUtilityButtons];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        type_ = KdmTypeUnknow;
        [self _setupDirectMessageCell];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void) update {
    if (type_ == KdmTypeThread)
    {
        [detailsView_ updateWithDMThread:dmThread_];
        [avatarView_ setDmThread:dmThread_];
        [badgeIndicatorView_ setBadgeValue:dmThread_.unreadCount];
        if ([badgeIndicatorView_ badgeIndicatorVisible]) {
            [self layoutBadgeIndicatorView];
        }
        
        if (dmThread_.isTop) {
            if ([self.rightUtilityButtons count]>0) {
                UIButton *button = [self.rightUtilityButtons objectAtIndex:0];
                [button setTitle:ASLocalizedString(@"DirectMessageCell_btn_1")forState:UIControlStateNormal];
            }
        }
        else
        {
            if ([self.rightUtilityButtons count]>0) {
                UIButton *button = [self.rightUtilityButtons objectAtIndex:0];
                [button setTitle:ASLocalizedString(@"DirectMessageCell_btn_2")forState:UIControlStateNormal];
            }
            
        }
    }
}
- (void) setDmInbox:(KDInbox *)dmInbox {
    if(dmInbox_ != dmInbox){
//        [dmInbox_ release];
        dmInbox_ = dmInbox;// retain];
        avatarView_.dmInbox = dmInbox;
    }
    if (type_ != KdmTypeInbox)
        type_ = KdmTypeInbox;
    
    [self update];
}
- (void) setDmThread:(KDDMThread *)dmThread {
    if(dmThread_ != dmThread){
//        [dmThread_ release];
        dmThread_ = dmThread ;//retain];
        
        avatarView_.dmThread = dmThread;
    }
    if (type_ != KdmTypeThread)
        type_ = KdmTypeThread;
    
    [self update];
}

- (KDInbox *)dmInbox
{
    return dmInbox_;
}
- (KDDMThread *) dmThread {
    return dmThread_;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect rect = CGRectMake(10.f, (self.bounds.size.height - 48.f) * 0.5, 48.f, 48.f);
    avatarView_.frame = rect;       
    
    CGFloat offsetX = rect.origin.x + rect.size.width + 10.0;
    rect = CGRectMake(offsetX, 0.0, self.bounds.size.width - offsetX, self.bounds.size.height - 1.0);
    detailsView_.frame = rect;
    
    if ([badgeIndicatorView_ badgeIndicatorVisible]) {
        [self layoutBadgeIndicatorView];
    }
}

/*
 2013.10.10 ios7中UITableViewCell 的superview 不是UItableview 所以[self superView] 返回的不是Tableview。解决方法为将avatarView 的 enable 设为No。
 
 */
//-(void)avatarViewTapped:(id)sender {
//    id superView = [self superview];
//    UITableView *tableview = nil;
//    NSIndexPath *indexPath = nil;
//    if (superView) {
//        tableview = (UITableView *) superView;
//        indexPath = [tableview indexPathForCell:self];
//    }
//    
//    if (tableview && indexPath) {
//        if (delegate_ && [delegate_ respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
//            [delegate_ tableView:tableview didSelectRowAtIndexPath:indexPath];
//        }
//    }
//}

- (void)layoutBadgeIndicatorView {
    CGSize contentSize = [badgeIndicatorView_ getBadgeContentSize];
    CGPoint point = CGPointMake(CGRectGetMaxX(self.avatarView.frame) - 8.f, CGRectGetMaxY(self.avatarView.frame) - 8.f);
    badgeIndicatorView_.center = point;
    CGRect rect = badgeIndicatorView_.frame;
    rect.size = contentSize;
    badgeIndicatorView_.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.detailsView.highlighted = selected;
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(detailsView_);
    //KD_RELEASE_SAFELY(dmInbox_);
    //KD_RELEASE_SAFELY(dmThread_);
    //KD_RELEASE_SAFELY(badgeIndicatorView_);
    //[super dealloc];
}

@end
