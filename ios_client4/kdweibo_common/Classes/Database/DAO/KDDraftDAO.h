//
//  KDDraftDAO.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-30.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class KDDraft;

typedef enum DraftQueryType
{
    DraftInSending = 0,
    DraftNotInSending,
    DraftAll
}DraftQueryType;

@protocol KDDraftDAO <NSObject>
@required

- (void)saveDraft:(KDDraft *)draft database:(FMDatabase *)fmdb;
- (BOOL)updateDraft:(KDDraft *)draft database:(FMDatabase *)fmdb;

- (NSUInteger)queryAllDraftsCountInDatabase:(FMDatabase *)fmdb;
- (NSUInteger)queryAllDraftsCountWithType:(DraftQueryType)type database:(FMDatabase *)fmdb;
- (NSArray *)queryAllDraftsWithAuthorId:(NSString *)authorId database:(FMDatabase *)fmdb;
- (NSArray *)queryAllDraftsWithAuthorId:(NSString *)authorId type:(DraftQueryType)type database:(FMDatabase *)fmdb;
- (NSData *)queryDraftImageDataWithId:(NSInteger)draftId database:(FMDatabase *)fmdb;
- (NSArray *)queryAllDraftsWithDraftId:(NSInteger)draftId  database:(FMDatabase *)fmdb;
- (BOOL)updateDraftWithId:(NSInteger)draftId SendingType:(DraftQueryType)type  database:(FMDatabase *)fmdb;
- (BOOL)removeDraftWithId:(NSInteger)draftId database:(FMDatabase *)fmdb;
- (BOOL)removeAllDraftsInDatabase:(FMDatabase *)fmdb;

@end