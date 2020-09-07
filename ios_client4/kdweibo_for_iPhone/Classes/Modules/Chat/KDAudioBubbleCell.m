//
//  KDAudioBubbleCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-5-13.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAudioBubbleCell.h"
#import "KDManagerContext.h"
#import "KDDefaultViewControllerContext.h"
#import "KDDownload.h"
#import "KDAttachment.h"
#import "KDAudioController.h"
#import "NSDate+Additions.h"

#define KD_DM_AUDIO_CELL_AVATAR_WH     40.0f
#define KD_DM_AUDIO_CELL_MARGIN        8.0f
#define KD_DM_AUDIO_CELL_PADDING       8.0f
#define KD_DM_AUDIO_CELL_BUBBLE_WIDTH       100.0f

#define KD_DM_TIME_STAMP_FONT          14.0f

@implementation KDAudioBubbleCell

@synthesize message = message_;
@synthesize avatarView = avatarView_;
@synthesize delegate = delegate_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
        [self setSelectionStyle:UITableViewCellEditingStyleNone];
        listener_ = [[KDMockDownloadListener alloc] initWithDownloadListener:self];
        [[KDDownloadManager sharedDownloadManager] addListener:listener_];
//        [listener_ release];
        
        duration_ = 0.0f;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioStopPlay:) name:KDAudioControllerAudioStopPlayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioStartPlay:) name:KDAudioControllerAudioStartPlayNotification object:nil];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupView {
    
    avatarView_ = [KDUserAvatarView avatarView];// retain];
    [avatarView_ addTarget:self action:@selector(showUserProfile:) forControlEvents:UIControlEventTouchUpInside];
    avatarView_.showVipBadge = NO;
    [self addSubview:avatarView_];
    
    bgImageView_ = [[UIImageView alloc] init];
    [self addSubview:bgImageView_];
    
    speakerImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dm_audio_cell_speaker_0_v3"]];
    [self addSubview:speakerImageView_];
    
    warningImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dm_audio_cell_warning_v2"]];
    [self addSubview:warningImageView_];
    
    unreadImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dm_audio_cell_unread"]];
    [self addSubview:unreadImageView_];
    
    loadingIndicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:loadingIndicatorView_];
    
    timeLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    timeLabel_.backgroundColor = [UIColor clearColor];
    timeLabel_.font = [UIFont systemFontOfSize:13.0f];
    timeLabel_.textColor = [UIColor grayColor];
    [self addSubview:timeLabel_];
    
    createdAtLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    createdAtLabel_.backgroundColor = RGBCOLOR(203.0, 203.0, 203.0);
    createdAtLabel_.textColor = [UIColor whiteColor];
    createdAtLabel_.font = [UIFont systemFontOfSize:KD_DM_TIME_STAMP_FONT];
    createdAtLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    createdAtLabel_.textAlignment = NSTextAlignmentCenter;
    createdAtLabel_.layer.masksToBounds = YES;
    createdAtLabel_.alpha = 0.8;
    
    createdAtLabel_.layer.cornerRadius = 5.0;
    [self addSubview:createdAtLabel_];
    
    nameLabel_ = [[UILabel alloc] init];
    nameLabel_.font = [UIFont systemFontOfSize:12.0f];
    nameLabel_.backgroundColor = [UIColor clearColor];
    nameLabel_.textColor = MESSAGE_NAME_COLOR;
    
    [self addSubview:nameLabel_];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
