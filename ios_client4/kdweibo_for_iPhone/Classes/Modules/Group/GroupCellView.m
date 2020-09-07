//
//  GroupCellView.m
//  TwitterFon
//
//  Created by apple on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"
#import "GroupCellView.h"
#import "GroupInfoViewController.h"
#import "KDCache.h"

@interface GroupCellView ()

@property (nonatomic, strong) KDGroupAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *announcementLabel;

@property (nonatomic, strong) KDBadgeView *badgeIndicatorView;

@end


@implementation GroupCellView

@synthesize groupController=groupController_;

@dynamic group;
@dynamic unreadCount;

@synthesize avatarView=avatarView_;
@synthesize nameLabel=nameLabel_;
@synthesize announcementLabel=announcementLabel_;

@synthesize badgeIndicatorView = badgeIndicatorView_;
@synthesize tickImageView = tickImageView_;
@synthesize cellAccessoryImageView = cellAccessoryImageView_;

- (void) setupGroupCell {
    self.backgroundColor = [UIColor kdBackgroundColor2];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor kdBackgroundColor2];//BOSCOLORWITHRGBA(0xDDDDDD, 1.0);
    self.selectedBackgroundView = bgColorView;

    self.contentView.backgroundColor = [UIColor kdBackgroundColor2];//BOSCOLORWITHRGBADIVIDE255(250, 250, 250, 1.0);
    
    // avatar view
    avatarView_ = [KDGroupAvatarView avatarView];// retain];
    [avatarView_ addTarget:self action:@selector(didTapGroupAvatar:) forControlEvents:UIControlEventTouchUpInside];
    avatarView_.layer.cornerRadius = 6;
    avatarView_.layer.masksToBounds = YES;
    [self.contentView addSubview:avatarView_];
    
    // name label
    nameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel_.backgroundColor = [UIColor clearColor];
    nameLabel_.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    nameLabel_.textColor = BOSCOLORWITHRGBA(0x000000, 1.0);
    [self.contentView addSubview:nameLabel_];
    
    // announcement label
    announcementLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    announcementLabel_.backgroundColor = [UIColor clearColor];
    announcementLabel_.font = [UIFont systemFontOfSize:14];
    announcementLabel_.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);;
    
    [self.contentView addSubview:announcementLabel_];
    
    badgeIndicatorView_ = [[KDBadgeView alloc]init];
    [badgeIndicatorView_ setBadgeBackgroundImage:[KDBadgeView XTRedBadgeBackgroudImage]];
    [badgeIndicatorView_ setBadgeColor:[UIColor whiteColor]];
    [badgeIndicatorView_ setbadgeTextFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [self.contentView addSubview:badgeIndicatorView_];
    
    
    
    tickImageView_ = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView  addSubview:tickImageView_];
    
    
    cellAccessoryImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_arrow"]];
    [self.contentView addSubview:cellAccessoryImageView_];
    
//    separatorView_ = [[UIView alloc] initWithFrame:CGRectZero];
//    separatorView_.backgroundColor = UIColorFromRGB(0xdddddd);
//    [self.contentView addSubview:separatorView_];
    self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
    self.separatorLineInset = UIEdgeInsetsMake(0, 44.0 + 2 * [NSNumber kdDistance1], 0, 0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupGroupCell];
    }
    
    return self;
}

