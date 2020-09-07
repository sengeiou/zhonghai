//
//  DirectMessageCellView.m
//  kdweibo
//
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"

#import "DirectMessageCellView.h"
#import "KDBadgeIndicatorView.h"
#import "KDDatabaseHelper.h"
#import "KDWeiboDAOManager.h"

#import "KDDMThread.h"
#import "KDInbox.h"
#import "KDManagerContext.h"

#import "CommenMethod.h"
#import "NSDate+Additions.h"
#import "UIViewAdditions.h"
#import "KDDMMessage.h"
#import "KDUploadTaskHelper.h"

@interface DirectMessageCellView ()

@property(nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, retain) UILabel *summaryLabel;
@property(nonatomic, retain) UILabel *lastDateLabel;

@property(nonatomic, retain)UIActivityIndicatorView *activityIndicatorView;

@end


@implementation DirectMessageCellView


@synthesize titleLabel=titleLabel_;
@synthesize summaryLabel=summaryLabel_;
@synthesize lastDateLabel=lastDateLabel_;

@synthesize activityIndicatorView = activityIndicatorView_;

- (void) setupDirectMessageDetailsView {
    // title label
    titleLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel_.backgroundColor = [UIColor clearColor];
    titleLabel_.highlightedTextColor = [UIColor whiteColor];
    titleLabel_.textColor = [UIColor blackColor];
    
    titleLabel_.font = [UIFont systemFontOfSize:16];
    
    titleLabel_.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    [self addSubview:titleLabel_];
    
    // summary label
    summaryLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    summaryLabel_.backgroundColor = [UIColor clearColor];
    summaryLabel_.highlightedTextColor = [UIColor whiteColor];
    summaryLabel_.textColor = MESSAGE_ACTNAME_COLOR;
    summaryLabel_.font = [UIFont systemFontOfSize:14];
    summaryLabel_.numberOfLines = 1;
    summaryLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubview:summaryLabel_];
    
    // last date label
    lastDateLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
    lastDateLabel_.backgroundColor = [UIColor clearColor];
    lastDateLabel_.highlightedTextColor = [UIColor whiteColor];
    lastDateLabel_.textColor = MESSAGE_ACTDATE_COLOR;
    lastDateLabel_.font = [UIFont systemFontOfSize:13];
    lastDateLabel_.lineBreakMode = NSLineBreakByTruncatingTail;
    lastDateLabel_.textAlignment = NSTextAlignmentRight;
    
    [self addSubview:lastDateLabel_];
    
    audioSendFailedImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dm_thread_cell_unsend_audio_cell_v2"]];
    [audioSendFailedImageView_ sizeToFit];
    [self addSubview:audioSendFailedImageView_];
    
    activityIndicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activityIndicatorView_];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDirectMessageDetailsView];
	}
	
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetY = 10.0;
    CGFloat width = self.bounds.size.width - 20.0;
    CGFloat pw = width * 0.5;
    
    CGRect rect = CGRectMake(0.0, offsetY, width * 0.7, 16.0);
    titleLabel_.frame = rect;
    
    rect.origin.x += pw + 10.f;
    rect.size.width = pw;
    lastDateLabel_.frame = rect;
    
    offsetY += rect.size.height + 12.f;
    [summaryLabel_ sizeToFit];
    
    if(audioSendFailedImageView_.hidden == NO) {
        audioSendFailedImageView_.frame = CGRectMake(0.0f, offsetY - 2.f, audioSendFailedImageView_.image.size.width, audioSendFailedImageView_.image.size.height);
        rect = CGRectMake(audioSendFailedImageView_.frame.size.width + 2.0f, CGRectGetMaxY(audioSendFailedImageView_.frame) - summaryLabel_.bounds.size.height + 2.f, width - 36, summaryLabel_.bounds.size.height);
    }else {
        rect = CGRectMake(0.0, offsetY, width - 36, summaryLabel_.bounds.size.height);
    }
    
    if (!activityIndicatorView_.hidden) {
        rect = CGRectMake(0.0f, offsetY, 20, 20);
        activityIndicatorView_.frame = rect;
        
        rect = CGRectMake(CGRectGetMaxX(activityIndicatorView_.frame) + 2.0f, CGRectGetMaxY(activityIndicatorView_.frame) - summaryLabel_.bounds.size.height, width - 36, summaryLabel_.bounds.size.height);
    }
    
    summaryLabel_.frame = rect;
}

