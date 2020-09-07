//
//  TestPersitentDAO.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-11.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "TestPersitentDAO.h"
#import "KDManagerContext.h"
#import "KDDBManager.h"
#import "KDParserManager.h"
#import "KDWeiboDAOManager.h"

#import "KDStatus.h"
#import "KDMentionMeStatus.h"
#import "KDCommentMeStatus.h"
#import "KDCommentStatus.h"
#import "KDGroupStatus.h"
#import "KDGroup.h"

#import "KDDMThread.h"
#import "KDDMMessage.h"

#import "KDABPerson.h"
#import "KDVote.h"
#import "KDVoteOption.h"

#import "KDUtility.h"
#import "KDDatabaseHelper.h"

#define KD_FAKE_CURRENT_USER_ID          @"123456"
#define KD_FAKE_CURRENT_COMMUNITY_ID     @"abcdef"

@interface TestPersitentDAO ()

@property(nonatomic, retain) NSString *sourcePath;
@property(nonatomic, retain) NSString *dbPath;

@end

@implementation TestPersitentDAO

@synthesize sourcePath=sourcePath_;
@synthesize dbPath=dbPath_;

- (void)setUp {
    [super setUp];
    
    // bind to current user id
    [[[KDManagerContext globalManagerContext] userManager] setCurrentUserId:KD_FAKE_CURRENT_USER_ID];
    
    // source path
    NSBundle *bundle = [NSBundle bundleForClass:[TestPersitentDAO class]];
    self.sourcePath = [bundle resourcePath];
    
    // database path
    NSString *path = [[KDUtility defaultUtility] searchDirectory:KDUserDatabaseDirectory inDomainMask:KDTemporaryDomainMask needCreate:NO];
    self.dbPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", KD_FAKE_CURRENT_COMMUNITY_ID]];
    
    STAssertNotNil(sourcePath_, @"The source path can not be nil");
    STAssertNotNil(dbPath_, @"The database path can not be nil");
    
    // remove database if need
    [self _removeDatabaseIfNeed];
    
    // setup database
    if (![self _createDatabase]) {
        STFail(@"Can not setup database.");
    }
    
    BOOL connected = [[KDDBManager sharedDBManager] tryConnectToCommunity:KD_FAKE_CURRENT_COMMUNITY_ID];
    if (!connected) {
        STFail(@"it's must connected to database before any testing");
    }
}

- (void)_removeDatabaseIfNeed {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dbPath_]) {
        NSError *error = nil;
        [fm removeItemAtPath:dbPath_ error:&error];
        
        STAssertNil(error, [NSString stringWithFormat:@"remove database did fail with error=%@", error]);
    }
}

- (NSData *)_databaseSchemaData {
    NSString *path = [sourcePath_ stringByAppendingPathComponent:@"create.sql"];
    return [NSData dataWithContentsOfFile:path];
}

- (BOOL)_createDatabase {
    BOOL succeed = NO;
    
    FMDatabase *db = [[FMDatabase alloc] initWithPath:dbPath_];
    if ([db open]) {
        // setup database schema
        NSData *data = [self _databaseSchemaData];
        NSString *schemaInString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        const char *sql = [schemaInString UTF8String];
        [schemaInString release];
        
        char *message = NULL;
        int status = sqlite3_exec([db sqliteHandle], sql, NULL, NULL, &message);
        if(SQLITE_OK == status){
            // set database schema version
            [db executeUpdate:@"PRAGMA user_version=1;"];
            
            succeed = YES;
            
        }else {
            if(message != NULL){
                NSLog(@"Can not setup database schema with message:%s", message);
                
                sqlite3_free(message);
                message = NULL;
            }
        }
    }
    
    [db close];
    [db release];
    
    return succeed;
}

- (id)parseJSONContentWithSourceName:(NSString *)sourceName {
    id results = nil;
    
    NSString *path = [sourcePath_ stringByAppendingPathComponent:sourceName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSError *error = nil;
        results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (error != nil) {
            NSLog(@"can not parse the json with path=%@ error=%@", path, error);
        }
    }
    
    return results;
}

- (FMDatabaseQueue *)_fmdbQueue {
    return [KDDBManager sharedDBManager].fmdbQueue;
}


- (void)testActions {
    [self _saveStatuses];
    
    [self _saveCommentMeStatuses];
    
    [self _saveMentionMeStatuses];
    
    [self _saveGroupStatuses];
    
    [self _saveDMThreads];
    
    [self _saveDMMessages];
    
    [self _saveABPersons];
    
    [self _saveGroups];
    
    [self _saveVotes];
}