//    [tap release];
    
    
    state_ = KDAudioBubbleCellStateNormal;
    [self stateChangedAction];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    avatarView_.avatarDataSource = (message_.sender ? message_.sender : [[KDManagerContext globalManagerContext] userManager].currentUser);
    [speakerImageView_ sizeToFit];
    [timeLabel_ sizeToFit];
    [warningImageView_ sizeToFit];
    
    CGFloat bgWidth = MIN(104 + ((duration_ - 1) / 59.0f ) * 104, 208);
    
    CGFloat offsetY = 0.0f;
    CGFloat offsetX = 0.0f;
    
    //create at label
    if(createdAtLabel_.hidden == NO) {
        createdAtLabel_.frame = CGRectMake((self.bounds.size.width - createdAtLabel_.bounds.size.width) * 0.5f, 5.0f, createdAtLabel_.bounds.size.width, createdAtLabel_.bounds.size.height);
        
        offsetY = CGRectGetMaxY(createdAtLabel_.frame) + KD_DM_AUDIO_CELL_PADDING + 14.0f;
    }
    
    //layout avatar view
    offsetX = postByMyself_ ? (self.bounds.size.width - KD_DM_AUDIO_CELL_AVATAR_WH - KD_DM_AUDIO_CELL_MARGIN) : KD_DM_AUDIO_CELL_MARGIN;
    
    avatarView_.frame = CGRectMake(offsetX, offsetY, KD_DM_AUDIO_CELL_AVATAR_WH, KD_DM_AUDIO_CELL_AVATAR_WH);
    
    //layout name label
    [nameLabel_ sizeToFit];
    offsetX = postByMyself_ ? CGRectGetMinX(avatarView_.frame) - 2 * KD_DM_AUDIO_CELL_PADDING - CGRectGetWidth(nameLabel_.bounds) : CGRectGetMaxX(avatarView_.frame) + 2 * KD_DM_AUDIO_CELL_PADDING;
    nameLabel_.frame = CGRectMake(offsetX, offsetY, CGRectGetWidth(nameLabel_.bounds), CGRectGetHeight(nameLabel_.bounds));
    
    //layout background image view
    offsetX = postByMyself_ ? CGRectGetMinX(avatarView_.frame) - KD_DM_AUDIO_CELL_PADDING - bgWidth : CGRectGetMaxX(avatarView_.frame) + KD_DM_AUDIO_CELL_PADDING;
    bgImageView_.frame = CGRectMake(offsetX, CGRectGetMaxY(nameLabel_.frame) + 5.0f, bgWidth, KD_DM_AUDIO_CELL_AVATAR_WH + (postByMyself_ ? 8.0f : 4.0f)); //caz the image has shadow, and the two images has different shadow height.
    
    //layout speaker image view
    offsetX = postByMyself_ ? CGRectGetMaxX(bgImageView_.frame) - speakerImageView_.bounds.size.width - 20.0f : CGRectGetMinX(bgImageView_.frame) + 20.0f;
    speakerImageView_.frame = CGRectMake(offsetX, CGRectGetMinY(bgImageView_.frame) + (CGRectGetHeight(bgImageView_.bounds) - CGRectGetHeight(speakerImageView_.bounds)) * 0.5f, CGRectGetWidth(speakerImageView_.bounds), CGRectGetHeight(speakerImageView_.bounds));
    
    //layout warning image view
    offsetX = postByMyself_ ? CGRectGetMinX(bgImageView_.frame) - CGRectGetWidth(warningImageView_.bounds) - KD_DM_AUDIO_CELL_PADDING : CGRectGetMaxX(bgImageView_.frame) + KD_DM_AUDIO_CELL_PADDING;
    warningImageView_.frame = CGRectMake(offsetX, CGRectGetMinY(bgImageView_.frame) + (KD_DM_AUDIO_CELL_AVATAR_WH - CGRectGetHeight(warningImageView_.bounds)) * 0.5f, CGRectGetWidth(warningImageView_.bounds), CGRectGetHeight(warningImageView_.bounds));
    
    //layout unread image view
    offsetX = postByMyself_ ? CGRectGetMinX(bgImageView_.frame) - CGRectGetWidth(unreadImageView_.bounds) - KD_DM_AUDIO_CELL_PADDING : CGRectGetMaxX(bgImageView_.frame) + KD_DM_AUDIO_CELL_PADDING;
    unreadImageView_.frame = CGRectMake(offsetX, CGRectGetMinY(bgImageView_.frame) + (KD_DM_AUDIO_CELL_AVATAR_WH - CGRectGetHeight(unreadImageView_.bounds)) * 0.5f, CGRectGetWidth(unreadImageView_.bounds), CGRectGetHeight(unreadImageView_.bounds));
    
    //layout duration label
    offsetX = postByMyself_ ? CGRectGetMinX(bgImageView_.frame) - CGRectGetWidth(timeLabel_.bounds) - KD_DM_AUDIO_CELL_PADDING : CGRectGetMaxX(bgImageView_.frame) + KD_DM_AUDIO_CELL_PADDING;
    timeLabel_.frame = CGRectMake(offsetX, CGRectGetMaxY(bgImageView_.frame) - (KD_DM_AUDIO_CELL_AVATAR_WH - CGRectGetHeight(timeLabel_.bounds)) * 0.7f, CGRectGetWidth(timeLabel_.bounds), CGRectGetHeight(timeLabel_.bounds));
    //layout loading indicator view
    offsetX = postByMyself_ ? CGRectGetMinX(bgImageView_.frame) - CGRectGetWidth(loadingIndicatorView_.bounds) - KD_DM_AUDIO_CELL_PADDING : CGRectGetMaxX(bgImageView_.frame) + KD_DM_AUDIO_CELL_PADDING;
    loadingIndicatorView_.frame = CGRectMake(offsetX, CGRectGetMinY(bgImageView_.frame) + (KD_DM_AUDIO_CELL_AVATAR_WH - CGRectGetHeight(loadingIndicatorView_.bounds)) * 0.5f, CGRectGetWidth(loadingIndicatorView_.bounds), CGRectGetHeight(loadingIndicatorView_.bounds));
    
