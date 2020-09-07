//
//  KDDBManager.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDCommon.h"
#import "KDDBManager.h"

#import "KDConfigurationContext.h"
#import "KDUtility.h"
#import "KDDBSchema.h"


@interface KDDBManager ()

@property (nonatomic, retain) FMDatabaseQueue *fmdbQueue;
@property (nonatomic, retain) NSString *communityId;

@end


@implementation KDDBManager

@synthesize fmdbQueue=fmdbQueue_;
@synthesize communityId=communityId_;

- (id)init {
    self = [super init];
    if (self) {
    
    }
    
    return self;
}

+ (KDDBManager *)sharedDBManager {
    static KDDBManager *sharedDBManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDBManager = [[KDDBManager alloc] init];
    });
    
    return sharedDBManager;
}

- (BOOL)tryConnectToCommunity:(NSString *)communityId {
    BOOL succeed = NO;
    if (![communityId_ isEqualToString:communityId]) {
        if (fmdbQueue_ != nil) {
            [fmdbQueue_ close];
            fmdbQueue_ = nil;
            //KD_RELEASE_SAFELY(fmdbQueue_);
        }
        
        self.communityId = communityId;
    }
	
    //创建数据库
	if(fmdbQueue_ == nil){
        succeed = [self _tryConnect];
    }
    
    return succeed;
}

- (BOOL)isConnectingWithCommunity:(NSString *)communityId {
    return [communityId_ isEqualToString:communityId] && fmdbQueue_ != nil;
}

- (void)close {
    if (fmdbQueue_ != nil) {
        [fmdbQueue_ close];
        fmdbQueue_ = nil;
        //KD_RELEASE_SAFELY(fmdbQueue_);
    }
    
    if (communityId_ != nil) {
        communityId_ = nil;
        //KD_RELEASE_SAFELY(communityId_);
    }
}

- (BOOL)_tryConnect {
    NSString *databaseName = [self _buildDatabaseName:communityId_];
    NSString *databasePath = [self _databasePathWithName:databaseName];
    
    // database is available
    BOOL available = [self _databaseAvailableWithPath:databasePath];
    
    if (!available) {
        // setup database with schema
        available = [self _setupDatabaseWithPath:databasePath];
    }
    
    if (available) {
        // connect to database
        available = [self _connect:databasePath];
    }
    
    return available;
}

- (BOOL)_databaseAvailableWithPath:(NSString *)path {
    BOOL avaiable = NO;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        BOOL shouldUpgrade = NO;
        
        // check user version from database
        int currentVersion = 0;
        FMDatabase *fmdb = [[FMDatabase alloc] initWithPath:path];
        if ([fmdb open]) {
            if ([self _queryDatabaseUserVersion:&currentVersion in:fmdb]) {
                NSUInteger latestVersion = [self _databaseUserVersion];
                if (currentVersion < latestVersion) {
                    shouldUpgrade = YES;
                    
                } else {
                    avaiable = YES;
                }
            }
            
        } else {
            NSAssert(NO, @"Can not open the database with path=%@", path);
        }
        
        // close database immediately
        [fmdb close];
//        [fmdb release];
        
        // should upgrade database
        if (shouldUpgrade) {
            NSError *error = nil;
            if (![fm removeItemAtPath:path error:&error]) {
                DLog(@"Can not remove database with path=%@ and error:%@", path, error);
            }
        }
    }
    
    return avaiable;
}




- (void)deleteCurrentCompanyDataBase {
//gordon_wu 修改内存泄露 2014.08.04
    NSString *communityId = [communityId_ copy] ;//autorelease];
    NSString *databaseName = [self _buildDatabaseName:communityId];
    NSString *databasePath = [self _databasePathWithName:databaseName];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:databasePath error:&error];
    if (error) {
        NSLog(@"error happend %@",[error localizedDescription]);
    }
    [self close];
}

