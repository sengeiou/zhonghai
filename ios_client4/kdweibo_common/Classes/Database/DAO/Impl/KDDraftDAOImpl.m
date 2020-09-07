//
//  KDDraftDAOImpl.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDDraftDAOImpl.h"
#import "KDDraft.h"

@implementation KDDraftDAOImpl

- (void)saveDraft:(KDDraft *)draft database:(FMDatabase *)fmdb {
    if (draft == nil) return;
    
    NSString *sql = @"REPLACE INTO drafts(id, type, author_id, created_at, content, status_content,"
                     " comment_on_status_id, comment_on_comment_id, reply_name, forwarded_id, group_id, group_name, image_data, mask,latitude, longitude, address, video_path, sending, uploadedImages,do_extra_comment_or_forward)"
                     " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?);";
    
    FMStatement *stmt = [fmdb preparedStatementWithSQL:sql];
    
    int idx = 1;
    [stmt bindInt:(int)draft.draftId atIndex:idx++];
    [stmt bindInt:(int)draft.type atIndex:idx++];
    [stmt bindString:draft.authorId atIndex:idx++];
    [stmt bindDate:draft.creationDate atIndex:idx++];
    
    [stmt bindString:draft.content atIndex:idx++];
    [stmt bindString:draft.originalStatusContent atIndex:idx++];
    [stmt bindString:draft.commentForStatusId atIndex:idx++];
    [stmt bindString:draft.commentForCommentId atIndex:idx++];
    [stmt bindString:draft.replyScreenName atIndex:idx++];
    [stmt bindString:draft.forwardedStatusId atIndex:idx++];
    
    [stmt bindString:draft.groupId atIndex:idx++];
    [stmt bindString:draft.groupName atIndex:idx++];
    
    NSData *data = ([draft.assetURLs count] > 0) ? [NSKeyedArchiver archivedDataWithRootObject:draft.assetURLs] : nil;
    [stmt bindData:data atIndex:idx++];
    
    [stmt bindInt:[draft realMask] atIndex:idx++];
    [stmt bindFloat:draft.coordinate.latitude atIndex:idx++];
    [stmt bindFloat:draft.coordinate.longitude atIndex:idx++];
    [stmt bindString:draft.address atIndex:idx++];
    [stmt bindString:draft.videoPath atIndex:idx++];
    [stmt bindInt:draft.isSending atIndex:idx++];
    [stmt bindBool:draft.doExtraCommentOrForward atIndex:idx++];

    NSString *uploadImages = [draft.uploadedImages componentsJoinedByString:@","];
    [stmt bindString:uploadImages atIndex:idx++];
    // step
    if (![stmt step]) {
        DLog(@"Can not save draft with id=%d", draft.draftId);
    }
    
    // finalize prepared statement
    [stmt close];
}

- (BOOL)updateDraft:(KDDraft *)draft database:(FMDatabase *)fmdb {
    if (draft == nil) return NO;
    
    NSString *sql = @"UPDATE drafts SET content = ?, status_content = ?, image_data = ?, mask=?, video_path=?, sending=?, uploadedImages=? WHERE id=?;";
    
    NSData *data = ([draft.assetURLs count] > 0) ? [NSKeyedArchiver archivedDataWithRootObject:draft.assetURLs] : nil;
    NSInteger mask = [draft realMask];
    NSString *uploadImages = [draft.uploadedImages componentsJoinedByString:@","];
    
    BOOL flag = [fmdb executeUpdate:sql, draft.content, draft.originalStatusContent, data, @(mask), draft.videoPath, @(draft.sending), uploadImages, @(draft.draftId)];
    
    return flag;
}

- (BOOL)updateDraftWithId:(NSInteger)draftId SendingType:(DraftQueryType)type  database:(FMDatabase *)fmdb {
    NSString *sql = @"UPDATE drafts SET sending=? WHERE id=?;";
    
    BOOL flag = [fmdb executeUpdate:sql, @(type), @(draftId)];
    
    return flag;
}

- (NSUInteger)queryAllDraftsCountInDatabase:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT COUNT(id) FROM drafts;";
    
    return [super queryCount:sql database:fmdb];
}