- (void)_saveStatuses {
    id<KDStatusDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
    
    [[self _fmdbQueue] inDatabase:^(FMDatabase *fmdb){
        KDStatus *s = [[KDStatus alloc] init];
        s.statusId = @"123456";
        s.type = KDTLStatusTypePublic;
        s.text = @"abc-cba";
        
        [dao saveStatus:s database:fmdb];
        
        NSArray *statuses = [dao queryStatusesWithTLType:KDTLStatusTypePublic limit:50 database:fmdb];
        STAssertTrue([statuses count] == 1, @"There is exist 1 status");
        
        KDStatus *temp = statuses[0];
        STAssertTrue([s.statusId isEqualToString:temp.statusId], @"the status id must be same");
        
        BOOL flag = [dao removeStatusWithId:s.statusId database:fmdb];
        STAssertTrue(flag, @"remove specific status with id must be true");
        
        flag = [dao removeAllStatusesInDatabase:fmdb];
        STAssertTrue(flag, @"remove all statuses must be true");
        
        [s release];
    }];
    
    
    ////////////////////////////////////////////////////////////////////////
    
    [[self _fmdbQueue] inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        NSArray *items = [self parseJSONContentWithSourceName:@"statuses_public_timeline.json"];
        if (items != nil) {
            KDStatusParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDStatusParser class]];
            NSArray *statuses = [parser parseAsStatuses:items type:KDTLStatusTypePublic];
            
            STAssertTrue([statuses count] == 50, @"There are 50 statuses in json file");
            
            [dao saveStatuses:statuses database:fmdb rollback:rollback];
            
            NSArray *items = [dao queryStatusesWithTLType:KDTLStatusTypePublic limit:10 database:fmdb];
            STAssertTrue([items count] == 10, @"There are exist 10 statuses");
            
            items = [dao queryStatusesWithTLType:KDTLStatusTypeFriends limit:10 database:fmdb];
            STAssertTrue([items count] == 0, @"There is no exist statuses");
            
        } else {
            STAssertTrue(NO, @"The items can not be nil.");
        }
    }];
    
    
    ////////////////////////////////////////////////////////////////////////
    
    [[self _fmdbQueue] inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        [dao saveStatus:nil database:fmdb];
        
        [dao saveStatuses:nil database:fmdb rollback:rollback];
    }];
}

- (void)_saveCommentMeStatuses {
    [[self _fmdbQueue] inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        KDCommentMeStatus *s = [[KDCommentMeStatus alloc] init];
        s.statusId = @"123456";
        s.type = KDTLStatusTypeCommentMe;
        s.text = @"abc-cba";
        s.replyStatusId = @"123";
        s.replyStatusText = @"s-text-1";
        s.replyUserId = @"u-123";
        
        id<KDStatusDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        [dao saveCommentMeStatus:s database:fmdb];
        
        NSArray *statuses = [dao queryCommentMeStatusesWithLimit:10 database:fmdb];
        STAssertTrue([statuses count] == 1, @"There is exist 1 status");
        
        KDCommentMeStatus *temp = statuses[0];
        STAssertTrue([s.statusId isEqualToString:temp.statusId], @"the status id must be same");
        STAssertTrue([s.text isEqualToString:temp.text], @"the text id must be same");
        STAssertTrue([s.replyStatusId isEqualToString:temp.replyStatusId], @"the reply status id must be same");
        STAssertTrue([s.replyStatusText isEqualToString:temp.replyStatusText], @"the reply status text must be same");
        STAssertTrue([s.replyUserId isEqualToString:temp.replyUserId], @"the reply user id must be same");
        
        BOOL flag = [dao removeCommentMeStatusWithId:s.statusId database:fmdb];
        STAssertTrue(flag, @"remove specific comment me status with id must be true");
        
        flag = [dao removeAllCommentMeStatusesInDatabase:fmdb];
        STAssertTrue(flag, @"remove all comment me statuses must be true");
        
        [s release];
        
        
        ////////////////////////////////////////////////////////////////////////
        
        NSArray *items = [self parseJSONContentWithSourceName:@"comments_to_me.json"];
        if (items != nil) {
            KDStatusParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDStatusParser class]];
            NSArray *statuses = [parser parseAsCommentMeStatuses:items];
            
            STAssertTrue([statuses count] == 11, @"There are 11 statuses in json file");
            
            [dao saveCommentMeStatuses:statuses database:fmdb rollback:rollback];
            
            NSArray *items = [dao queryCommentMeStatusesWithLimit:20 database:fmdb];
            STAssertTrue([items count] == 11, @"There are exist 11 statuses");
            
        } else {
            STAssertTrue(NO, @"The items can not be nil.");
        }
        
        
        ////////////////////////////////////////////////////////////////////////
        
        [dao saveCommentMeStatus:nil database:fmdb];
        
        [dao saveCommentMeStatuses:nil database:fmdb rollback:rollback];
    }];
    
}