// for now, upgrade same as first setup database.
- (BOOL)_setupDatabaseWithPath:(NSString *)path {
    NSString *parentPath = [path stringByDeletingLastPathComponent];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL setup = YES;
    BOOL isDir = NO;
    if ([fm fileExistsAtPath:parentPath isDirectory:&isDir]) {
        if (isDir) {
            setup = NO;
        }
    }
    
    if (setup) {
        BOOL flag = [fm createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:NULL];
        if (!flag) {
            DLog(@"Can not create database parent path=%@", parentPath);
        }
    }
    
    BOOL succeed = NO;
    
    // open the database, if the database file not exists, the sqlite will create one
    FMDatabase *fmdb = [[FMDatabase alloc] initWithPath:path];
    if ([fmdb open]) {
        // setup database schema
//        NSData *data = [self _databaseSchemaAsData];
//        NSString *schema = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//       
//        const char *sql = [schema UTF8String];
//        [schema release];
//        
//        char *message = NULL;
//        int status = sqlite3_exec([fmdb sqliteHandle], sql, NULL, NULL, &message);
//        if(SQLITE_OK == status){
//            // set database user version
//            [self _updateDatabaseUserVersion:fmdb];
//            
//            succeed = YES;
//            
//        }else {
//            if(message != NULL){
//                NSLog(@"Can not setup database schema with message:%s", message);
//                
//                sqlite3_free(message);
//                message = NULL;
//            }
//        }
        
        //setup methods 2:
        NSDictionary *schemas = [KDDBSchema tablesNameToSchema];
        BOOL success = YES;
        for(NSString *schema in schemas.allKeys) {
            NSString *name = [schemas objectForKey:schema];
            const char *sql = [schema UTF8String];
            
            char *msg = NULL;
            int status = sqlite3_exec([fmdb sqliteHandle], sql, NULL, NULL, &msg);
            
            if(SQLITE_OK == status) {
                DLog(@"did finished create table : %@", name);
            }else {
                DLog(@"fail to create table : %@. with error : %s", name, msg);
                success = NO;
                break;
            }
        }
        
        if(success) {
            [self _updateDatabaseUserVersion:fmdb];
            succeed = YES;
        }
        
    } else {
        DLog(@"Can not open the database with error code=%d message:%@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
    }
    
    // close database immediately
    [fmdb close];
  ///  [fmdb release];
    
    return succeed;
}

- (BOOL)_connect:(NSString *)databasePath {
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:databasePath];
    self.fmdbQueue = queue;
    //[queue release];
    
    return fmdbQueue_ != nil;
}

- (NSString *)_buildDatabaseName:(NSString *)communityId {
    return [NSString stringWithFormat:@"%@.db", communityId];
}

- (NSData *)_databaseSchemaAsData {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Common" ofType:@"bundle"]];
    NSURL *url = [NSURL fileURLWithPath:[bundle pathForResource:@"SQL/createV2" ofType:@"sql"]];
    NSAssert(url, ASLocalizedString(@"KDDBManager_NoFind"));
    return [NSData dataWithContentsOfURL:url];
}

- (BOOL)_queryDatabaseUserVersion:(int *)version in:(FMDatabase *)fmdb {
    BOOL succeed = NO;
    
    FMResultSet *rs = [fmdb executeQuery:@"PRAGMA user_version;"];
    if ([rs next]) {
        succeed = YES;
        *version = [rs intForColumnIndex:0];
    }
    [rs close];
    return succeed;
}

- (void)_updateDatabaseUserVersion:(FMDatabase *)fmdb {
    NSUInteger version = [self _databaseUserVersion];
    
    NSString *sql = [NSString stringWithFormat:@"PRAGMA user_version=%lu;", (unsigned long)version];
    if (![fmdb executeUpdate:sql]) {
        DLog(@"Set database user version with error code=%d message:%@", [fmdb lastErrorCode], [fmdb lastErrorMessage]);
    }
}

- (NSString *)_databasePathWithName:(NSString *)name {
    NSString *path = [[KDUtility defaultUtility] searchDirectory:KDUserDatabaseDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
    path = [path stringByAppendingPathComponent:name];
    
    return path;
}

- (NSUInteger)_databaseUserVersion {
    return [[[KDConfigurationContext getCurrentConfigurationContext] getDefaultPlistInstance] getBaseDatabaseUserVersion];
}

- (void)dealloc {
    //KD_RELEASE_SAFELY(fmdbQueue_);
    //KD_RELEASE_SAFELY(communityId_);
    
    //[super dealloc];
}

@end
