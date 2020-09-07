//
//  KDDMMessage.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"

#import "KDUser.h"
#import "KDCompositeImageSource.h"

typedef enum {
    KDDMMessageStateUnsend = 1 << 1,
    KDDMMessageStateSending = 1 << 2,
    KDDMMessageStatePlaying = 1 << 3,
    KDDMMessageStateSended = 1 << 4
}KDDMMessageState;

@interface KDDMMessage : KDObject

@property(nonatomic, retain) NSString *messageId;

@property(nonatomic, retain) NSString *message;
@property(nonatomic, assign) NSTimeInterval createdAt;
@property(nonatomic, assign) BOOL isSystemMessage;
@property(nonatomic, assign) KDDMMessageState messageState;
@property(nonatomic, assign) BOOL unread;

@property(nonatomic, assign) float latitude;
@property(nonatomic, assign) float longitude;
@property(nonatomic, copy)   NSString *address;

@property(nonatomic, retain) KDCompositeImageSource *compositeImageSource;
@property(nonatomic, retain) NSArray *attachments;

@property(nonatomic, retain) KDUser *sender;
@property(nonatomic, retain) KDUser *recipient;

@property(nonatomic, assign) KDExtraSourceMask extraSourceMask;
@property(nonatomic, assign) BOOL needTimestamp;

@property(nonatomic, assign) CGRect bubbleRect;
@property(nonatomic, copy) NSString *timestamp;
@property(nonatomic, copy) NSString *threadId;

- (void)poulatedByMessage:(KDDMMessage *)message;
- (BOOL)hasAudio;
- (BOOL)hasPicture;
- (BOOL)hasLocationInfo;
- (BOOL)shouldDisplayTimeStamp:(NSArray *)messages;
- (NSString *)formatedCreateAt;
- (BOOL)hasVideo;
@end
