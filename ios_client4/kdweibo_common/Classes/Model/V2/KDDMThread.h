//
//  KDDMThread.h
//  kdweibo
//
//  Created by laijiandong on 5/24/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDObject.h"
#import "KDUser.h"

#import "KDAvatarProtocol.h"

@interface KDDMThread : KDObject<KDCompositeAvatarDataSource> {
 @private
    NSString *threadId_;
    NSString *subject_;
    NSString *avatarURL_;
    NSArray *participantAvatarURLs_;
    
    NSTimeInterval createdAt_;
    NSTimeInterval updatedAt_;
    
    NSString *latestDMId_;
    NSString *latestDMText_;
    NSString *latestDMSenderId_;
    
    NSString *nextSinceDMId_;
    
    BOOL isPublic_;
    NSUInteger unreadCount_;
    
    NSString *participantIDs_;
    NSUInteger participantsCount_;
    
    KDUser *latestSender_;
}

@property (nonatomic, retain) NSString *threadId;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *avatarURL;
@property (nonatomic, retain) NSArray *participantAvatarURLs;

@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) NSTimeInterval updatedAt;

@property (nonatomic, retain) NSString *latestDMId;
@property (nonatomic, retain) NSString *latestDMText;
@property (nonatomic, retain) NSString *latestDMSenderId;

@property (nonatomic, retain) NSString *nextSinceDMId;

@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, assign) NSUInteger unreadCount;

@property (nonatomic, retain) NSString *participantIDs;
@property (nonatomic, assign) NSUInteger participantsCount;

@property (nonatomic, retain) KDUser *latestSender;

@property (nonatomic, assign) BOOL isTop;


- (NSString *)id_;

@end
