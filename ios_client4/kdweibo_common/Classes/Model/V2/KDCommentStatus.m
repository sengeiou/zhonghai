//
//  KDCommentStatus.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-4.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDCommentStatus.h"
#import "NSDate+Additions.h"

@implementation KDCommentStatus

@synthesize replyCommentText = replyCommentText_;
@synthesize status = status_;
@synthesize timestamp = timestamp_;
@synthesize messageState = messageState_;
- (void)dealloc {
    //KD_RELEASE_SAFELY(timestamp_);
    //KD_RELEASE_SAFELY(replyCommentText_);
    //KD_RELEASE_SAFELY(status_);
    //[super dealloc];
}
#pragma mark - ChatBubbleCellDataSource

- (BOOL)hasLocationInfo
{
    return NO;
}

- (NSString *)message
{
    return self.text;
}
- (BOOL)isSystemMessage
{
    return NO;
}
- (KDUser *)sender
{
    return self.author;
}
- (NSTimeInterval)createdAtTime
{
    return [self.createdAt timeIntervalSince1970];
}

- (NSString *)timestamp {
	if(timestamp_ == nil){
        self.timestamp = [NSDate formatMonthOrDaySince1970:[self createdAtTime]];
    }
    
    return timestamp_;
}
- (BOOL)isSending
{
    return messageState_ & KDCommentStateSending;
}
- (BOOL)isSendFailure
{
    return (messageState_ & KDCommentStateUnsend) && !(messageState_ & KDCommentStateSended);
}
@end