//    if(postByMyself_) {
//        avatarView_.frame = CGRectMake(self.bounds.size.width - KD_DM_AUDIO_CELL_AVATAR_WH - KD_DM_AUDIO_CELL_MARGIN, (self.bounds.size.height - KD_DM_AUDIO_CELL_AVATAR_WH - offsetY) * 0.5f + offsetY, KD_DM_AUDIO_CELL_AVATAR_WH, KD_DM_AUDIO_CELL_AVATAR_WH);
//        [nameLabel_ sizeToFit];
//        nameLabel_.frame = CGRectMake(CGRectGetMinX(avatarView_.frame) - CGRectGetWidth(nameLabel_.bounds) - 2 * KD_DM_AUDIO_CELL_PADDING, offsetY, CGRectGetWidth(nameLabel_.bounds), CGRectGetHeight(nameLabel_.bounds));
//        offsetY += nameLabel_.bounds.size.height + 5.0f;
//        bgImageView_.frame = CGRectMake(CGRectGetMinX(avatarView_.frame) - KD_DM_AUDIO_CELL_PADDING - bgWidth, offsetY, bgWidth, KD_DM_AUDIO_CELL_AVATAR_WH + 8.0f); // plus 8.0f ,caz the image has shadow.
//        speakerImageView_.frame = CGRectMake(CGRectGetMaxX(bgImageView_.frame) - speakerImageView_.bounds.size.width - 20.0f, (self.bounds.size.height - speakerImageView_.bounds.size.height - offsetY) * 0.5f + offsetY, speakerImageView_.bounds.size.width, speakerImageView_.bounds.size.height);
//        warningImageView_.frame = CGRectMake(CGRectGetMinX(bgImageView_.frame) - warningImageView_.bounds.size.width - KD_DM_AUDIO_CELL_PADDING, (self.bounds.size.height - warningImageView_.bounds.size.height - offsetY) * 0.5f + offsetY, warningImageView_.bounds.size.width, warningImageView_.bounds.size.height);
//        unreadImageView_.frame = CGRectMake(CGRectGetMinX(bgImageView_.frame) - unreadImageView_.image.size.width - KD_DM_AUDIO_CELL_PADDING, offsetY + 1.0f, unreadImageView_.image.size.width, unreadImageView_.image.size.height);
//        timeLabel_.frame = CGRectMake(CGRectGetMinX(bgImageView_.frame) - timeLabel_.bounds.size.width - KD_DM_AUDIO_CELL_PADDING, (self.bounds.size.height - timeLabel_.bounds.size.height - offsetY) * 0.5f + offsetY, timeLabel_.bounds.size.width, timeLabel_.bounds.size.height);
//        loadingIndicatorView_.frame = CGRectMake(CGRectGetMinX(bgImageView_.frame) - loadingIndicatorView_.bounds.size.width - KD_DM_AUDIO_CELL_PADDING, (self.bounds.size.height - loadingIndicatorView_.bounds.size.height - offsetY) * 0.5f + offsetY, loadingIndicatorView_.bounds.size.width, loadingIndicatorView_.bounds.size.height);
//    }else {
//        avatarView_.frame = CGRectMake(KD_DM_AUDIO_CELL_MARGIN, (self.bounds.size.height - KD_DM_AUDIO_CELL_AVATAR_WH - offsetY) * 0.5f + offsetY, KD_DM_AUDIO_CELL_AVATAR_WH, KD_DM_AUDIO_CELL_AVATAR_WH);
//        [nameLabel_ sizeToFit];
//        nameLabel_.frame = CGRectMake(CGRectGetMaxX(avatarView_.frame) + 2 * KD_DM_AUDIO_CELL_PADDING, offsetY, CGRectGetWidth(nameLabel_.bounds), CGRectGetHeight(nameLabel_.bounds));
//        offsetY += nameLabel_.bounds.size.height + 5.0f;
//        bgImageView_.frame = CGRectMake(CGRectGetMaxX(avatarView_.frame) + KD_DM_AUDIO_CELL_PADDING, offsetY, bgWidth, KD_DM_AUDIO_CELL_AVATAR_WH + 4.0f); // Y eight above and four here ? shadow different.
//        speakerImageView_.frame = CGRectMake(CGRectGetMinX(bgImageView_.frame) + 20.0f, (self.bounds.size.height - speakerImageView_.bounds.size.height - offsetY) * 0.50f + offsetY, speakerImageView_.bounds.size.width, speakerImageView_.bounds.size.height);
//        warningImageView_.frame = CGRectMake(CGRectGetMaxX(bgImageView_.frame) + KD_DM_AUDIO_CELL_PADDING, (self.bounds.size.height - warningImageView_.bounds.size.height - offsetY) * 0.5f + offsetY, warningImageView_.bounds.size.width, warningImageView_.bounds.size.height);
//        unreadImageView_.frame = CGRectMake(CGRectGetMaxX(bgImageView_.frame) + KD_DM_AUDIO_CELL_PADDING, offsetY + 1.0f, unreadImageView_.image.size.width, unreadImageView_.image.size.height);
//        timeLabel_.frame = CGRectMake(CGRectGetMaxX(bgImageView_.frame) + KD_DM_AUDIO_CELL_PADDING, (self.bounds.size.height - timeLabel_.bounds.size.height - offsetY) * 0.5f + offsetY, timeLabel_.bounds.size.width, timeLabel_.bounds.size.height);
//        loadingIndicatorView_.frame = CGRectMake(CGRectGetMaxX(bgImageView_.frame) + KD_DM_AUDIO_CELL_PADDING, (self.bounds.size.height - loadingIndicatorView_.bounds.size.height - offsetY) * 0.5f + offsetY, loadingIndicatorView_.bounds.size.width, loadingIndicatorView_.bounds.size.height);
//    }
}