- (void)_saveMentionMeStatuses {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [[self _fmdbQueue] inTransaction:^(FMDatabase *fmdb, BOOL *rollback){
            KDMentionMeStatus *s = [[KDMentionMeStatus alloc] init];
            s.statusId = @"123456";
            s.type = KDTLStatusTypeCommentMe;
            s.text = @"abc-cba";
            
            id<KDStatusDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
            [dao saveMentionMeStatus:s database:fmdb];
            
            NSArray *statuses = [dao queryMentionMeStatusesWithLimit:10 database:fmdb];
            STAssertTrue([statuses count] == 1, @"There is exist 1 status");
            
            KDMentionMeStatus *temp = statuses[0];
            STAssertTrue([s.statusId isEqualToString:temp.statusId], @"the status id must be same");
            STAssertTrue([s.text isEqualToString:temp.text], @"the text id must be same");
            
            BOOL flag = [dao removeMentionMeStatusWithId:s.statusId database:fmdb];
            STAssertTrue(flag, @"remove specific mention me status with id must be true");
            
            flag = [dao removeAllMentionMeStatusesInDatabase:fmdb];
            STAssertTrue(flag, @"remove all mention me statuses must be true");
            
            [s release];
            
            
            ////////////////////////////////////////////////////////////////////////
            
            NSArray *items = [self parseJSONContentWithSourceName:@"mentions_to_me.json"];
            if (items != nil) {
                KDStatusParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDStatusParser class]];
                NSArray *statuses = [parser parseAsMentionMeStatuses:items];
                
                STAssertTrue([statuses count] == 20, @"There are 20 statuses in json file");
                
                [dao saveMentionMeStatuses:statuses database:fmdb rollback:rollback];
                
                NSArray *items = [dao queryMentionMeStatusesWithLimit:20 database:fmdb];
                STAssertTrue([items count] == 20, @"There are exist 20 statuses");
                
            } else {
                STAssertTrue(NO, @"The items can not be nil.");
            }
            
            
            ////////////////////////////////////////////////////////////////////////
            
            [dao saveMentionMeStatus:nil database:fmdb];
            
            [dao saveMentionMeStatuses:nil database:fmdb rollback:rollback];
        }];
    });
}

- (void)_saveGroupStatuses {
    [[self _fmdbQueue] inDatabase:^(FMDatabase *fmdb){
        KDGroupStatus *s = [[KDGroupStatus alloc] init];
        s.statusId = @"123456";
        s.type = KDTLStatusTypeGroupStatus;
        s.text = @"abc-cba";
        s.groupId = @"g-001";
        s.groupName = @"g-name";
        
        id<KDStatusDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] statusDAO];
        [dao saveGroupStatus:s database:fmdb];
        
        NSArray *statuses = [dao queryGroupStatusesWithGroupId:@"g-001" limit:10 database:fmdb];
        STAssertTrue([statuses count] == 1, @"There is exist 1 status");
        
        KDStatus *temp = statuses[0];
        STAssertTrue([s.statusId isEqualToString:temp.statusId], @"the status id must be same");
        
        BOOL flag = [dao removeGroupStatusWithId:s.statusId database:fmdb];
        STAssertTrue(flag, @"remove specific status with id must be true");
        
        flag = [dao removeAllGroupStatusesInDatabase:fmdb];
        STAssertTrue(flag, @"remove all statuses must be true");
        
        [s release];
        
        BOOL rollback = NO; // ignore this value now
        
        ////////////////////////////////////////////////////////////////////////
        
        NSArray *items = [self parseJSONContentWithSourceName:@"statuses_public_timeline.json"];
        if (items != nil) {
            KDStatusParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDStatusParser class]];
            NSArray *statuses = [parser parseAsGroupStatuses:items];
            
            int idx = 0;
            for (; idx < 10; idx++) {
                KDGroupStatus *gs = statuses[idx];
                gs.groupId = @"g-001";
                gs.groupName = @"g-name";
            }
            
            STAssertTrue([statuses count] == 50, @"There are 50 statuses in json file");
            
            [dao saveGroupStatuses:statuses database:fmdb rollback:&rollback];
            
            NSArray *items = [dao queryGroupStatusesWithGroupId:@"not-exist-gid" limit:10 database:fmdb];
            STAssertTrue([items count] == 0, @"There are not exist statuses");
            
            items = [dao queryGroupStatusesWithGroupId:@"g-001" limit:20 database:fmdb];
            STAssertTrue([items count] == 10, @"There are exists 10 statuses");
            
        } else {
            STAssertTrue(NO, @"The items can not be nil.");
        }
        
        ////////////////////////////////////////////////////////////////////////
        
        [dao saveGroupStatus:nil database:fmdb];
        
        [dao saveGroupStatuses:nil database:fmdb rollback:&rollback];
    }];
}