- (void)updateWithDMThread:(KDDMThread *)thread {
    titleLabel_.text = thread.subject;
    
    lastDateLabel_.text = nil;
    [KDDatabaseHelper inDatabase:^id(FMDatabase *fmdb){
        id<KDDMMessageDAO> messageDAO = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
        return [messageDAO queryUnsendDMMessagesWithThreadId:thread.threadId database:fmdb];
    }completionBlock:^(id results){
        if([(NSArray *)results count] > 0) {
            audioSendFailedImageView_.hidden = NO;
            KDDMMessage *msg = [(NSArray *)results objectAtIndex:0];
            BOOL isUploading = [[KDUploadTaskHelper shareUploadTaskHelper] isTaskOnRunning:msg.messageId];
            
            if([msg hasAudio]) {
                summaryLabel_.text = !isUploading ? ASLocalizedString(@"DirectMessageCellView_tips_1"): ASLocalizedString(@"DirectMessageCellView_tips_2");
                
            }else if([msg hasPicture]) {
                summaryLabel_.text = !isUploading ? ASLocalizedString(@"DirectMessageCellView_tips_3"): ASLocalizedString(@"DirectMessageCellView_tips_4");
            }else if([msg hasLocationInfo]) {
                summaryLabel_.text = !isUploading ? ASLocalizedString(@"DirectMessageCellView_tips_5"): ASLocalizedString(@"DirectMessageCellView_tips_6");
            }else {
                summaryLabel_.text = !isUploading ? ASLocalizedString(@"DirectMessageCellView_tips_7"): ASLocalizedString(@"DirectMessageCellView_tips_8");
            }
            if (isUploading) {
                activityIndicatorView_.hidden = NO;
                [activityIndicatorView_ startAnimating];
                audioSendFailedImageView_.hidden = YES;
            }else {
                activityIndicatorView_.hidden = YES;
                [activityIndicatorView_ stopAnimating];
                audioSendFailedImageView_.hidden = NO;
            }
            
            lastDateLabel_.text = [NSDate formatDayAndWeekSince1970:msg.createdAt];
        }else {
            BOOL lastestMessageByMe = [[KDManagerContext globalManagerContext].userManager isCurrentUserId:thread.latestDMSenderId];
            NSString *suffix = nil;
            NSString *postfix = nil;
            if(!lastestMessageByMe && !thread.isPublic){
                // if direct message thread is private and lastest message not creatd by me
                suffix = @"";
                
            }else if(lastestMessageByMe && !thread.isPublic){
                suffix = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"KDMeVC_me", @"")];
            }
            else {
                if (lastestMessageByMe) {
                    suffix = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"KDMeVC_me", @"")];
                }else if (thread.latestSender.screenName) {
                    suffix = [NSString stringWithFormat:@"%@:",thread.latestSender.screenName];
                }
            }
            
            postfix = thread.latestDMText?[NSString stringWithFormat:@" %@",thread.latestDMText]:@"";
            audioSendFailedImageView_.hidden = YES;
            summaryLabel_.text = [suffix stringByAppendingString:postfix];
            
            if(!summaryLabel_.text || [summaryLabel_.text isEqualToString:@""]) {
                summaryLabel_.text = ASLocalizedString(@"DirectMessageCellView_tips_9");
            }
        }
    }];
    
    if(!lastDateLabel_.text)
        lastDateLabel_.text = [NSDate formatDayAndWeekSince1970:thread.updatedAt];
    
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    titleLabel_.highlighted = highlighted;
    summaryLabel_.highlighted = highlighted;
    lastDateLabel_.highlighted = highlighted;
}


- (void)dealloc {
    //KD_RELEASE_SAFELY(titleLabel_);
    //KD_RELEASE_SAFELY(summaryLabel_);
    //KD_RELEASE_SAFELY(lastDateLabel_);
    //KD_RELEASE_SAFELY(audioSendFailedImageView_);
    
    //KD_RELEASE_SAFELY(activityIndicatorView_);
    
    //[super dealloc];
}

@end
