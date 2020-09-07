//
//  KDDMMessage.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDDMMessage.h"
#import "NSDate+Additions.h"
#import "NSString+Additions.h"
#import "KDAttachment.h"
#import "KDManagerContext.h"
#import "NSDate+Additions.h"


@implementation KDDMMessage

@synthesize messageId=messageId_;

@synthesize message=message_;
@synthesize createdAt=createdAt_;
@synthesize isSystemMessage=isSystemMessage_;
@synthesize messageState = messageState_;
@synthesize unread = unread_;

@synthesize latitude = latitude_;
@synthesize longitude = longitude_;
@synthesize address = address_;

@synthesize compositeImageSource=compositeImageSource_;
@synthesize attachments=attachments_;

@synthesize sender=sender_;
@synthesize recipient=recipient_;

@synthesize extraSourceMask=extraSourceMask_;

@synthesize bubbleRect=bubbleRect_;
@synthesize needTimestamp=needTimestamp_;
@synthesize timestamp = timestamp_ ;
@synthesize threadId = threadId_;

- (id)init {
    self = [super init];
    if (self) {
        extraSourceMask_ = KDExtraSourceMaskNone;
    }
    
    return self;
}
- (void)poulatedByMessage:(KDDMMessage *)message {
    self.messageId = message.messageId;
    self.message = message.message;
    self.isSystemMessage = message.isSystemMessage;
    self.messageState = message.messageState;
    self.unread = message.unread;
    self.latitude = message.latitude;
    self.longitude = message.longitude;
    self.address = message.address;
    self.compositeImageSource = message.compositeImageSource;
    self.compositeImageSource.entity = self;
    self.attachments = message.attachments;
    self.sender = message.sender;
    self.recipient = message.recipient;
    self.extraSourceMask = message.extraSourceMask;
    self.threadId = message.threadId;
    self.needTimestamp = message.needTimestamp;
    self.bubbleRect = message.bubbleRect;
    self.timestamp = message.timestamp;
}
- (NSString*)timestamp {
	if(timestamp_ == nil){
        self.timestamp = [NSDate formatMonthOrDaySince1970:self.createdAt];
    }
    
    return timestamp_;
}

- (BOOL)hasAudio {
    if(attachments_ && attachments_.count == 1) {
        KDAttachment *att = [attachments_ objectAtIndex:0];
        if([att.filename hasSuffix:@".amr"] || [att.url hasSuffix:@".amr"]) {
            return YES;
        }
    }
    
    return NO;
}
- (BOOL)hasVideo
{
    return NO;
}
- (BOOL)hasPicture {
    if(compositeImageSource_) {
        NSArray *imageSources = [compositeImageSource_ imageSources];
        if(imageSources.count > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)hasLocationInfo {
    if(address_ && ![address_ isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)shouldDisplayTimeStamp:(NSArray *)messages {
    KDDMMessage *lastMsg = nil;
    NSUInteger index = [messages indexOfObject:self];
    if (0 < index) {
           lastMsg = [messages objectAtIndex:index - 1];
    }
    return (nil == lastMsg || 300 < [[NSDate dateWithTimeIntervalSince1970: self.createdAt] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970: lastMsg.createdAt]]);
}

- (NSString *)formatedCreateAt {
    return  [[NSDate dateWithTimeIntervalSince1970:self.createdAt] formatRelativeTime];
}

- (NSString *)id_ {
    return self.messageId;
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(messageId_);
    
    //KD_RELEASE_SAFELY(message_);
    //KD_RELEASE_SAFELY(compositeImageSource_);
    //KD_RELEASE_SAFELY(attachments_);
    //KD_RELEASE_SAFELY(address_);
    //KD_RELEASE_SAFELY(sender_);
    //KD_RELEASE_SAFELY(recipient_);
    //KD_RELEASE_SAFELY(timestamp_);
    //KD_RELEASE_SAFELY(threadId_);
    
    //[super dealloc];
}
- (NSTimeInterval)createdAtTime
{
    return createdAt_;
}
- (BOOL)isSending
{
    return messageState_ & KDDMMessageStateSending;
}
- (BOOL)isSendFailure
{
    return (messageState_ & KDDMMessageStateUnsend) && !(messageState_ & KDDMMessageStateSended);
}
@end
