//
//  KDStatusParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDStatusParser.h"
#import "KDUserParser.h"
#import "KDStatusExtraMessageParser.h"
#import "KDExtendStatusParser.h"

#import "KDStatus.h"
#import "KDMentionMeStatus.h"
#import "KDCommentMeStatus.h"
#import "KDCommentStatus.h"
#import "KDGroupStatus.h"
#import "KDStatusCounts.h"
#import "NSString+Additions.h"


#define MAP_IMAGE_BASE_URL   @"http://st.map.soso.com/api"
#define MAP_IMAGE_THUMBNAIL_SIZE  @"180*180"
#define MAP_IMAGE_MIDDLE_SIZE   @"480*360"
@implementation KDStatusParser

- (id)_statusWithClass:(Class)clazz {
    return [[clazz alloc] init];// autorelease];
}

- (BOOL)_validate:(NSDictionary *)body {
    return body != nil && [body count] > 0;
}

- (BOOL)_validateList:(NSArray *)body {
    return body != nil && [body count] > 0;
}

- (void)_parseExtraSource:(NSDictionary *)body to:(KDStatus *)status {
    // images
    KDCompositeImageSource *cis = [super parseAsCompositeImageSource:[body objectNotNSNullForKey:@"pictures"]];
    if(cis != nil && [cis hasImageSource]){
        status.compositeImageSource = cis;
        
        status.extraSourceMask |= KDExtraSourceMaskImages;
        for (KDImageSource *imageSource in cis.imageSources) {
            imageSource.entityId = status.statusId;
        }
    }
    
    // documents
    status.attachments = [super parseAsAttachments:[body objectNotNSNullForKey:@"attachment"] objectId:status.statusId];
    if ([status hasAttachments] || [status hasVideo]) {
        status.extraSourceMask |= KDExtraSourceMaskDocuments;
    }
}

//


- (void)_parseBasicInfoWithBody:(NSDictionary *)body to:(KDStatus *)status {
    status.statusId = [body stringForKey:@"id"];
    //status.text = [body stringForKey:@"text"];
    status.address = [body stringForKey:@"address"];
    status.text = [body stringForKey:@"text"];
    status.source = [body stringForKey:@"source" defaultValue:@""];
    
    status.groupId = [body stringForKey:@"group_id"];
    status.groupName = [body stringForKey:@"group_Name"];
    
    status.createdAt = [body ASCDatetimeForKey:@"created_at"];
    status.updatedAt = [body ASCDatetimeWithMillionSecondsForKey:@"update_at"];
    
    status.favorited = [body boolForKey:@"favorited"];
    status.truncated = [body boolForKey:@"truncated"];
    status.liked = [body boolForKey:@"liked"];
    status.latitude = [body floatForKey:@"latitude"];
    status.longitude = [body floatForKey:@"longitude"];
    status.replyStatusId = [body stringForKey:@"in_reply_to_status_id"];
    status.replyUserId = [body stringForKey:@"in_reply_to_user_id"];
    status.replyScreenName = [body stringForKey:@"in_reply_to_screen_name"];
    
    //    status.delData = [body objectForKey:@"delData"];
    
    status.likedCount = [body intForKey:@"like_count"];
    //    if ([status isKindOfClass:[KDGroupStatus class]]) {
    status.commentsCount = [body intForKey:@"reply_count"];
    //    }
    
    NSDictionary *userInfo = [body objectNotNSNullForKey:@"user"];
    KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
    status.author = [parser parseAsSimple:userInfo];
    
    // parse extra source
    [self _parseExtraSource:body to:status];
    // [self assemblyMapImageUrl:status];
    
    // parse forwarded status
    NSDictionary *fwdBody = [body objectNotNSNullForKey:@"retweeted_status"];
    if(fwdBody != nil) {
        KDStatus *fwdStatus = [self _statusWithClass:[KDStatus class]];
        
        [self _parseBasicInfoWithBody:fwdBody to:fwdStatus];
        if (fwdStatus.statusId == nil) {
            fwdStatus.statusId = kKDHasBeenDeletedStatusId; // the forwarded status has been deleted by author.
        }
        
        status.forwardedStatus = fwdStatus;
    }
    
    // parse status extra message
    NSDictionary *extraMessageInfo = [body objectNotNSNullForKey:@"msgExtra"];
    if (extraMessageInfo != nil) {
        KDStatusExtraMessageParser *extraMessageParser = [super parserWithClass:[KDStatusExtraMessageParser class]];
        KDStatusExtraMessage *sem = [extraMessageParser parse:extraMessageInfo];
        if (sem != nil) {
            if (![sem.visibility isEqualToString:@"private"]) {
                if (status.groupName) {
                    sem.visibility = status.groupName;
                }
            }
            status.extraMessage = sem;
            
            if ([sem isConnector]) {
                KDExtendStatusParser *extendStatusParser = [super parserWithClass:[KDExtendStatusParser class]];
                status.extendStatus = [extendStatusParser parse:extraMessageInfo];
                
            } else {
                // for now, just need to format (praise, bulletin, freshman) extra message body
                // and append to status text
                NSString *messageBody = [KDStatusExtraMessage formatExtraMessage:sem appendToContent:status.text];
                if (messageBody != nil) {
                    status.text = messageBody;
                }
            }
        }
    }
}