- (void)_saveDMThreads {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(){
        [[self _fmdbQueue] inTransaction:^(FMDatabase *fmdb, BOOL *rollback){
            KDDMThread *t1 = [[KDDMThread alloc] init];
            t1.threadId = @"t-001";
            t1.latestDMId = @"tl-001";
            t1.latestDMSenderId = @"u-001";
            t1.latestDMText = @"dm-message-haha";
            
            id<KDDMThreadDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] dmThreadDAO];
            [dao saveDMThreads:@[t1] database:fmdb rollback:rollback];
            
            NSArray *threads = [dao queryDMThreadsWithLimit:10 database:fmdb];
            STAssertTrue([threads count] == 1, @"There is exist 1 dm thread");
            
            KDDMThread *t2 = [dao queryDMThreadWithId:@"t-001" database:fmdb];
            
            KDDMThread *temp = threads[0];
            STAssertTrue([t1.threadId isEqualToString:temp.threadId], @"the thread id must be same");
            STAssertTrue([t1.threadId isEqualToString:t2.threadId], @"the thread id must be same");
            
            STAssertTrue([t1.latestDMId isEqualToString:t2.latestDMId], @"the latest message id must be same");
            STAssertTrue([t1.latestDMSenderId isEqualToString:t2.latestDMSenderId], @"the sender id must be same");
            STAssertTrue([t1.latestDMText isEqualToString:t2.latestDMText], @"the message text must be same");
            
            BOOL flag = [dao removeDMThreadWithId:@"t-001" database:fmdb];
            STAssertTrue(flag, @"remove specific dm thread with id must be true");
            
            flag = [dao removeAllDMThreadsInDatabase:fmdb];
            STAssertTrue(flag, @"remove all threads must be true");
            
            [t1 release];
            
            
            ////////////////////////////////////////////////////////////////////////
            
            NSDictionary *body = [self parseJSONContentWithSourceName:@"dm_threads.json"];
            if (body != nil) {
                NSArray *items = [body objectNotNSNullForKey:@"threads"];
                
                KDDMThreadParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDDMThreadParser class]];
                threads = [parser parse:items];
                
                STAssertTrue([threads count] == 20, @"There are 20 dm threads in json file");
                
                [dao saveDMThreads:threads database:fmdb rollback:rollback];
                
                
                threads = [dao queryDMThreadsWithLimit:10 database:fmdb];
                STAssertTrue([threads count] == 10, @"There are exists 10 dm threads");
                
                temp = [dao queryDMThreadWithId:@"fake-t-001" database:fmdb];
                STAssertNil(temp, @"Not exist dm thread");
                
                temp = [dao queryDMThreadWithId:@"50b6b5dde4b05f7d1b8acb8b" database:fmdb];
                STAssertNotNil(temp, @"dm thread can not be nil");
            }
            
            
            ////////////////////////////////////////////////////////////////////////
            
            [dao saveDMThreads:nil database:fmdb rollback:rollback];
        }];
    });
}

