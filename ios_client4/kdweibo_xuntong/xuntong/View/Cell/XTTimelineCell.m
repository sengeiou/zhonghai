//
//  PersonListCell.m
//  ContactsLite
//
//  Created by kingdee eas on 12-11-14.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//
#import "XTTimelineCell.h"
#import "XTUnreadImageView.h"
#import "PersonSimpleDataModel.h"
#import "ContactUtils.h"
#import "RecordDataModel.h"
#import "BOSConfig.h"

#define HEADER_VIEW_SIDE 44.f

@interface XTTimelineCell ()
{
    // 记录message label原始的frame
    CGRect _messageLabelOriginalFrame;
    
    // 记录message label偏移后的frame
    CGRect _messageLabelNewFrame;
    
}
@property (nonatomic, strong) XTGroupHeaderImageView *headerImageView;
@property (nonatomic, strong) XTUnreadImageView *unreadImageView;

@property (nonatomic, strong) UIImageView *partnerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *labelVoice; // ASLocalizedString(@"XTTimelineCell_Meeting")
@end

@implementation XTTimelineCell

// [有人@你] 出现时产生的偏移量/本体宽度
float atOffsetX = 66.0f;
// [草稿] 出现时产生的偏移量/本体宽度
const float draftOffsetX = 40.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorLineInset = UIEdgeInsetsMake(0, HEADER_VIEW_SIDE + 2 * [NSNumber kdDistance1], 0, 0);
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        
        //头像
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(12, (68-44)/2, 44, 44)];
        [self.contentView addSubview:headerView];
        self.headerImageView = [[XTGroupHeaderImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [headerView addSubview:self.headerImageView];
        self.headerImageView.layer.cornerRadius = 5;
        self.headerImageView.layer.masksToBounds = YES;
        self.unreadImageView = [[XTUnreadImageView alloc] initWithParentView:self.contentView];
        
        CGRect frame = headerView.frame;
        frame.origin.x += (CGRectGetWidth(frame) + 12.0);
        //姓名或者组名
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, 11+4, ScreenFullWidth-60-13-12*2-44+14-41, 20.0)];
        self.nameLabel.font = FS2;
        self.nameLabel.textColor = FC1;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLabel];
        
        //外部员工图标
        self.partnerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 15, 15)];
        self.partnerImageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
        self.partnerImageView.hidden = YES;
        [self.contentView addSubview:self.partnerImageView];
        
        frame = self.nameLabel.frame;
        frame.origin.y += frame.size.height + 13.0;
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y - 6, ScreenFullWidth-60-13-12*2-44+14, 18.0)];
        self.messageLabel.textColor = FC2;
        self.messageLabel.font = FS5;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.messageLabel];
        
        _messageLabelOriginalFrame = self.messageLabel.frame;
        _messageLabelNewFrame = CGRectMake(self.messageLabel.frame.origin.x + draftOffsetX, self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width - draftOffsetX, self.messageLabel.frame.size.height);
        
        
        self.headerMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y - 5 , 38, 18.0)];
        self.headerMessageLabel.font = FS5;
        self.headerMessageLabel.backgroundColor = [UIColor clearColor];
        self.headerMessageLabel.hidden = YES;
        [self.contentView addSubview:self.headerMessageLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenFullWidth-80-13, 10.0+4, 80, 14.0)];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = FS6;
        self.timeLabel.textColor = FC2;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.imageViewVoice];
        [self.contentView addSubview:self.imageViewTop];
        [self.contentView addSubview:self.labelVoice];
        
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
    self.unreadImageView.bGrey = ![self.group pushOpened];
    if (unreadCount > 0) {
//        if (unreadCount > 99) {
//            self.unreadImageView.unreadCount = 0;
//            self.unreadImageView.frame = CGRectMake(ScreenFullWidth - [NSNumber kdDistance1] - 9, Height(self.contentView.frame) - [NSNumber kdDistance1] - 9 - 1, 21, 9);
//        }
//        else {
            self.unreadImageView.unreadCount = unreadCount;
            SetOrigin(self.unreadImageView.frame, ScreenFullWidth- [NSNumber kdDistance1] - Width(self.unreadImageView.frame), Height(self.contentView.frame) - [NSNumber kdDistance1] - Height(self.unreadImageView.frame) - 1);
//        }
    }
    
    if (self.shouldHideUnreadImage) {
        self.unreadImageView.hidden = YES;
    }
    
    
    if(self.group.partnerType == 1)
    {
        CGRect frame = self.nameLabel.frame;
        frame.origin.x = CGRectGetMaxX(self.headerImageView.frame)+24;
        frame.size = self.partnerImageView.frame.size;
        self.partnerImageView.frame = frame;
        self.partnerImageView.hidden = NO;
        
        frame = self.nameLabel.frame;
        frame.origin.x = CGRectGetMaxX(self.partnerImageView.frame)+4;
        frame.size.width = ScreenFullWidth-60-13-12*2-44+14-41-4;
        self.nameLabel.frame = frame;
    }
    else
    {
        self.partnerImageView.hidden = YES;
        
        CGRect frame = self.nameLabel.frame;
        frame.origin.x = CGRectGetMaxX(self.headerImageView.frame)+24;
        frame.size.width = ScreenFullWidth-60-13-12*2-44+14-41;
        self.nameLabel.frame = frame;
    }
    
    //名称
    self.nameLabel.text = self.group.groupName;
    if ([self.group.groupId hasPrefix:@"XT-10001"] || [self.group.groupId hasSuffix:@"XT-10001"]) {
//         self.nameLabel.text = ASLocalizedString(@"KDToDoContainorViewController_title");
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppLanguage] isEqualToString:@"en"]) {
            self.nameLabel.text = ASLocalizedString(@"KDToDoContainorViewController_title");
        } else {
            self.nameLabel.text = self.group.groupName;
        }
    }
    
    
    NSString *str = [ContactUtils xtDateFormatterAtTimeline:self.group.lastMsgSendTime];
    self.timeLabel.text = str;
    
    NSString *content = nil;
    if (self.group.lastMsg.msgType == MessageTypeEvent) {
        content = [[XTDataBaseDao sharedDatabaseDaoInstance] queryLastContentExcludeEventMessageWithGroupId:self.group.groupId];
    }
    else {
        if (self.group.lastMsgDesc.length > 0) {
            content = self.group.lastMsgDesc;
        }
        else if (self.group.lastMsg.msgType == MessageTypeSpeech) {
            content = ASLocalizedString(@"KDPublicTopCell_Voice");
        }
        else if (self.group.lastMsg.msgType == MessageTypePicture) {
            content = ASLocalizedString(@"KDPublicTopCell_Pic");
        }
    }
    
    
    // 点对点对话。 即2个人对话时，不需要显示对方名字。——梁华
    NSMutableString *messageText = [NSMutableString string];
    if (content.length > 0) {
        if (self.group.lastMsg.nickname.length > 0 && self.group.groupType != GroupTypeDouble) {
            [messageText appendString:self.group.lastMsg.nickname];
            [messageText appendString:@":"];
        }
        else {
            if ([self.group.lastMsg.fromUserId isEqualToString:[BOSConfig sharedConfig].user.userId] && self.group.groupType != GroupTypeDouble)
            {
                [messageText appendString:ASLocalizedString(@"XTTimelineCell_Me")];
            }
            else {
                NSLog(@"%@",self.group.lastMsg.fromUserId);
                if (self.group.lastMsg.fromUserId.length > 0 && self.group.groupType != GroupTypeDouble) {
                    PersonSimpleDataModel *person = [self.group participantForKey:self.group.lastMsg.fromUserId];
                    if (person && ![person isPublicAccount] && person.personName.length > 0) {
                        [messageText appendString:person.personName];
                        [messageText appendString:@":"];
                    }
                }
            }
        }
        [messageText appendString:content];
    }
    
    float fImageVoiceOffset = 0;
    self.labelVoice.hidden = YES;

    if (self.agoraMultiCallGroupType == KDAgoraMultiCallGroupType_none)
    {
        _imageViewVoice.hidden = YES;
    }
    else
    {
        _imageViewVoice.hidden = NO;
        
        _imageViewVoice.frame = CGRectMake(12+44+12, self.messageLabel.frame.origin.y+3, 12, 12);
        if (self.agoraMultiCallGroupType == KDAgoraMultiCallGroupType_joined)
        {
            _imageViewVoice.image = [UIImage imageNamed:@"message_img_phone_3"];
            self.labelVoice.hidden = NO;
            self.labelVoice.frame = CGRectMake(MaxX(_imageViewVoice.frame)+5, Y(self.messageLabel.frame), 0, 18.0);
            
            self.labelVoice.text = ASLocalizedString(@"XTTimelineCell_Meeting");
            
            SetWidth(self.labelVoice.frame, [self.labelVoice.text sizeWithFont:self.labelVoice.font].width);
            
            fImageVoiceOffset = 12 + 5 + Width(self.labelVoice.frame) + 4;
        }
        
        if (self.agoraMultiCallGroupType == KDAgoraMultiCallGroupType_noJoined)
        {
            _imageViewVoice.image = [UIImage imageNamed:@"message_img_phone_2"];
            
            fImageVoiceOffset = 12 + 5;
        }
    }

    // [有人@你]/[有新公告]
    if ([self.group isNotifyTypeAt] || [self.group isNotifyTypeNotice])
    {
        // 配置message header label
        self.headerMessageLabel.hidden = NO;
        self.headerMessageLabel.frame = CGRectMake(_messageLabelOriginalFrame.origin.x + fImageVoiceOffset, _messageLabelOriginalFrame.origin.y, atOffsetX, _messageLabelOriginalFrame.size.height);
        self.headerMessageLabel.text = [self.group isNotifyTypeAt] ? ASLocalizedString(@"XTTimelineCell_@") : ASLocalizedString(@"Notice_New_Tip");
        [self.headerMessageLabel sizeToFit];
        atOffsetX = CGRectGetWidth(self.headerMessageLabel.frame);
        
        
        // 右移并缩短message label, 并设置草稿的文本
        self.messageLabel.frame = _messageLabelOriginalFrame;
        _messageLabelNewFrame = CGRectMake(self.messageLabel.frame.origin.x + atOffsetX + fImageVoiceOffset, self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width - atOffsetX-fImageVoiceOffset, self.messageLabel.frame.size.height);
        self.messageLabel.frame = _messageLabelNewFrame;
        self.messageLabel.text = messageText;
        
        self.headerMessageLabel.textColor = FC5;
    }
    else if (self.group.draft.length > 0) // 有草稿
    {
        // 右移并缩短message label, 并设置草稿的文本
        self.messageLabel.frame = _messageLabelOriginalFrame;
        _messageLabelNewFrame = CGRectMake(self.messageLabel.frame.origin.x + draftOffsetX + fImageVoiceOffset, self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width - draftOffsetX-fImageVoiceOffset, self.messageLabel.frame.size.height);
        self.messageLabel.frame = _messageLabelNewFrame;
        self.messageLabel.text = self.group.draft;
        // 配置message header label
        self.headerMessageLabel.hidden = NO;
        self.headerMessageLabel.frame = CGRectMake(_messageLabelOriginalFrame.origin.x + fImageVoiceOffset, _messageLabelOriginalFrame.origin.y, draftOffsetX, _messageLabelOriginalFrame.size.height);
        self.headerMessageLabel.text = ASLocalizedString(@"XTTimelineCell_Draft");
        self.headerMessageLabel.textColor = FC4;
        
    }
    else
    {
        // 没有草稿才显示新消息
        self.messageLabel.text = messageText;
        // message label恢复原状
        self.messageLabel.frame = _messageLabelOriginalFrame;
        AddX(self.messageLabel.frame, fImageVoiceOffset);
        SetWidth(self.messageLabel.frame, Width(self.messageLabel.frame) - fImageVoiceOffset);
        // 隐藏header label
        self.headerMessageLabel.hidden = YES;
    }
}

- (UIImageView *)imageViewTop
{
    if (!_imageViewTop)
    {
        _imageViewTop = [UIImageView new];
        _imageViewTop.image = [UIImage imageNamed:@"message_img_up_normal"];
        _imageViewTop.frame = CGRectMake(0, 0, 13, 13);
        _imageViewTop.hidden = YES;
    }
    return _imageViewTop;
}

- (UIImageView *)imageViewVoice
{
    if (!_imageViewVoice)
    {
        _imageViewVoice = [UIImageView new];
    }
    return _imageViewVoice;
}

- (UILabel *)labelVoice
{
    if (!_labelVoice)
    {
        _labelVoice = [UILabel new];
        _labelVoice.textColor = UIColorFromRGB(0x25c5dd);
        _labelVoice.font = FS5;
    }
    return _labelVoice;
}

@end