- (id)_parseWithBody:(NSDictionary *)body toClazz:(Class)clazz didCompleteBlock:(void (^) (NSDictionary *, id))block {
    if (![self _validate:body]) return nil;
    
    KDStatus *status = [self _statusWithClass:clazz];
    [self _parseBasicInfoWithBody:body to:status];
    if (block != nil) {
        block(body, status);
    }
    
    return status;
}

- (NSArray *)_parseWithBodyList:(NSArray *)body toClazz:(Class)clazz didCompleteBlock:(void (^) (NSDictionary *, id))block {
    if (![self _validateList:body]) return nil;
    
    KDStatus *s = nil;
    
    NSArray *dataArray = nil;
    NSArray *delDataArray = nil;
    
    NSMutableArray *statuses = [NSMutableArray arrayWithCapacity:[body count]];
    NSArray *allKeys = [(NSDictionary *)[body firstObject] allKeys];
    if ([allKeys count ] > 3) {
        for (NSDictionary *item in body) {
            s = [self _parseWithBody:item toClazz:clazz didCompleteBlock:block];
            if (s != nil) {
                [statuses addObject:s];
            }
        }
    }
    else
    {
        dataArray = [[body firstObject] objectForKey:@"data"];
        delDataArray = [[body firstObject] objectForKey:@"delData"];
        
        if ([dataArray count] > 0) {
            for (NSDictionary *item in dataArray) {
                s = [self _parseWithBody:item toClazz:clazz didCompleteBlock:block];
                if (s != nil && s.statusId != nil) {
                    [statuses addObject:s];
                }
            }
        }
        
        if ([delDataArray count] >0) {
            [statuses addObject:delDataArray];
        }
        
    }
    return statuses;
}


/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark normal status and forwarded status

- (KDStatus *)parseAsStatus:(NSDictionary *)body type:(KDTLStatusType)type {
    return [self _parseWithBody:body
                        toClazz:[KDStatus class]
               didCompleteBlock:^(NSDictionary *body, id status){
                   ((KDStatus *)status).type = type;
               }];
}

- (NSArray *)parseAsStatuses:(NSArray *)bodyList type:(KDTLStatusType)type {
    return [self _parseWithBodyList:bodyList
                            toClazz:[KDStatus class]
                   didCompleteBlock:^(NSDictionary *body, id status){
                       ((KDStatus *)status).type = type;
                   }];
}

- (NSArray *)parseAsStatusCountsList:(NSArray *)bodyList {
    NSUInteger count = 0;
    if (bodyList == nil || (count = [bodyList count]) == 0) return nil;
    
    KDStatusCounts *sc = nil;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
    for (NSDictionary *body in bodyList) {
        sc = [[KDStatusCounts alloc] init];
        
        sc.statusId = [body stringForKey:@"id"];
        sc.forwardsCount = [body integerForKey:@"rt"];
        sc.commentsCount = [body integerForKey:@"comments"];
        sc.likedCount = [body integerForKey:@"like"];
        sc.liked = [body boolForKey:@"liked"];
        
        //zgbin:加点赞和评论的字段
        sc.microBlogComments = [body objectForKey:@"microBlogComments"];
        sc.likeUserInfos = [body objectForKey:@"likeUserInfos"];
        //zgbin:end
        
        [items addObject:sc];
        //        [sc release];
    }
    
    return items;
}