- (void)_saveDMMessages {
    [[self _fmdbQueue] inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        KDDMMessage *m = [[KDDMMessage alloc] init];
        m.messageId = @"dm-m-001";
        m.message = @"can u see it";
        
        id<KDDMMessageDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] dmMessageDAO];
        [dao saveDMMessages:@[m] threadId:@"dm-m-t-001" database:fmdb rollback:rollback];
        
        NSArray *messages = [dao queryDMMessagesWithThreadId:@"dm-m-t-001" limit:10 database:fmdb];
        STAssertTrue([messages count] == 1, @"There is exist 1 dm message");
        
        NSString *mid = [dao queryLatestDMMessageIdWithThreadId:@"dm-m-t-001" database:fmdb];
        STAssertTrue([mid isEqualToString:m.messageId], @"mid can not be nil");
        
        KDDMMessage *temp = messages[0];
        STAssertTrue([m.messageId isEqualToString:temp.messageId], @"the message id must be same");
        STAssertTrue([m.message isEqualToString:temp.message], @"the message must be same");
        
        BOOL flag = [dao removeDMMessageWithId:m.messageId database:fmdb];
        STAssertTrue(flag, @"remove specific dm message with id must be true");
        
        flag = [dao removeAllDMMessagesInDatabase:fmdb];
        STAssertTrue(flag, @"remove all message must be true");
        
        [m release];
        
        
        ////////////////////////////////////////////////////////////////////////
        
        NSArray *items = [self parseJSONContentWithSourceName:@"dm_messages.json"];
        if (items != nil) {
            KDDMMessageParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDDMMessageParser class]];
            NSArray *messages = [parser parseAsDMMessageList:items];
            
            STAssertTrue([messages count] == 4, @"There are 4 dm thread messages in json file");
            
            [dao saveDMMessages:messages threadId:@"50052406e4b0c3813fdf84de" database:fmdb rollback:rollback];
            
            messages = [dao queryDMMessagesWithThreadId:@"50052406e4b0c3813fdf84de" limit:10 database:fmdb];
            
            STAssertTrue([messages count] == 4, @"There are 4 dm thread messages");
            
            temp = messages[0];
            
            STAssertNotNil(temp.messageId, @"The message id can not be nil");
        }
        
        [dao saveDMMessages:nil threadId:nil database:fmdb rollback:rollback];
    }];
}

- (void)_saveABPersons {
    [[self _fmdbQueue] inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        KDABPerson *p = [[KDABPerson alloc] init];
        p.pId = @"p-001";
        p.name = @"p-u-name";
        p.networkId = @"p-nid-001";
        p.userId = @"p-u-001";
        p.type = KDABPersonTypeRecently;
        
        id<KDABPersonDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] ABPersonDAO];
        [dao saveABPersons:@[p] type:KDABPersonTypeRecently clear:YES database:fmdb rollback:rollback];
        
        [dao saveABPersons:@[p] type:KDABPersonTypeAll clear:YES database:fmdb rollback:rollback];
        
        NSArray *persons = [dao queryABPersonsByType:KDABPersonTypeRecently limit:10 database:fmdb];
        STAssertTrue([persons count] == 1, @"There is exist 1 person");
        
        NSArray *emptyPersons = [dao queryABPersonsByType:KDABPersonTypeFavorited limit:10 database:fmdb];
        STAssertTrue([emptyPersons count] == 0, @"There is no person");
        
        KDABPerson *temp = persons[0];
        STAssertTrue([p.pId isEqualToString:temp.pId], @"the person id must be same");
        STAssertTrue([p.name isEqualToString:temp.name], @"the name must be same");
        STAssertTrue([p.networkId isEqualToString:temp.networkId], @"the network id must be same");
        STAssertTrue([p.userId isEqualToString:temp.userId], @"the user id must be same");
        
        BOOL flag = [dao updateABPersonFavoritedState:p database:fmdb];
        STAssertTrue(flag, @"update specificed person must be true");
        
        flag = [dao removeABPerson:temp type:temp.type database:fmdb];
        STAssertTrue(flag, @"remove specificed person must be true");
        
        flag = [dao removeAllABPersonsWithType:KDABPersonTypeFavorited database:fmdb];
        STAssertTrue(flag, @"remove all persons with type must be true");
        
        [p release];
        
        
        ////////////////////////////////////////////////////////////////////////
        
        NSDictionary *body = [self parseJSONContentWithSourceName:@"ab_person_member_list_simple.json"];
        if (body != nil) {
            NSArray *items = [body objectNotNSNullForKey:@"list"];
            
            KDABPersonParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDABPersonParser class]];
            persons = [parser parse:items type:KDABPersonTypeRecently];
            
            STAssertTrue([persons count] == 20, @"There are 20 ab persons in json file");
            
            [dao saveABPersons:persons type:KDABPersonTypeAll clear:YES database:fmdb rollback:rollback];
            
            persons = [dao queryABPersonsByType:KDABPersonTypeAll limit:10 database:fmdb];
            STAssertTrue([persons count] == 10, @"There are 10 ab persons");
            
            KDABPerson *p = persons[0];
            
            STAssertEqualObjects(p.pId, @"509372b724ac46fb9503a3d7", @"The person id must be same");
            STAssertEqualObjects(p.userId, @"4e1fcad4cce73e504ebfc40d", @"The user id must be same");
            STAssertEqualObjects(p.networkId, @"383cee68-cea3-4818-87ae-24fb46e081b1", @"The network must be same");
            
            STAssertEqualObjects(p.jobTitle, @"Chief Admin", @"The job title must be same");
            STAssertEqualObjects(p.department, @"Admin office", @"The department must be same");
            
            STAssertTrue([p.emails count] == 2, @"There are 2 emails");
            
            STAssertNotNil(p.profileImageURL, @"The profile url can not be nil");
        }
        
        [dao saveABPersons:nil type:KDABPersonTypeFavorited clear:YES database:fmdb rollback:rollback];
    }];
}

