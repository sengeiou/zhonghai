//
//  KDGroup.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDObject.h"
#import "KDAvatarProtocol.h"

typedef enum : NSUInteger {
    KDGroupTypePrivate = 1,
    KDGroupTypePublic
}KDGroupType;

@interface KDGroup : KDObject <KDAvatarDataSource>

@property(nonatomic, retain) NSString *groupId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *profileImageURL;
@property(nonatomic, retain) NSString *summary;
@property(nonatomic, retain) NSString *bulletin;
@property(nonatomic, retain) NSString *latestMsgContent;
@property(nonatomic, retain) NSDate *latestMsgDate;

@property(nonatomic, assign) KDGroupType type;
@property(nonatomic, assign) NSUInteger sortingIndex; // just used on query the groups from database
@property(nonatomic, assign) NSInteger messageCount;
@property(nonatomic, assign) NSInteger memberCount;
- (BOOL)isPrivate; // return YES means this is private group, otherwise is not.

@end