/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark mention me status

- (void)_didParseMentionMeStatus:(KDMentionMeStatus *)status body:(NSDictionary *)body {
    //_parseBasicInfoWithBody 已经有了
    
    
    
    //    NSDictionary *statusInfo = [body objectNotNSNullForKey:@"status"];
    //    if(statusInfo != nil) {
    //        status.groupId = [statusInfo stringForKey:@"group_id"];
    //        status.groupName = [statusInfo stringForKey:@"group_Name"];
    //    }
}

- (KDMentionMeStatus *)parseAsMentionMeStatus:(NSDictionary *)body {
    return [self _parseWithBody:body
                        toClazz:[KDMentionMeStatus class]
               didCompleteBlock:^(NSDictionary *body, id status){
                   [self _didParseMentionMeStatus:status body:body];
               }];
}

- (NSArray *)parseAsMentionMeStatuses:(NSArray *)body {
    return [self _parseWithBodyList:body
                            toClazz:[KDMentionMeStatus class]
                   didCompleteBlock:^(NSDictionary *body, id status){
                       [self _didParseMentionMeStatus:status body:body];
                   }];
}


/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark comment me status

- (void)_didParseCommentMeStatus:(KDCommentMeStatus *)status body:(NSDictionary *)body {
    status.replyStatusText = [body stringForKey:@"in_reply_to_status_text"];
    status.replyCommentText = [body stringForKey:@"in_reply_to_comment_text"];
    
    NSDictionary *statusInfo = [body objectNotNSNullForKey:@"status"];
    if(statusInfo != nil) {
        //        status.groupId = [statusInfo stringForKey:@"group_id"];
        //        status.groupName = [statusInfo stringForKey:@"group_Name"];
        if (status.groupId) {
            status.status = [self parseAsGroupStatus:statusInfo];
        }else {
            status.status = [self parseAsStatus:statusInfo type:KDTLStatusTypePublic];
        }
        
    }
}

- (KDCommentMeStatus *)parseAsCommentMeStatus:(NSDictionary *)body {
    return [self _parseWithBody:body
                        toClazz:[KDCommentMeStatus class]
               didCompleteBlock:^(NSDictionary *body, id status){
                   [self _didParseCommentMeStatus:status body:body];
               }];
}

- (NSArray *)parseAsCommentMeStatuses:(NSArray *)body {
    return [self _parseWithBodyList:body
                            toClazz:[KDCommentMeStatus class]
                   didCompleteBlock:^(NSDictionary *body, id status){
                       [self _didParseCommentMeStatus:status body:body];
                   }];
}


/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark comment status

- (void)_didParseCommentStatus:(KDCommentStatus *)status body:(NSDictionary *)body {
    
    status.replyCommentText = [body stringForKey:@"in_reply_to_comment_text"];
    status.messageState = KDCommentStateSended;
    NSDictionary *statusInfo = [body objectNotNSNullForKey:@"status"];
    if(statusInfo){
        status.status = [self parseAsStatus:statusInfo type:KDTLStatusTypeUndefined];
    }
    
}

- (KDCommentStatus *)parseAsCommentStatus:(NSDictionary *)body {
    return [self _parseWithBody:body
                        toClazz:[KDCommentStatus class]
               didCompleteBlock:^(NSDictionary *body, id status){
                   [self _didParseCommentStatus:status body:body];
               }];
}

- (NSArray *)parseAsCommentStatuses:(NSArray *)body {
    return [self _parseWithBodyList:body
                            toClazz:[KDCommentStatus class]
                   didCompleteBlock:^(NSDictionary *body, id status){
                       [self _didParseCommentStatus:status body:body];
                   }];
}


/////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark group status

- (KDGroupStatus *)parseAsGroupStatus:(NSDictionary *)body {
    return  [self _parseWithBody:body toClazz:[KDGroupStatus class] didCompleteBlock:nil];
}

- (NSArray *)parseAsGroupStatuses:(NSArray *)body {
    return [self _parseWithBodyList:body toClazz:[KDGroupStatus class] didCompleteBlock:nil];
}

@end