- (void)_saveGroups {
    [[self _fmdbQueue] inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        KDGroup *g = [[KDGroup alloc] init];
        g.groupId = @"g-001";
        g.name = @"Go language";
        g.profileImageURL = @"http://go-langauge.com/images/icon.png";
        g.bulletin = @"start learn go language";
        g.summary = @"join us plz!";
        g.type = KDGroupTypePublic;
        
        id<KDGroupDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] groupDAO];
        [dao saveGroups:@[g] database:fmdb rollback:rollback];
        
        NSArray *items = [dao queryGroupsWithLimit:10 database:fmdb];
        STAssertTrue([items count] == 1, @"There is  only 1 group");
        
        KDGroup *temp = [dao queryGroupWithId:@"g-fake-001" database:fmdb];
        STAssertNil(temp, @"not exist group with specificed group id");
        
        temp = [dao queryGroupWithId:@"g-001" database:fmdb];
        STAssertNotNil(temp, @"The group can not be nil");
        
        STAssertTrue([g.groupId isEqualToString:temp.groupId], @"the group id must be same");
        STAssertTrue([g.name isEqualToString:temp.name], @"the group name must be same");
        STAssertTrue([g.profileImageURL isEqualToString:temp.profileImageURL], @"the group profile image url must be same");
        STAssertTrue([g.bulletin isEqualToString:temp.bulletin], @"the group bulletin must be same");
        STAssertTrue([g.summary isEqualToString:temp.summary], @"the group summary must be same");
        
        STAssertTrue(![temp isPrivate], @"this is public group");
        
        BOOL flag = [dao removeAllGroupsInDatabase:fmdb];
        STAssertTrue(flag, @"remove all groups can not be false");
        
        [g release];
        
        
        ////////////////////////////////////////////////////////////////////////
        
        NSArray *body = [self parseJSONContentWithSourceName:@"groups_joined.json"];
        if (body != nil) {
            KDGroupParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDGroupParser class]];
            NSArray *groups = [parser parseAsGroupList:body];
            
            STAssertTrue([groups count] == 15, @"There are 15 groups");
            
            [dao saveGroups:groups database:fmdb rollback:rollback];
            
            items = [dao queryGroupsWithLimit:20 database:fmdb];
            STAssertTrue([items count] == 15, @"There are 15 groups");
            
            temp = [dao queryGroupWithId:@"4f137222cce7da5f0634ec33" database:fmdb];
            STAssertNotNil(temp, @"The group can not be nil");
            STAssertNotNil(temp.groupId, @"The id can not be nil");
            STAssertNotNil(temp.name, @"The name can not be nil");
            STAssertNotNil(temp.profileImageURL, @"The profile image url can not be nil");
            STAssertNotNil(temp.summary, @"The summary can not be nil");
            STAssertNotNil(temp.bulletin, @"The bulletin can not be nil");
            
            g = items[0];
            STAssertTrue([g.groupId isEqualToString:temp.groupId], @"the group id must be same");
            STAssertTrue([g.name isEqualToString:temp.name], @"the group name must be same");
            STAssertTrue([g.profileImageURL isEqualToString:temp.profileImageURL], @"the group profile image url must be same");
            STAssertTrue([g.bulletin isEqualToString:temp.bulletin], @"the group bulletin must be same");
            STAssertTrue([g.summary isEqualToString:temp.summary], @"the group summary must be same");
        }
        
        [dao saveGroups:nil database:fmdb rollback:rollback];
    }];
}

