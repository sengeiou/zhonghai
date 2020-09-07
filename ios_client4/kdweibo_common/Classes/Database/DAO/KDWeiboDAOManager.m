//
//  KDWeiboDAOManager.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-7.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDWeiboDAOManager.h"

#import "KDABPersonDAOImpl.h"
#import "KDDownloadDAOImpl.h"
#import "KDAttachmentDAOImpl.h"
#import "KDUserDAOImpl.h"
#import "KDGroupDAOImpl.h"
#import "KDCompositeImageSourceDAOImpl.h"
#import "KDDraftDAOImpl.h"
#import "KDDMThreadDAOImpl.h"
#import "KDDMMessageDAOImpl.h"
#import "KDVoteDAOImpl.h"
#import "KDStatusDAOImpl.h"
#import "KDExtendStatusDAOImpl.h"
#import "KDStatusExtraMessageDAOImpl.h"
#import "KDTopicDAOImpl.h"
#import "KDInboxDAOImpl.h"
#import "KDTodoDAOImpl.h"
#import "KDSigninRecordDAOImpl.h"
#import "KDApplicationDAOImpl.h"

@interface KDWeiboDAOManager ()

@property(nonatomic, retain) NSMutableDictionary *daoMap;

@end


@implementation KDWeiboDAOManager

@synthesize daoMap=daoMap_;

- (id)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    
    return self;
}

- (NSString *)_classToKey:(Class)clazz {
    return NSStringFromClass(clazz);
}

- (void)_addDAOWithClass:(Class)clazz {
    id parser = [[clazz alloc] init];
    [daoMap_ setObject:parser forKey:[self _classToKey:clazz]];
//    [parser release];
}

// setup some data access object(DAO) as default to aviod alloc memory frequency.
- (void)_setup {
    daoMap_ = [[NSMutableDictionary alloc] init];
    
    // address book person
    [self _addDAOWithClass:[KDABPersonDAOImpl class]];
    
    // download
    [self _addDAOWithClass:[KDDownloadDAOImpl class]];
    
    // attachment
    [self _addDAOWithClass:[KDAttachmentDAOImpl class]];
    
    // user
    [self _addDAOWithClass:[KDUserDAOImpl class]];
    
    // group
    [self _addDAOWithClass:[KDGroupDAOImpl class]];
    
    // compiste image source
    [self _addDAOWithClass:[KDCompositeImageSourceDAOImpl class]];
    
    // draft
    [self _addDAOWithClass:[KDDraftDAOImpl class]];
    
    // direct message thread
    [self _addDAOWithClass:[KDDMThreadDAOImpl class]];
    
    // direct message thread message
    [self _addDAOWithClass:[KDDMMessageDAOImpl class]];
    
    // vote
    [self _addDAOWithClass:[KDVoteDAOImpl class]];
    
    // status
    [self _addDAOWithClass:[KDStatusDAOImpl class]];
    
    // extend status
    [self _addDAOWithClass:[KDExtendStatusDAOImpl class]];
    
    // status extra message
    [self _addDAOWithClass:[KDStatusExtraMessageDAOImpl class]];
    
    //favorited topic
    [self _addDAOWithClass:[KDTopicDAOImpl class]];
    
    //inbox list
    [self _addDAOWithClass:[KDInboxDAOImpl class]];
    
    //todo list
    [self _addDAOWithClass:[KDTodoDAOImpl class]];
    
    //sign list
    [self _addDAOWithClass:[KDSigninRecordDAOImpl class]];
    
    //application list
    [self _addDAOWithClass:[KDApplicationDAOImpl class]];
}

+ (KDWeiboDAOManager *)globalWeiboDAOManager {
    static KDWeiboDAOManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KDWeiboDAOManager alloc] init];
    });
    
    return manager;
}

- (id)_daoWithClass:(Class)clazz {
    // check the class can not be Nil
    if (clazz == Nil) return nil;
    
    // try to find out parser from map
    id parser = [daoMap_ objectForKey:[self _classToKey:clazz]];
    if (parser != nil) {
        return parser;
    }
    
    // if there is not exist associate parser for class, create one
    return [[clazz alloc] init];// autorelease];
}

- (id<KDABPersonDAO>)ABPersonDAO {
    return [self _daoWithClass:[KDABPersonDAOImpl class]];
}

- (id<KDDownloadDAO>)downloadDAO {
    return [self _daoWithClass:[KDDownloadDAOImpl class]];
}

- (id<KDAttachmentDAO>)attachmentDAO {
    return [self _daoWithClass:[KDAttachmentDAOImpl class]];
}

- (id<KDUserDAO>)userDAO {
    return [self _daoWithClass:[KDUserDAOImpl class]];
}

- (id<KDGroupDAO>)groupDAO {
    return [self _daoWithClass:[KDGroupDAOImpl class]];
}

- (id<KDCompositeImageSourceDAO>)compositeImageSourceDAO {
    return [self _daoWithClass:[KDCompositeImageSourceDAOImpl class]];
}

- (id<KDDraftDAO>)draftDAO {
    return [self _daoWithClass:[KDDraftDAOImpl class]];
}

- (id<KDDMThreadDAO>)dmThreadDAO {
    return [self _daoWithClass:[KDDMThreadDAOImpl class]];
}

- (id<KDDMMessageDAO>)dmMessageDAO {
    return [self _daoWithClass:[KDDMMessageDAOImpl class]];
}

- (id<KDVoteDAO>)voteDAO {
    return [self _daoWithClass:[KDVoteDAOImpl class]];
}

- (id<KDStatusDAO>)statusDAO {
    return [self _daoWithClass:[KDStatusDAOImpl class]];
}

- (id<KDExtendStatusDAO>)extendStatusDAO {
    return [self _daoWithClass:[KDExtendStatusDAOImpl class]];
}

- (id<KDStatusExtraMessageDAO>)statusExtraMessageDAO {
    return [self _daoWithClass:[KDStatusExtraMessageDAOImpl class]];
}

- (id<KDTopicDAO>)topicDAO {
    return [self _daoWithClass:[KDTopicDAOImpl class]];
}
- (id<KDInboxDAO>)inboxDAO
{
    return [self _daoWithClass:[KDInboxDAOImpl class]];
}
- (id<KDTodoDAO>)todoDAO
{
    return [self _daoWithClass:[KDTodoDAOImpl class]];
}
- (id<KDSigninRecordDAO>)signinDAO
{
    return [self _daoWithClass:[KDSigninRecordDAOImpl class]];
}

- (id<KDApplicationDAO>)applicationDAO
{
    return [self _daoWithClass:[KDApplicationDAOImpl class]];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(daoMap_);
    
    //[super dealloc];
}

@end
