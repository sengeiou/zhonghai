//
//  KDPublicAccountCache.m
//  kdweibo
//
//  Created by Gil on 15/3/31.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPublicAccountCache.h"
#import "TMMemoryCache.h"
#import "XTDataBaseDao.h"
#import "KDPubAcctFetch.h"

@interface KDPublicAccountCache ()
@property (nonatomic, strong) TMMemoryCache *memory;
@property (nonatomic, strong) KDPubAcctFetch *fetcher;
@end

@implementation KDPublicAccountCache

+ (instancetype)sharedPublicAccountCache
{
    static id cache;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        cache = [[self alloc] init];
    });
    
    return cache;
}

- (id)init {
    self = [super init];
    if (self) {
        self.memory = [[TMMemoryCache alloc] init];
        self.memory.costLimit = 100;
        self.memory.removeAllObjectsOnMemoryWarning = NO;
        self.memory.removeAllObjectsOnEnteringBackground = NO;
    }
    return self;
}

- (KDPubAcctFetch *)fetcher {
    if (_fetcher == nil) {
        _fetcher = [[KDPubAcctFetch alloc] init];
    }
    return _fetcher;
}

#pragma mark - Person Cache

- (KDPublicAccountDataModel *)pubAcctForKey:(NSString *)key {
    return [self pubAcctForKey:key completionBlock:nil];
}


- (KDPublicAccountDataModel *)pubAcctForKey:(NSString *)key completionBlock:(KDPubAcctFetchCompletionBlock)completionBlock
{
    if (key.length == 0) {
        return nil;
    }
    
    id person = [self.memory objectForKey:key];
    
    if (!person) {
        person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPublicAccountWithId:key];
        if (person) {
            [self setPubAcct:person forKey:key];
        }
        else {
            [self.fetcher fetchWithPubAcctIds:@[key] completionBlock:completionBlock];
        }
    }
    
    return person;
}

- (void)setPubAcct:(KDPublicAccountDataModel *)person forKey:(NSString *)key {
    if (key.length == 0 || !person) {
        return;
    }
    
    [self.memory setObject:person forKey:key withCost:1];
}

- (void)removePubAcctForKey:(NSString *)key {
    if (key.length == 0) {
        return;
    }
    [self.memory removeObjectForKey:key];
}

- (void)removeAllPubAccts {
    [self.memory removeAllObjects];
}

@end