- (void)_saveVotes {
    [[self _fmdbQueue] inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
        KDVote *v = [[KDVote alloc] init];
        v.voteId = @"v-001";
        v.name = @"v-test";
        v.participantCount = 10;
        v.maxVoteItemCount = 2;
        v.selectedOptionIDs = @[@"opt-001", @"opt-002"];
        v.state = KDVoteStateActive;
        
        KDVoteOption *opt1 = [[[KDVoteOption alloc] init] autorelease];
        opt1.optionId = @"opt-001";
        opt1.name = @"opt001";
        
        KDVoteOption *opt2 = [[[KDVoteOption alloc] init] autorelease];
        opt1.optionId = @"opt-002";
        opt1.name = @"opt002";
        
        KDVoteOption *opt3 = [[[KDVoteOption alloc] init] autorelease];
        opt1.optionId = @"opt-003";
        opt1.name = @"opt003";
        
        v.voteOptions = @[opt1, opt2, opt3];
        
        id<KDVoteDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] voteDAO];
        [dao saveVote:v database:fmdb];
        
        KDVote *temp = [dao queryVoteWithId:@"v-fake-001" database:fmdb];
        STAssertNil(temp, @"not exist vote with specificed vote id");
        
        temp = [dao queryVoteWithId:@"v-001" database:fmdb];
        STAssertNotNil(temp, @"The vote can not be nil");
        
        STAssertTrue([v.voteId isEqualToString:temp.voteId], @"the vote id must be same");
        STAssertTrue([v.name isEqualToString:temp.name], @"the name must be same");
        STAssertTrue(v.participantCount == temp.participantCount, @"the participant count must be same");
        STAssertTrue(v.maxVoteItemCount == temp.maxVoteItemCount, @"the max vote item count must be same");
        
        STAssertTrue([v.selectedOptionIDs count] == [temp.selectedOptionIDs count], @"the selected options count must be same");
        
        BOOL flag = [dao removeVoteWithId:@"v-fake-001" database:fmdb];
        STAssertTrue(flag, @"not exist vote");
        
        flag = [dao removeVoteWithId:@"v-001" database:fmdb];
        STAssertTrue(flag, @"remove specificed vote with id should be true");
        
        flag = [dao removeAllVotesInDatabase:fmdb];
        STAssertTrue(flag, @"remove all vote can not be false");
        
        [v release];
        
        
        //////////////////////////////////////////////////////////////////////
        
        NSArray *body = [self parseJSONContentWithSourceName:@"vote_popular_all.json"];
        if (body != nil) {
            STAssertTrue([body count] == 5, @"There are 5 votes");
            
            KDVoteParser *parser = [[KDParserManager globalParserManager] parserWithClass:[KDVoteParser class]];
            
            NSMutableArray *votes = [NSMutableArray arrayWithCapacity:[body count]];
            for (NSDictionary *item in body) {
                v = [parser parse:item];
                STAssertNotNil(v, @"The vote can not be nil");
                
                [votes addObject:v];
            }
            
            [dao saveVotes:votes database:fmdb rollback:rollback];
            
            temp = [dao queryVoteWithId:@"4f1686e124ac5c307165525f" database:fmdb];
            STAssertNotNil(temp, @"The vote can not be nil");
            
            STAssertTrue([temp.voteId isEqualToString:@"4f1686e124ac5c307165525f"], @"the vote id must be same");
            
            STAssertTrue((temp.createdTime > 1326876385.0 - 0.001 && temp.createdTime < 1326876385.0 + 0.999), @"time must in range");
            STAssertTrue(temp.isEnded, @"this vote has been closed");
            
            STAssertTrue(temp.maxVoteItemCount == 1, @"this is a single vote");
            STAssertTrue(temp.participantCount == 1928, @"There are 1928 participants");
            
            STAssertTrue(!temp.votedVote, @"not been voted this vote");
            
            NSArray *options = temp.voteOptions;
            STAssertTrue([options count] == 13, @"There are 13 vote options");
            
            KDVoteOption *option = options[0];
            STAssertTrue([option.optionId isEqualToString:@"4f1686e124ac5c3071655265"], @"the option id must be same");
            STAssertTrue(option.count == 0, @"the option count must be 0");
            
        } else {
            STFail(@"Can not load the votes by json file");
        }
    }];
}

- (void)disable_testFMDatabaseQueue {
    __block NSInteger mask = 0x0000;
    
    // action A
    [self _executeConcurrencyActionA:^(BOOL finished, NSTimeInterval duration){
        mask |= 0x000f;
        
        NSLog(@"The time duration of action A=%0.3f", duration);
        STAssertTrue(finished, @"action A must executed correctly");
    }];
    
    // action B
    [self _executeConcurrencyActionB:^(BOOL finished, NSTimeInterval duration){
        mask |= 0x00f0;
        
        NSLog(@"The time duration of action B=%0.3f", duration);
        STAssertTrue(finished, @"action B must executed correctly");
    }];
    
    // action C
    [self _executeConcurrencyActionC:^(BOOL finished, NSTimeInterval duration){
        mask |= 0x0f00;
        
        NSLog(@"The time duration of action C=%0.3f", duration);
        STAssertTrue(finished, @"action C must executed correctly");
    }];
    
    // action D
    [self _executeConcurrencyActionD:^(BOOL finished, NSTimeInterval duration){
        mask |= 0xf000;
        
        NSLog(@"The time duration of action D=%0.3f", duration);
        STAssertTrue(finished, @"action D must executed correctly");
    }];
    
    while (YES) {
        if (mask == 0xffff) {
            break;
        }
        
        [NSThread sleepForTimeInterval:0.2]; // sleep 200 milliseconds
    }
}

