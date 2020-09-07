//
//  KDInboxCell.m
//  kdweibo
//
//  Created by bird on 13-7-12.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDInboxCell.h"
#import "NSDate+Additions.h"
#import "KDDefaultViewControllerContext.h"
#import "UIViewAdditions.h"

@interface KDInboxCell ()

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) KDInboxRenderView *renderView;
@property (nonatomic, retain) UILabel *sourceLabel;
@property (nonatomic, retain) UIImageView *separatorImageView;

@end

#define KD_INBOX_INTERACTIVE_CELL_MARGIN_H    10.0
#define KD_INBOX_BOTTOM_CELL_MARGIN_H    10.0
#define KD_INBOX_LR_CELL_MARGIN_H    8.0
#define AVARTAR_SIZE 34.f

@implementation KDInboxCell

@synthesize inbox = inbox_;
@synthesize type=type_;
@synthesize userAvatarView=userAvatarView_;
@synthesize nameLabel=nameLabel_;
@synthesize dateLabel=dateLabel_;
@synthesize renderView=renderView_;
@synthesize sourceLabel=sourceLabel_;

- (void)setupMessageInteractiveCell {
    
    [super.contentView addSubview:[self backgroundView_]];
    
    highlightedView_ = [[UIView alloc] initWithFrame:CGRectZero];
    [backgroundView_ addSubview:highlightedView_];
    
    // avatar view
    userAvatarView_ = [KDUserAvatarView avatarView];// retain];
    [userAvatarView_ addTarget:self action:@selector(didTapOnAvatar:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView_ addSubview:userAvatarView_];
    
    // name label
    nameLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel_.backgroundColor = [UIColor clearColor];
    nameLabel_.font = [UIFont systemFontOfSize:16.0];
    nameLabel_.textColor = [UIColor blackColor];
    
    [backgroundView_ addSubview:nameLabel_];
    
    // date label
    dateLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    dateLabel_.backgroundColor = [UIColor clearColor];
    dateLabel_.font = [UIFont systemFontOfSize:12.0];
    dateLabel_.textColor = MESSAGE_DATE_COLOR;
    dateLabel_.textAlignment = NSTextAlignmentLeft;
    
    [backgroundView_ addSubview:dateLabel_];
    
    // render view
    renderView_ = [[KDInboxRenderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width - 2 * KD_INBOX_LR_CELL_MARGIN_H*2, 1.0f)];
    [backgroundView_ addSubview:renderView_];
    
    // source label
    sourceLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    sourceLabel_.backgroundColor = [UIColor clearColor];
    sourceLabel_.font = [UIFont systemFontOfSize:12.0];
    sourceLabel_.textColor = MESSAGE_DATE_COLOR;
    
    [backgroundView_ addSubview:sourceLabel_];
    
    statusImage_  = [UIButton buttonWithType:UIButtonTypeCustom];
    statusImage_.frame = CGRectZero;
    [statusImage_ setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [statusImage_ setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
    [statusImage_ setBackgroundImage:[[UIImage imageNamed:@"inbox_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    statusImage_.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [backgroundView_ addSubview:statusImage_];
    
    // badge indicator view
    badgeIndicatorView_ = [[KDBadgeIndicatorView alloc] initWithFrame:CGRectZero];
    [badgeIndicatorView_ setBadgeBackgroundImage:[KDBadgeIndicatorView tipBadgeBackgroundImage]];
    [badgeIndicatorView_ setBadgeColor:[UIColor whiteColor]];
    [badgeIndicatorView_ setbadgeTextFont:[UIFont systemFontOfSize:14.0]];
    [backgroundView_ addSubview:badgeIndicatorView_];
    
}
- (UIView *)backgroundView_
{
    if (!backgroundView_)
    {
//        UIImage *bgImg = [UIImage imageNamed:@"todo_bg"];
//        bgImg = [bgImg stretchableImageWithLeftCapWidth:bgImg.size.width/2.0f topCapHeight:bgImg.size.height/2.0f];
        backgroundView_ = [[UIImageView alloc] init];// autorelease];
        backgroundView_.backgroundColor = [UIColor kdBackgroundColor2];
        backgroundView_.userInteractionEnabled = YES;
    }
    return backgroundView_;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupMessageInteractiveCell];
    }
    
    return self;
}
- (void)setupType
{
    if([inbox_.type isEqual:@"Comment"])
        type_ = KDInboxInteractiveTypeComment;
    else if([inbox_.type isEqual:@"Metion"])
        type_ = KDInboxInteractiveTypeMetion;
    else
        type_ = KDInboxInteractiveTypeUnknown;
}
- (void)layoutBadgeIndicatorView
{

}
- (void)layout {
    CGFloat offsetX = KD_INBOX_LR_CELL_MARGIN_H;
    CGFloat offsetY = KD_INBOX_LR_CELL_MARGIN_H;
    CGFloat width = ScreenFullWidth - 2*KD_INBOX_LR_CELL_MARGIN_H;
    
    // avatar view
    CGRect rect = CGRectMake(offsetX, offsetY, AVARTAR_SIZE, AVARTAR_SIZE);
    userAvatarView_.frame = rect;
    
    // badge
    CGSize contentSize = [badgeIndicatorView_ getBadgeContentSize];
    badgeIndicatorView_.frame =  CGRectMake(CGRectGetMaxX(rect)-(contentSize.width -8), CGRectGetMaxY(rect)-(contentSize.height -8), contentSize.width, contentSize.height);
    
    // name label
    offsetX += rect.size.width + KD_INBOX_INTERACTIVE_CELL_MARGIN_H +3.0;
    rect = CGRectMake(offsetX, offsetY+1, width-offsetX-KD_INBOX_LR_CELL_MARGIN_H, 16.0);
    nameLabel_.frame = rect;
    
    // date label
    offsetY = CGRectGetMaxY(rect)+ 4.0;
    rect.origin.y = offsetY;
    dateLabel_.frame = rect;
    
    // source label
    offsetX = CGRectGetMaxX(rect);
    rect.origin.x = offsetX;
    // sourceLabel_.frame = rect;
    
    //status
    statusImage_.frame = CGRectMake(width - 72, KD_INBOX_LR_CELL_MARGIN_H, 70, 18);
    
    NSString *imageName;
    NSString *prefix = @"inbox_bg";;
    switch (type_) {
        case KDInboxInteractiveTypeComment:
            prefix = [prefix stringByAppendingString:@"_comment"];
            [statusImage_ setTitle:ASLocalizedString(@"DraftTableViewCell_tips_4")forState:UIControlStateNormal];
            [statusImage_ setImage:[UIImage imageNamed:@"inbox_comment"] forState:UIControlStateNormal];
            [statusImage_ addTarget:self action:@selector(reply:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case KDInboxInteractiveTypeMetion:
            prefix = [prefix stringByAppendingString:@"_metion"];
            [statusImage_ setTitle:ASLocalizedString(@"KDInboxCell_about")forState:UIControlStateNormal];
            [statusImage_ setImage:[UIImage imageNamed:@"inbox_metion"] forState:UIControlStateNormal];
            [statusImage_ addTarget:self action:@selector(mention:) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            break;
    }
    if (inbox_.isUnRead)
        imageName = [prefix stringByAppendingString:@"_unread"];
    else
        imageName = @"inbox_bg";
    UIImage *image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [statusImage_ setBackgroundImage:image forState:UIControlStateNormal];
    [statusImage_ setBackgroundImage:image forState:UIControlStateHighlighted];
    
    
    offsetX = KD_INBOX_LR_CELL_MARGIN_H;
    offsetY = CGRectGetMaxY(userAvatarView_.frame) + KD_INBOX_INTERACTIVE_CELL_MARGIN_H;
    // content render view
    rect = CGRectMake(offsetX, offsetY, width - KD_INBOX_LR_CELL_MARGIN_H*2, renderView_.frame.size.height);
    renderView_.frame = rect;
    
    offsetY = CGRectGetMaxY(rect) + KD_INBOX_BOTTOM_CELL_MARGIN_H;
    
    rect.origin.y = KD_INBOX_BOTTOM_CELL_MARGIN_H;
    rect.size.width = width;
    rect.size.height = offsetY;
    backgroundView_.frame = rect;
    
    highlightedView_.frame = CGRectInset(backgroundView_.bounds, 0.5, 0.5);
    
    self.bounds = CGRectMake(0.0f, 0.0f, width, offsetY+ KD_INBOX_BOTTOM_CELL_MARGIN_H);
}

- (void)reply:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(replyWithInbox:)]) {
        [self.delegate replyWithInbox:self.inbox];
    }
}

- (void)mention:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(mentionWithInbox:)]) {
        [self.delegate mentionWithInbox:self.inbox];
    }
}

- (NSString *)formatSource {
    NSString *source = (inbox_.groupName != nil) ? inbox_.groupName : ASLocalizedString(@"KDInboxCell_hall");
    return [NSString stringWithFormat:ASLocalizedString(@"Wb_From"), source];
}

- (void)update {
    
    if (type_ != KDInboxInteractiveTypeUnknown)
        userAvatarView_.avatarDataSource = inbox_.latestFeed.senderUser;
    
    NSInteger unReadCount = inbox_.unReadCount;
    if (inbox_.unReadCount ==1)
        unReadCount = 0;
    [badgeIndicatorView_ setBadgeValue:unReadCount];
    
    nameLabel_.text = inbox_.latestFeed.senderUser.username;
    
    dateLabel_.text = [[NSDate formatMonthOrDaySince1970:inbox_.updateTime] stringByAppendingFormat:@"      %@",[self formatSource]];
//    sourceLabel_.text = [self formatSource];
    renderView_.inbox = inbox_;
    [self layout];
}

- (void)setInbox:(KDInbox *)inbox
{
    if(inbox_ != inbox){
//        [inbox_ release];
        inbox_ = inbox;// retain];
        
        [self setupType];
        [self update];
        
    }
}
- (void)didTapOnAvatar:(UIButton *)sender {
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:inbox_.latestFeed.senderUser sender:sender];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    // Configure the view for the selected state
    highlightedView_.backgroundColor = highlighted?[UIColor colorWithRed:240/255.f green:241/255.f blue:242/255.f alpha:1.0]:[UIColor clearColor];
}

