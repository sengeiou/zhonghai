//
//  KDSearchTextCell.m
//  kdweibo
//
//  Created by sevli on 15/8/7.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSearchTextCell.h"
#import "KDSearchTextModel.h"

#import "ContactUtils.h"

@interface KDSearchTextCell()

@property (nonatomic, strong) XTGroupHeaderImageView *headerImageView;
@property (nonatomic, strong) RTLabel *nameLabel;
@property (nonatomic, strong) RTLabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *externalSignImageView; //外部联系人的标示图标
@end


@implementation KDSearchTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        //头像
        self.headerImageView = [[XTGroupHeaderImageView alloc] initWithFrame:CGRectMake(.0, .0, 44.0, 44.0)];
        [self.contentView addSubview:self.headerImageView];
        
        //组名
        self.nameLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.font = FS2;
        self.nameLabel.textColor = FC1;
        self.nameLabel.backgroundColor = self.contentView.backgroundColor;
        self.nameLabel.lineBreakMode = RTTextLineBreakModeCharWrapping;
        [self.contentView addSubview:self.nameLabel];
        
        self.messageLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
        self.messageLabel.textColor = FC2;
        self.messageLabel.font = FS5;
        self.messageLabel.backgroundColor = self.contentView.backgroundColor;
        [self.contentView addSubview:self.messageLabel];
        
        //发送时间
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.font = FS5;
        self.timeLabel.textColor = FC2;
        self.timeLabel.backgroundColor = self.contentView.backgroundColor;
        [self.contentView addSubview:self.timeLabel];
        
        //外部标示
        self.externalSignImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.externalSignImageView];
        
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 68, 0, 0);
    }
    
    return self;
}

- (void)setSearchModel:(KDSearchTextModel *)searchModel {
    if (_searchModel != searchModel) {
        _searchModel = searchModel;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    BOOL isExternalGroup = self.searchModel.isExternalGroup;
    
    self.headerImageView.group = self.searchModel;
    CGRect frame = CGRectMake([NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - 44.0) / 2, 44.0, 44.0);
    self.headerImageView.frame = frame;
    
    self.nameLabel.text = self.searchModel.groupName;
    
    if (self.searchModel.highlightMessage.length > 0) {
        self.messageLabel.hidden = NO;
        self.messageLabel.text = self.searchModel.highlightMessage;
    }
    else {
        self.messageLabel.hidden = YES;
    }
    frame.origin.x += (CGRectGetWidth(frame) + [NSNumber kdDistance1]);
    
    CGFloat height = 20;
    if (isAboveiOS9) {
        height = 24.0;
    }
    if (self.messageLabel.hidden) {
        frame.origin.y = (CGRectGetHeight(self.contentView.frame) - height) / 2;
    }
    else {
        frame.origin.y = CGRectGetMinY(self.headerImageView.frame);
    }
    frame.size.width = (ScreenFullWidth - CGRectGetMaxX(frame) - [NSNumber kdDistance1]);
    frame.size.height = height;
    
    self.nameLabel.frame = frame;
    
    height = 16.0;
    if (isAboveiOS9) {
        height = 20.0;
    }
    frame.origin.y = (CGRectGetMaxY(self.headerImageView.frame) - height);
    frame.size.height = height;
    self.messageLabel.frame = frame;
    
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    NSString *str = [ContactUtils xtDateFormatterAtTimeline:self.searchModel.searchMessageData.sendTime];
    self.timeLabel.text = str;
    [self.timeLabel sizeToFit];
    CGRect timeLabelFrame = self.timeLabel.frame;
    timeLabelFrame.origin.x = ScreenFullWidth - timeLabelFrame.size.width - 13;
    timeLabelFrame.origin.y = CGRectGetMinY(self.nameLabel.frame);
    timeLabelFrame.size.height = 14.0f;
    self.timeLabel.frame = timeLabelFrame;
    
    if (CGRectGetMaxX(self.nameLabel.frame) > CGRectGetMinX(self.timeLabel.frame))
    {
        self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y, ScreenFullWidth - CGRectGetMinX(self.nameLabel.frame) - CGRectGetWidth(self.timeLabel.frame) - 17 , CGRectGetHeight(self.nameLabel.frame));
    }
//    self.externalSignImageView.frame = CGRectMake(CGRectGetMaxX(self.headerImageView.frame) + [NSNumber kdDistance1], 0, 20, 20);
//    self.externalSignImageView.center = CGPointMake(self.externalSignImageView.center.x, self.nameLabel.center.y);
//    self.externalSignImageView.image = [UIImage imageNamed:@"message_tip_shang"];
//    self.externalSignImageView.hidden = !isExternalGroup;
//    
//    CGRect tempFrame = self.nameLabel.frame;
//    if (isExternalGroup)
//    {
//        tempFrame.origin.x += self.externalSignImageView.frame.size.width + 5;
//        
//        tempFrame.size.width -= self.externalSignImageView.frame.size.height + 5;
//    }
//    self.nameLabel.frame = tempFrame;
}

@end