- (void)_executeConcurrencyActionA:(void (^)(BOOL finshed, NSTimeInterval duration))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
        
        [[self _fmdbQueue] inDatabase:^(FMDatabase *fmdb){
            id<KDUserDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
            
            KDUInt64 uid = (NSUInteger)time(NULL) * 1000;
            NSString *name = nil;
            KDUser *user = nil;
            
            int idx = 0;
            for (; idx < 5000; idx++) {
                name = [NSString stringWithFormat:@"uid-%lld-%d", uid--, idx + 1];
                
                user = [[KDUser alloc] init];
                user.userId = name;
                user.username = name;
                user.screenName = name;
                
                [dao saveUserSimple:user database:fmdb];
                
                [user release];
                
                if (idx % 100 == 0) {
                    [NSThread sleepForTimeInterval:0.1]; // sleep 100 milliseconds
                }
            }
        }];
        
        NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
        
        if (block != nil) {
            block(YES, end - start);
        }
    });
}

- (void)_executeConcurrencyActionB:(void (^)(BOOL finshed, NSTimeInterval duration))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
        
        [[self _fmdbQueue] inDatabase:^(FMDatabase *fmdb){
            id<KDUserDAO> dao = [[KDWeiboDAOManager globalWeiboDAOManager] userDAO];
        
            KDUInt64 uid = (NSUInteger)time(NULL) * 1000;
            NSString *name = nil;
            KDUser *user = nil;
            
            int idx = 0;
            for (; idx < 1000; idx++) {
                name = [NSString stringWithFormat:@"uid-%lld-%d", uid--, idx + 1];
                
                user = [[KDUser alloc] init];
                user.userId = name;
                user.username = name;
                user.screenName = name;
                
                [dao saveUserSimple:user database:fmdb];
                
                [user release];
                
                if (idx % 100 == 0) {
                    [NSThread sleepForTimeInterval:0.300]; // sleep 300 milliseconds
                }
            }
        }];
        
        NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
        
        if (block != nil) {
            block(YES, end - start);
        }
    });
}

- (void)_executeConcurrencyActionC:(void (^)(BOOL finshed, NSTimeInterval duration))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        FMDatabaseQueue *queue = [[KDDBManager sharedDBManager] fmdbQueue];
        [queue inDatabase:^(FMDatabase *fmdb){
            NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
            NSString *sql = @"SELECT user_id, name, screen_name, email FROM users limit 10;";
            
            int idx = 0;
            for (; idx < 2000; idx++) {
                FMResultSet *rs = [fmdb executeQuery:sql];
                
                int count = 0;
                while ([rs next]) {
                    count++;
                }
                [rs close];
                if (idx % 60 == 0) {
                    [NSThread sleepForTimeInterval:0.2]; // sleep 200 milliseconds
                }
            }
            
            NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
            
            if (block != nil) {
                block(YES, end - start);
            }
        }];
    });
}

- (void)_executeConcurrencyActionD:(void (^)(BOOL finshed, NSTimeInterval duration))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        FMDatabaseQueue *queue = [[KDDBManager sharedDBManager] fmdbQueue];
        [queue inDeferredTransaction:^(FMDatabase *fmdb, BOOL *rollback){
            NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
            NSString *sql = @"DELETE FROM users WHERE name = ?;";
            
            int idx = 0;
            for (; idx < 100; idx++) {
                BOOL flag = [fmdb executeUpdate:sql, @"fake-user-001"];
                if (!flag) {
                    NSLog(@"Can not delete the user");
                }
                
                if (idx % 5 == 0) {
                    [NSThread sleepForTimeInterval:0.8]; // sleep 800 milliseconds
                }
            }
            
            NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
            
            if (block != nil) {
                block(YES, end - start);
            }
        }];
    });
}

- (void)tearDown {
    //KD_RELEASE_SAFELY(sourcePath_);
    //KD_RELEASE_SAFELY(dbPath_);
    
    [super tearDown];
}

@end