#define KD_STATUS_DISPLAY_HEIGHT_PROP_KEY   @"kd:reply_status_height"

+ (CGFloat)messageInteractiveCellHeight:(KDInbox *)inbox{
    NSNumber *prop = [inbox propertyForKey:KD_STATUS_DISPLAY_HEIGHT_PROP_KEY];
    
    CGFloat height = 0.0;
    if (prop == nil) {
        
        float width = [UIScreen mainScreen].bounds.size.width - 2 * KD_INBOX_LR_CELL_MARGIN_H*2;

        height = AVARTAR_SIZE+KD_INBOX_LR_CELL_MARGIN_H+KD_INBOX_INTERACTIVE_CELL_MARGIN_H + KD_INBOX_BOTTOM_CELL_MARGIN_H*2 + [KDInboxRenderView calculateInboxDisplaySize:inbox constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
        
        [inbox setProperty:[NSNumber numberWithFloat:height] forKey:KD_STATUS_DISPLAY_HEIGHT_PROP_KEY];
        
    } else {
        height = [prop floatValue];
    }
    return height;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(highlightedView_);
    //KD_RELEASE_SAFELY(badgeIndicatorView_);
    //KD_RELEASE_SAFELY(inbox_);
    //KD_RELEASE_SAFELY(userAvatarView_);
    //KD_RELEASE_SAFELY(nameLabel_);
    //KD_RELEASE_SAFELY(dateLabel_);
    //KD_RELEASE_SAFELY(renderView_);
    //KD_RELEASE_SAFELY(sourceLabel_);
    //[super dealloc];
}
@end