#define KD_GROUP_AVATAR_CELL_WH   44.0
//2012-09-05修改，添加“暂无公告”
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = 15.0;
    CGFloat offsetY = (super.contentView.bounds.size.height - KD_GROUP_AVATAR_CELL_WH) * 0.5;
    
    CGRect rect =CGRectZero;
    if (tickImageView_.image) {
        [tickImageView_ sizeToFit];
        rect = tickImageView_.frame;
        rect.size.width = 22;
        rect.size.height = 22;
        rect.origin.x = offsetX;
        rect.origin.y = (super.contentView.bounds.size.height - rect.size.height) * 0.5;
        tickImageView_.frame = rect;
    }
    
    
    rect = CGRectMake(CGRectGetMaxX(tickImageView_.frame)+15, offsetY, KD_GROUP_AVATAR_CELL_WH, KD_GROUP_AVATAR_CELL_WH);
    avatarView_.frame = rect;
    
    
    offsetX = CGRectGetMaxX(rect) + 10;
    offsetY = 12;
    CGFloat height = 16.0f;
    rect = CGRectMake(offsetX, offsetY, super.contentView.bounds.size.width - offsetX - 25.0, height);
    nameLabel_.frame = rect;
    
    offsetY += rect.size.height +8.0;
    rect.origin.y = offsetY;
//    NSLog(@"%f",offsetY);
    rect.size.height = 18.f;
    rect.size.width = 195.f;
    announcementLabel_.frame = rect;
    
    
    if([badgeIndicatorView_ badgeIndicatorVisible]){
        [badgeIndicatorView_ sizeToFit];
        rect = [badgeIndicatorView_ frame];
        CGPoint point = CGPointMake(CGRectGetMaxX(avatarView_.frame) - 4.f, CGRectGetMinY(avatarView_.frame) + 6.f);
        badgeIndicatorView_.center = point;
    }
    
   
    
    cellAccessoryImageView_.frame = CGRectMake(self.contentView.bounds.size.width - cellAccessoryImageView_.image.size.width -13, (self.bounds.size.height - cellAccessoryImageView_.image.size.height)/2.0, cellAccessoryImageView_.image.size.width, cellAccessoryImageView_.image.size.height);
    

    //separatorView_.frame = CGRectMake(0, self.contentView.bounds.size.height- 1, self.contentView.bounds.size.width, 0.5);
    
}

- (void)didTapGroupAvatar:(id)sender {
    GroupInfoViewController *givc = [[GroupInfoViewController alloc] initWithNibName:nil bundle:nil];
    givc.group = self.group;
    [groupController_.navigationController pushViewController:givc animated:YES];
//    [givc release];
}

- (void)refresh {
    avatarView_.avatarDataSource = group_;
    
    nameLabel_.text = group_.name;
    if(group_.summary && group_.summary.length > 0)
        announcementLabel_.text = group_.summary;
    else
        announcementLabel_.text = NSLocalizedString(@"NO_GROUP_STATUS", @"");
}

- (void)setGroup:(KDGroup *)group {
    if(group_ != group){
//        [group_ release];
        group_ = group;// retain];
        
        [self refresh];
    }
}

- (KDGroup *)group {
    return group_;
}

- (void)setUnreadCount:(NSUInteger)unreadCount {
    if(unreadCount_ != unreadCount){
        unreadCount_ = unreadCount;

        badgeIndicatorView_.badgeValue = unreadCount_;
        
        BOOL visible = [badgeIndicatorView_ badgeIndicatorVisible];
        if (visible) {
            [self setNeedsLayout];
        }
    }
}

- (NSUInteger)unreadCount {
    return unreadCount_;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    //cellAccessoryImageView_.image = highlighted?[UIImage imageNamed:@"smallTriangle"]:[UIImage imageNamed:@"profile_edit_arrow"];
  
}

- (void)prepareForReuse
{
    //separatorView_.hidden = NO;
}
- (void)dealloc  {
    
    groupViewController_ = nil;
    
    ////KD_RELEASE_SAFELY(separatorView_);
    //KD_RELEASE_SAFELY(group_);
    //KD_RELEASE_SAFELY(cellAccessoryImageView_);
    //KD_RELEASE_SAFELY(avatarView_);
    //KD_RELEASE_SAFELY(nameLabel_);
    //KD_RELEASE_SAFELY(announcementLabel_);
    
    //KD_RELEASE_SAFELY(badgeIndicatorView_);
    //KD_RELEASE_SAFELY(tickImageView_);
    
    //[super dealloc];
}

@end