- (void)setMessage:(KDDMMessage *)message {
    if(message_ != message) {
//        [message_ release];
        [message_ removeObserver:self forKeyPath:@"messageState"];
//         message_ = [message retain];
        [message_ addObserver:self forKeyPath:@"messageState" options:NSKeyValueObservingOptionNew context:NULL];
        postByMyself_ = (message_.sender ? [[[KDManagerContext globalManagerContext] userManager]isCurrentUserId:message_.sender.userId] : YES);
        
        NSString *bgImageName = nil;
        if(!postByMyself_) {
            bgImageName = @"dm_cell_blue_bg.png";
            speakerImageView_.layer.transform = CATransform3DIdentity;
        }else {
            bgImageName = @"dm_cell_white_bg.png";
            speakerImageView_.layer.transform = CATransform3DRotate(speakerImageView_.layer.transform, M_PI, 0, 1, 0);
        }
        
        createdAtLabel_.hidden = ![[message propertyForKey:@"kddmmessage_is_need_stamp"] boolValue];
        if(createdAtLabel_.hidden == NO) {
            createdAtLabel_.text = [NSDate formatMonthOrDaySince1970:message.createdAt];
            CGRect frame = createdAtLabel_.frame;
            frame.size = [createdAtLabel_.text sizeWithFont:createdAtLabel_.font];
            frame.size.width += 10.f;
            createdAtLabel_.frame = frame;
        }
        
        NSString *senderName = message_.sender.screenName;
        if(!senderName) {
            senderName = message_.sender.username;
        }
        nameLabel_.text = senderName;
        
        UIImage *bgImage = [UIImage imageNamed:bgImageName];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width * 0.5f topCapHeight:bgImage.size.height * 0.5f];
        bgImageView_.image = bgImage;
        
        [self updateState];
        
        [self loadAudio];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"messageState"]) {
        [self updateState];
        //[self loadAudio];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAudioControllerAudioStopPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDAudioControllerAudioStartPlayNotification object:nil];
    
    [[KDDownloadManager sharedDownloadManager] removeListener:listener_];
    
    [message_ removeObserver:self forKeyPath:@"messageState"];
//    [message_ release];
//    [avatarView_ release];
//    
//    [createdAtLabel_ release];
//    [timeLabel_ release];
//    [bgImageView_ release];
//    [warningImageView_ release];
//    [unreadImageView_ release];
//    [speakerImageView_ release];
//    [loadingIndicatorView_ release];
    
    //[super dealloc];
}

