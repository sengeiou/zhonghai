//
//  KDDMThread.m
//  kdweibo
//
//  Created by laijiandong on 5/24/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDDMThread.h"

#import "KDCache.h"

@implementation KDDMThread

@synthesize threadId=threadId_;
@synthesize subject=subject_;
@synthesize avatarURL=avatarURL_;
@synthesize participantAvatarURLs=participantAvatarURLs_;

@synthesize createdAt=createdAt_;
@synthesize updatedAt=updatedAt_;

@synthesize latestDMId=latestDMId_;
@synthesize latestDMText=latestDMText_;
@synthesize latestDMSenderId=latestDMSenderId_;
@synthesize nextSinceDMId=nextSinceDMId_;

@synthesize isPublic=isPublic_;
@synthesize unreadCount=unreadCount_;

@synthesize participantIDs=participantIDs_;
@synthesize participantsCount=participantsCount_;

@synthesize latestSender=latestSender_;

@synthesize isTop = isTop_;

- (id)init {
    self = [super init];
    if(self){
        threadId_ = nil;
        subject_ = nil;
        avatarURL_ = nil;
        
        createdAt_ = 0.0;
        updatedAt_ = 0.0;
        
        latestDMId_ = nil;
        latestDMText_ = nil;
        latestDMSenderId_ = nil;
        
        nextSinceDMId_ = nil;
        
        isPublic_ = NO;
        unreadCount_ = 0;
        participantsCount_ = 0;
        
        latestSender_ = nil;
        
        isTop_ = NO;

    }
    
    return self;
}

- (NSComparisonResult)compare:(KDDMThread *)obj
{
    if (self.updatedAt>obj.updatedAt)
        return NSOrderedAscending;
    else if(self.updatedAt < obj.updatedAt)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
    
}

- (NSComparisonResult)logicCompare:(KDDMThread *)obj
{
    
//    if (self.isTop == obj.isTop)
//        return [self compare:obj];
//    else
//        return NSOrderedSame;
    return [self compare:obj];
}


///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAvatarDataSource protocol methods

- (KDAvatarType)getAvatarType {
    return KDAvatarTypeDMThread;
}

- (KDImageSize *)avatarScaleToSize {
    return self.isPublic ? [KDImageSize defaultDMThreadAvatarSize] : [KDImageSize defaultUserAvatarSize];
}

- (NSString *)getAvatarLoadURL {
    return [self avatarLoadURLAtIndex:0x00];
}

- (NSString *)getAvatarCacheKey {
    return [self avatarCacheKeyAtIndex:0x00];
}

- (void)removeAvatarCacheKey {
    // unsupport now.
}

- (NSString *)avatarLoadURLAtIndex:(NSUInteger)index {
    NSString *url = nil;
    if (participantAvatarURLs_ != nil && index < [participantAvatarURLs_ count]) {
        url = [participantAvatarURLs_ objectAtIndex:index];
    }
    
    return url;
}

- (NSString *)avatarCacheKeyAtIndex:(NSUInteger)index {
    NSString *url = [self avatarLoadURLAtIndex:index];
    NSString *cacheKey = nil;
    if (url != nil) {
        cacheKey = [super propertyForKey:url];
        if(cacheKey == nil){
            cacheKey = [KDCache cacheKeyForURL:url];
            if(cacheKey != nil){
                [super setProperty:cacheKey forKey:url];
            }
        }
    }
    
    return cacheKey;
}

// fro ipad view transiton
- (NSString *)id_ {
    return self.threadId;
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(threadId_);
    //KD_RELEASE_SAFELY(subject_);
    //KD_RELEASE_SAFELY(avatarURL_);
    //KD_RELEASE_SAFELY(participantAvatarURLs_);
    
    //KD_RELEASE_SAFELY(latestDMId_);
    //KD_RELEASE_SAFELY(latestDMSenderId_);
    //KD_RELEASE_SAFELY(latestDMText_);
    
    //KD_RELEASE_SAFELY(nextSinceDMId_);
    
    //KD_RELEASE_SAFELY(participantIDs_);
    //KD_RELEASE_SAFELY(latestSender_);
    
    //[super dealloc];
}

@end