- (NSUInteger)queryAllDraftsCountWithType:(DraftQueryType)type database:(FMDatabase *)fmdb {
    if (DraftAll == type) {
        return  [self queryAllDraftsCountInDatabase:fmdb];
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(id) FROM drafts WHERE sending = %d;", type == DraftInSending];
    
    return [super queryCount:sql database:fmdb];
}

- (NSArray *)queryAllDraftsWithAuthorId:(NSString *)authorId database:(FMDatabase *)fmdb
{
    return  [self queryAllDraftsWithAuthorId:authorId type:DraftAll database:fmdb];
}

- (NSArray *)queryAllDraftsWithAuthorId:(NSString *)authorId type:(DraftQueryType)type database:(FMDatabase *)fmdb
{
    if (authorId == nil) return nil;

    NSString *sql = nil;
    FMResultSet *rs = nil;
    if (DraftAll == type) {
        sql = @"SELECT id, type, created_at, content, status_content,"
        " comment_on_status_id, comment_on_comment_id,reply_name, forwarded_id,group_id, group_name, mask,latitude,longitude,address,video_path,sending,uploadedImages,do_extra_comment_or_forward"
        " FROM drafts WHERE author_id = ? ORDER BY created_at DESC;";
        rs = [fmdb executeQuery:sql, authorId];
    }else {
        sql = @"SELECT id, type, created_at, content, status_content,"
        " comment_on_status_id, comment_on_comment_id,reply_name,forwarded_id, group_id, group_name, mask,latitude,longitude,address,video_path,sending,uploadedImages,do_extra_comment_or_forward"
        " FROM drafts WHERE author_id = ? and sending = ? ORDER BY created_at DESC;";
        rs = [fmdb executeQuery:sql, authorId, @(type == DraftInSending)];
    }
    
    KDDraft *draft = nil;
    NSMutableArray *drafts = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        draft = [[KDDraft alloc] init];
        draft.authorId = authorId;
        draft.saved = YES;
        
        idx = 0;
        draft.draftId = [rs intForColumnIndex:idx++];
        draft.type = [rs intForColumnIndex:idx++];
        draft.creationDate = [rs dateForColumnIndex:idx++];
        
        draft.content = [rs stringForColumnIndex:idx++];
        draft.originalStatusContent = [rs stringForColumnIndex:idx++];
        draft.commentForStatusId = [rs stringForColumnIndex:idx++];
        draft.commentForCommentId = [rs stringForColumnIndex:idx++];
        draft.replyScreenName = [rs stringForColumnIndex:idx++];
        draft.forwardedStatusId = [rs stringForColumnIndex:idx++];
        
        draft.groupId = [rs stringForColumnIndex:idx++];
        draft.groupName = [rs stringForColumnIndex:idx++];
        
        draft.mask = [rs intForColumnIndex:idx++];
        //CLLocationCoordinate2D coordinate
        // draft.coordinate.latitude = [rs doubleForColumnIndex:idx++];
        float latitute = [rs doubleForColumnIndex:idx++];
        float longitute = [rs doubleForColumnIndex:idx++];
        CLLocationCoordinate2D coordinate = {latitute,longitute};
        draft.coordinate = coordinate;
        draft.address = [rs stringForColumnIndex:idx++];
        draft.videoPath = [rs stringForColumnIndex:idx++];
        draft.sending = [rs intForColumnIndex:idx++];
        draft.doExtraCommentOrForward = [rs boolForColumnIndex:idx++];

        NSString *uploadImages = [rs stringForColumnIndex:idx++];
        if (![uploadImages isEqualToString:@""]) {
            draft.uploadedImages =  [NSMutableArray arrayWithArray:[uploadImages componentsSeparatedByString:@","]];
        }

        [drafts addObject:draft];
    }
    
    [rs close];
    
    return drafts;
}

- (NSArray *)queryAllDraftsWithDraftId:(NSInteger)draftId  database:(FMDatabase *)fmdb {
    
    NSString *sql = nil;
    FMResultSet *rs = nil;

    sql = @"SELECT id, author_id,type, created_at, content, status_content,"
    " comment_on_status_id, comment_on_comment_id,reply_name, forwarded_id,group_id, group_name, mask,latitude,longitude,address,video_path, sending, uploadedImages,do_extra_comment_or_forward"
        " FROM drafts WHERE id = ?;";
    rs = [fmdb executeQuery:sql, @(draftId)];
    
    KDDraft *draft = nil;
    NSMutableArray *drafts = [NSMutableArray array];
    
    int idx;
    while ([rs next]) {
        draft = [[KDDraft alloc] init];
        draft.saved = YES;
        
        idx = 0;
        draft.draftId = [rs intForColumnIndex:idx++];
        draft.authorId = [rs stringForColumnIndex:idx ++];
        draft.type = [rs intForColumnIndex:idx++];
        draft.creationDate = [rs dateForColumnIndex:idx++];
        
        draft.content = [rs stringForColumnIndex:idx++];
        draft.originalStatusContent = [rs stringForColumnIndex:idx++];
        draft.commentForStatusId = [rs stringForColumnIndex:idx++];
        draft.commentForCommentId = [rs stringForColumnIndex:idx++];
        draft.replyScreenName = [rs stringForColumnIndex:idx++];
        draft.forwardedStatusId = [rs stringForColumnIndex:idx++];
        
        draft.groupId = [rs stringForColumnIndex:idx++];
        draft.groupName = [rs stringForColumnIndex:idx++];
        
        draft.mask = [rs intForColumnIndex:idx++];
        //CLLocationCoordinate2D coordinate
        // draft.coordinate.latitude = [rs doubleForColumnIndex:idx++];
        float latitute = [rs doubleForColumnIndex:idx++];
        float longitute = [rs doubleForColumnIndex:idx++];
        CLLocationCoordinate2D coordinate = {latitute,longitute};
        draft.coordinate = coordinate;
        draft.address = [rs stringForColumnIndex:idx++];
        draft.videoPath = [rs stringForColumnIndex:idx++];
        draft.sending = [rs intForColumnIndex:idx++];
        draft.doExtraCommentOrForward = [rs boolForColumnIndex:idx++];
        
        NSString *uploadImages = [rs stringForColumnIndex:idx++];
        if (![uploadImages isEqualToString:@""]) {
            draft.uploadedImages =  [NSMutableArray arrayWithArray:[uploadImages componentsSeparatedByString:@","]];
        }
        
        [drafts addObject:draft];
    }
    
    [rs close];
    
    return drafts;
}

- (NSData *)queryDraftImageDataWithId:(NSInteger)draftId database:(FMDatabase *)fmdb {
    NSString *sql = @"SELECT image_data FROM drafts WHERE id=?;";
    
    FMResultSet *rs = [fmdb executeQuery:sql, @(draftId)];
    NSData *data = ([rs next]) ? [rs dataForColumnIndex:0] : nil;
    [rs close];
    
    return data;
}

- (BOOL)removeDraftWithId:(NSInteger)draftId database:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM drafts WHERE id=?;", @(draftId)];
}

- (BOOL)removeAllDraftsInDatabase:(FMDatabase *)fmdb {
    return [fmdb executeUpdate:@"DELETE FROM drafts;"];
}

@end