- (void) showUserProfile:(id)sender{
    [[KDDefaultViewControllerContext defaultViewControllerContext] showUserProfileViewController:message_.sender sender:sender];
}

- (void)tap:(UITapGestureRecognizer *)gest {
    CGPoint point = [gest locationInView:self];
    if(state_ == KDAudioBubbleCellStateSendFailed && CGRectContainsPoint(warningImageView_.frame, point)) {
        if(delegate_ && [delegate_ respondsToSelector:@selector(audioBubbleCellTapInWarning:)]) {
            [delegate_ audioBubbleCellTapInWarning:self];
        }
    }else if(CGRectContainsPoint(bgImageView_.frame, point)){
        if(state_ == KDAudioBubbleCellStateLoading) {
            return;
        }
        
        if(delegate_ && [delegate_ respondsToSelector:@selector(audioBubbleCellTapInSpeaker:)]) {
            [delegate_ audioBubbleCellTapInSpeaker:self];
        }
        
        if(state_ != KDAudioBubbleCellStatePlaying) {
            [[KDAudioController sharedInstance] playAudioForMessage:message_];
        }else {
            [[KDAudioController sharedInstance] stopPlay];
        }
    }
}

- (void)updateTimeLabelWithAudioPath:(NSString *)audioPath {
    Float64 duration = [[KDAudioController sharedInstance] durationOfAudionAtPath:audioPath];
    duration_ = duration;
    
    //if(duration <= 60) {
        timeLabel_.text = [NSString stringWithFormat:@"%d″", (int)ceil(duration_)];
//    }else {
//        timeLabel_.text = [NSString stringWithFormat:@"%d′%d″",((int)duration / 60), ((int)duration % 60)];
//    }
    
    [timeLabel_ sizeToFit];
    //重新设置对话框长度 王松 2013-11-19
    [self setNeedsLayout];
}

- (void)setSpeakerLevel:(CGFloat)lvl {
    
}

- (void)updateState {
    if(postByMyself_) {
        if((message_.messageState & KDDMMessageStateSending) != 0) {
            [self turnOnState:KDAudioBubbleCellStateLoading];
        }else {
            [self turnOffState:KDAudioBubbleCellStateLoading];
        }
        
        if((message_.messageState & KDDMMessageStateUnsend) != 0) {
            [self turnOnState:KDAudioBubbleCellStateSendFailed];
        }else {
            [self turnOffState:KDAudioBubbleCellStateSendFailed];
        }
    }
    
    if(message_.messageState & KDDMMessageStatePlaying) {
        [self turnOnState:KDAudioBubbleCellStatePlaying];
    }else {
        [self turnOffState:KDAudioBubbleCellStatePlaying];
    }
}

