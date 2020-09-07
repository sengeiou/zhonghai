//
//  XTTimelineSearchCell.m
//  kdweibo
//
//  Created by Gil on 15/1/12.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "XTTimelineSearchCell.h"
#import "XTImageUtil.h"
#import "XTUnreadImageView.h"
#import "ContactUtils.h"
#import "BOSConfig.h"

@interface XTTimelineSearchCell ()
@property (nonatomic, strong) XTGroupHeaderImageView *headerImageView;
@property (nonatomic, strong) XTUnreadImageView *unreadImageView;

@property (nonatomic, strong) RTLabel *nameLabel;
@property (nonatomic, strong) RTLabel *messageLabel;
@property (nonatomic, strong) UIImageView *separateLineImageView;
@end

@implementation XTTimelineSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.contentView.backgroundColor = BOSCOLORWITHRGBA(0xffffff, 1.0);
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xE5E5E5, 1.0);
        self.selectedBackgroundView = bgColorView;
        
        //头像
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, 48.0, 48.0)];
        [self.contentView addSubview:headerView];
        self.headerImageView = [[XTGroupHeaderImageView alloc] initWithFrame:CGRectMake(0, 0, 48.0, 48.0)];
        [headerView addSubview:self.headerImageView];
        self.headerImageView.layer.cornerRadius = 2;
        self.headerImageView.layer.masksToBounds = YES;
        self.unreadImageView = [[XTUnreadImageView alloc] initWithParentView:headerView];
        
        CGRect frame = headerView.frame;
        frame.origin.x += (CGRectGetWidth(frame) + 10.0);
        frame.origin.y += 2.0;
        //组名
        CGFloat height = 20.f;
        if(isAboveiOS9){
            height = 24.0f;
        }
        self.nameLabel = [[RTLabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 242.0, height)];
        self.nameLabel.font = [UIFont systemFontOfSize:16.0];
        self.nameLabel.textColor = BOSCOLORWITHRGBA(0x000000, 1.0);
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.lineBreakMode = RTTextLineBreakModeCharWrapping;
        [self.contentView addSubview:self.nameLabel];
        
        frame = self.nameLabel.frame;
        frame.origin.y += (frame.size.height + 7.0);
        self.messageLabel = [[RTLabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y , 242.0, 20.0)];
        self.messageLabel.font = [UIFont systemFontOfSize:14.0];
        self.messageLabel.textColor = BOSCOLORWITHRGBA(0x808080, 1.0);
        self.messageLabel.textAlignment = RTTextAlignmentLeft;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.lineBreakMode = RTTextLineBreakModeCharWrapping;
        [self.contentView addSubview:self.messageLabel];
        
//        self.separateLineImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
//        [self.contentView addSubview:self.separateLineImageView];
        
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 68, 0, 0);
    }
    
    return self;
}

- (void)setGroup:(GroupDataModel *)group
{
    if (_group != group) {
        _group = group;
        [self.headerImageView setGroup:group];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //未读
    int unreadCount = self.group.unreadCount;
    self.unreadImageView.hidden = unreadCount <= 0;
    if (unreadCount > 0) {
        self.unreadImageView.unreadCount = unreadCount;
    }
    
    //名称
    self.nameLabel.text = self.group.highlightGroupName.length > 0 ? self.group.highlightGroupName : self.group.groupName;
    
    if (self.group.highlightMessage.length > 0) {
        self.messageLabel.hidden = NO;
        self.messageLabel.text = self.group.highlightMessage;
    }
    else {
        self.messageLabel.hidden = YES;
    }
    
    CGRect frame = CGRectMake(10.0, 10.0, 48.0, 48.0);
    frame.origin.x += (CGRectGetWidth(frame) + 10.0);
    if (self.messageLabel.hidden) {
        frame.origin.y += 12.0;
    }
    else {
        frame.origin.y += 2.0;
    }
    frame.size.width = self.nameLabel.bounds.size.width;
    frame.size.height = self.nameLabel.bounds.size.height;
    self.nameLabel.frame = frame;
    
    self.separateLineImageView.frame = CGRectMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.separateLineImageView.bounds))/2, CGRectGetHeight(self.bounds) - 1, CGRectGetWidth(self.separateLineImageView.bounds), 1.0);
    
}

@end
