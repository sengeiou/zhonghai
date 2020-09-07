//
//  KDGroup.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDGroup.h"

#import "KDCache.h"
#import "KDImageSize.h"

@implementation KDGroup

@synthesize groupId=groupId_;
@synthesize name=name_;
@synthesize profileImageURL=profileImageURL_;
@synthesize summary=summary_;
@synthesize bulletin=bulletin_;

@synthesize type=type_;
@synthesize sortingIndex=sortingIndex_;
@synthesize latestMsgContent = latestMsgContent_;
@synthesize latestMsgDate = latestMsgDate_;

- (id)init {
    self = [super init];
    if (self) {
        type_ = KDGroupTypePrivate;
    }
    
    return self;
}

- (BOOL)isPrivate {
    return KDGroupTypePrivate == type_;
}

///////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark KDAvatarDataSource protocol method

- (KDAvatarType)getAvatarType {
    return KDAvatarTypeGroup;
}

- (KDImageSize *)avatarScaleToSize {
    return [KDImageSize defaultGroupAvatarSize];
}

- (NSString *)getAvatarLoadURL {
    return profileImageURL_;
}

- (NSString *)getAvatarCacheKey {
    NSString *cacheKey = [super propertyForKey:kKDAvatarPropertyCacheKey];
    if(cacheKey == nil){
        NSString *loadURL = [self getAvatarLoadURL];
        cacheKey = [KDCache cacheKeyForURL:loadURL];
        if(cacheKey != nil){
            [super setProperty:cacheKey forKey:kKDAvatarPropertyCacheKey];
        }
    }
    
    return cacheKey;
}

- (void)removeAvatarCacheKey {
    [super setProperty:nil forKey:kKDAvatarPropertyCacheKey];
}

- (void)dealloc {
    
    //KD_RELEASE_SAFELY(latestMsgContent_);
    //KD_RELEASE_SAFELY(latestMsgDate_);
    //KD_RELEASE_SAFELY(groupId_);
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(profileImageURL_);
    //KD_RELEASE_SAFELY(summary_);
    //KD_RELEASE_SAFELY(bulletin_);
    
    //[super dealloc];
}

@end