- (void)stateChangedAction {
    if(state_ == KDAudioBubbleCellStateNormal || (state_ & KDAudioBubbleCellStatePlaying) == KDAudioBubbleCellStatePlaying) {
        timeLabel_.hidden = NO;
    }else {
        timeLabel_.hidden = YES;
    }
    
    if((state_ & KDAudioBubbleCellStateSendFailed) == KDAudioBubbleCellStateSendFailed) {
        warningImageView_.hidden = NO;
        timeLabel_.hidden = YES;
    }else {
        warningImageView_.hidden = YES;
    }
    
    if(!postByMyself_) {
        unreadImageView_.hidden = !message_.unread;
    }
    
    if((state_ & KDAudioBubbleCellStateLoading) == KDAudioBubbleCellStateLoading) {
        [loadingIndicatorView_ startAnimating];
        loadingIndicatorView_.hidden = NO;
        timeLabel_.hidden = YES;
        warningImageView_.hidden = YES;
    } else {
        [loadingIndicatorView_ stopAnimating];
        loadingIndicatorView_.hidden = YES;
    }
    
    if((state_ & KDAudioBubbleCellStatePlaying) == KDAudioBubbleCellStatePlaying) {
        [speakerImageView_ setAnimationDuration:0.6f];
        [speakerImageView_ setAnimationImages:
         [NSArray arrayWithObjects:
          [UIImage imageNamed:@"dm_audio_cell_speaker_1_v3"],
          [UIImage imageNamed:@"dm_audio_cell_speaker_2_v3"],
          [UIImage imageNamed:@"dm_audio_cell_speaker_3_v3"],
          nil]];
        [speakerImageView_ setAnimationRepeatCount:0];
        [speakerImageView_ startAnimating];
    }else {
        if([speakerImageView_ isAnimating]) {
            [speakerImageView_ stopAnimating];
        }
    }
}

- (void)turnOnState:(KDAudioBubbleCellState)st {
    state_ |= st;
    [self stateChangedAction];
}

- (void)turnOffState:(KDAudioBubbleCellState)st {
    state_ &= ~st;
    [self stateChangedAction];
}

- (void)loadAudio {
    KDAttachment *att = [message_.attachments lastObject];
    if(att.fileId == nil) {
        if(att.url) {
            [self updateTimeLabelWithAudioPath:att.url];
        }
    } else {
        [KDDownload downloadsWithAttachemnts:message_.attachments
                                diretMessage:message_
                                 finishBlock:^(NSArray *downloads) {
                                     KDDownload *download = [downloads lastObject];
                                     
                                     if(![download isSuccess]) {
                                         [[KDDownloadManager sharedDownloadManager] addDownload:download];
                                         [self turnOnState:KDAudioBubbleCellStateLoading];
                                     }else {
                                         [self updateTimeLabelWithAudioPath:download.path];
                                     }
                                 }];
    }
}

+ (CGFloat)heightForAudioInMessage:(KDDMMessage *)message interval:(NSTimeInterval)interval {
    
    if(interval > CHAT_BUBBLE_TIMESTAMP_DIFF || interval == -1) {
        [message setProperty:@(YES) forKey:@"kddmmessage_is_need_stamp"];
        
        CGSize stampSize = [@"0800" sizeWithFont:[UIFont systemFontOfSize:KD_DM_TIME_STAMP_FONT]];
        
        return 60.0f + stampSize.height + 14.0f + KD_DM_AUDIO_CELL_PADDING + 20.0f;
    }else {
        [message setProperty:@(NO) forKey:@"kddmmessage_is_need_stamp"];
        return 60.0f + 20.0f;
    }
}

- (void)audioStartPlay:(NSNotification *)noti {
    NSString *messageID = [noti.userInfo objectForKey:KDAudioControllerAudioMessageIDUserInfoKey];
    if([messageID isEqualToString:message_.messageId]) {
        [self turnOnState:KDAudioBubbleCellStatePlaying];
        self.message.unread = NO;
        [self stateChangedAction];
    }
}

- (void)audioStopPlay:(NSNotification *)noti {
    if((state_ & KDAudioBubbleCellStatePlaying) == KDAudioBubbleCellStatePlaying) {
        NSString *messageID = [noti.userInfo objectForKey:KDAudioControllerAudioMessageIDUserInfoKey];
        if([messageID isEqualToString:message_.messageId]) {
            [self turnOffState:KDAudioBubbleCellStatePlaying];
        }
    }
}

#pragma mark - KDDownloadListener
- (void)downloadProgressDidChange:(KDRequestProgressMonitor *)monitor {
    
}

- (void)downloadStateDidChange:(KDDownload *)download {
    if([download.entityId isEqualToString:message_.messageId]) {
        [self turnOffState:KDAudioBubbleCellStateLoading];
        
        if([download isSuccess]) {
            [self updateTimeLabelWithAudioPath:download.path];
        }
    }
}
@end
