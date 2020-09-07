//
//  KDApplicationDAOImpl.m
//  kdweibo_common
//
//  Created by shen kuikui on 14-1-9.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDApplicationDAOImpl.h"
#import "KDApplication.h"

@implementation KDApplicationDAOImpl

- (KDApplication *)applicationWithResultSet:(FMResultSet *)rs
{
    KDApplication *application = [[KDApplication alloc] init];// autorelease];
    
    int idx = 0;
    
    application.appId = [rs stringForColumnIndex:idx++];
    application.desc = [rs stringForColumnIndex:idx++];
    application.detailDesc = [rs stringForColumnIndex:idx++];
    application.httpUrl = [rs stringForColumnIndex:idx++];
    application.iconUrl = [rs stringForColumnIndex:idx++];
    application.installUrl = [rs stringForColumnIndex:idx++];
    application.key = [rs stringForColumnIndex:idx++];
    application.mobileType = [rs stringForColumnIndex:idx++];
    application.name = [rs stringForColumnIndex:idx++];
    application.networkId = [rs stringForColumnIndex:idx++];
    application.schemeUrl = [rs stringForColumnIndex:idx++];
    application.tenantId = [rs stringForColumnIndex:idx++];
    application.appVersion = [rs stringForColumnIndex:idx++];
    application.needAuth = [rs boolForColumnIndex:idx++];
    
    if(application.appId) {
        return application;
    }else {
        return nil;
    }
}

- (void)saveApplications:(NSArray *)applications database:(FMDatabase *)db
{
    if(!applications || applications.count == 0) return;
    
    NSString *sql = @"REPLACE INTO application(appId, desc, detailDesc, httpUrl, iconUrl, installUrl, key, mobileType, name, networkId, schemeUrl, tenantId, appVersion, needAuth) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    FMStatement *stmt = [db preparedStatementWithSQL:sql];
    
    for(KDApplication *application in applications) {
        int idx = 1;
        
        [stmt bindString:application.appId atIndex:idx++];
        [stmt bindString:application.desc atIndex:idx++];
        [stmt bindString:application.detailDesc atIndex:idx++];
        [stmt bindString:application.httpUrl atIndex:idx++];
        [stmt bindString:application.iconUrl atIndex:idx++];
        [stmt bindString:application.installUrl atIndex:idx++];
        [stmt bindString:application.key atIndex:idx++];
        [stmt bindString:application.mobileType atIndex:idx++];
        [stmt bindString:application.name atIndex:idx++];
        [stmt bindString:application.networkId atIndex:idx++];
        [stmt bindString:application.schemeUrl atIndex:idx++];
        [stmt bindString:application.tenantId atIndex:idx++];
        [stmt bindString:application.appVersion atIndex:idx++];
        [stmt bindBool:application.needAuth atIndex:idx++];
        
        if(![stmt step]) {
            DLog(@"can not save application with id = %@", application.appId);
        }
        
        [stmt reset];
    }
    
    [stmt close];
}

- (NSArray *)queryAllApplicationsFromDB:(FMDatabase *)db
{
    NSString *sql = @"SELECT appId, desc, detailDesc, httpUrl, iconUrl, installUrl, key, mobileType, name, networkId, schemeUrl, tenantId, appVersion, needAuth FROM application";
    
    FMResultSet *rs = [db executeQuery:sql];
    NSMutableArray *apps = [NSMutableArray array];
    
    while ([rs next]) {
        KDApplication *app = [self applicationWithResultSet:rs];
        
        if(app) {
            [apps addObject:app];
        }
    }
    
    [rs close];
    
    return apps;
}

@end
