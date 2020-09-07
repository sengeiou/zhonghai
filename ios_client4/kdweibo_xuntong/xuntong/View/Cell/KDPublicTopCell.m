//
//  KDPublicTopCell.m
//  kdweibo
//
//  Created by Ad on 14-5-12.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPublicTopCell.h"
#import "XTUnreadImageView.h"
#import "GroupDataModel.h"
#import "PersonSimpleDataModel.h"
#import "ContactUtils.h"
#import "RecordDataModel.h"
#import "BOSConfig.h"
#import "KDApplicationQueryAppsHelper.h"

@implementation KDPublicTopCell

-(BOOL)pressOrNot
{
    if (_pressOrNot) {
        _pressOrNot = NO;
    }
    return _pressOrNot;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.backgroundColor = BOSCOLORWITHRGBADIVIDE255(250, 250, 250, 1.0);
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xF3F5F8, 1.0);
        self.selectedBackgroundView = bgColorView;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        //头像
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(12, (68-44)/2, 44, 44)];
        [self.contentView addSubview:headerView];
        self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44.0, 44.0)];
        [headerView addSubview:self.headerImageView];
        self.headerImageView.layer.cornerRadius = (ImageViewCornerRadius==-1?(CGRectGetHeight(headerView.frame)/2):ImageViewCornerRadius);
        self.headerImageView.layer.masksToBounds = YES;
        self.headerImageView.layer.shouldRasterize = YES;
        self.headerImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.headerImageView.image = [UIImage imageNamed:@"college_img_public_timeline.png"];//[XTImageUtil publicheadimage];
        self.unreadImageView = [[XTUnreadImageView alloc] initWithParentView:self.contentView];
        
        CGRect frame = headerView.frame;
        frame.origin.x += (CGRectGetWidth(frame) + 12.0);
        //姓名或者组名
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, 11+4, ScreenFullWidth-60-13-12*2-44+14-41, 16.0)];
        self.nameLabel.font = FS2;
        self.nameLabel.textColor = FC1;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLabel];
        
        frame = self.nameLabel.frame;
        frame.origin.y += frame.size.height + 13.0;
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y - 6, ScreenFullWidth-60-13-12*2-44+14, 18.0)];
        self.messageLabel.textColor = FC2;
        self.messageLabel.font = FS5;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.messageLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenFullWidth-80-13, 10.0+4, 80.0, 14.0)];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = FS6;
        self.timeLabel.textColor = FC2;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.timeLabel];
        
//        self.separateLineImageView = [[UIImageView alloc] init];
//        self.separateLineImageView.backgroundColor = BOSCOLORWITHRGBA(0xDDDDDD, 1.0);
//        [self.contentView addSubview:self.separateLineImageView];
        
    }
    
    return self;
}

- (void)setDataModel:(FoldPublicDataModel *)dataModel
{
    if (_dataModel != dataModel) {
        _dataModel = dataModel;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if ([[KDApplicationQueryAppsHelper shareHelper] getFoldPublicAccountPressState] == YES)
    {
        self.unreadImageView.hidden = YES;
    }
    else
    {
        if (self.dataModel.unreadCount > 0)
        {
            self.unreadImageView.hidden = NO;
            self.unreadImageView.unreadCount = (int)self.dataModel.unreadCount;
            SetOrigin(self.unreadImageView.frame, ScreenFullWidth- [NSNumber kdDistance1] - Width(self.unreadImageView.frame), Height(self.contentView.frame) - [NSNumber kdDistance1] - Height(self.unreadImageView.frame) - 1);
        }
        else {
            self.unreadImageView.hidden = YES;
        }
    }
    //名称
    self.nameLabel.text = ASLocalizedString(@"XTContactContentViewController_Tip_2");
    
    self.timeLabel.text = [ContactUtils xtDateFormatter:self.dataModel.latestMessageTime];
    
    NSMutableString *messageText = [NSMutableString string];
    
    if (![self.dataModel.groupName isKindOfClass:[NSNull class]] && self.dataModel.groupName.length > 0) {
        [messageText appendString:self.dataModel.groupName];
        [messageText appendString:@":"];
    }
    
    if (self.dataModel.latestMessageType == MessageTypeSpeech){
        [messageText appendString:ASLocalizedString(@"KDPublicTopCell_Voice")];
    } else if (self.dataModel.latestMessageType == MessageTypePicture){
        [messageText appendString:ASLocalizedString(@"KDPublicTopCell_Pic")];
    } else {
        if (self.dataModel.latestMessage != nil) {
            [messageText appendString:self.dataModel.latestMessage];
        }
    }
    
    self.messageLabel.text = messageText;
    
//    self.separateLineImageView.frame = CGRectMake(0.0, CGRectGetHeight(self.bounds) - 0.5, CGRectGetWidth(self.bounds), 0.5);
    
    [super layoutSubviews];

}



@end

