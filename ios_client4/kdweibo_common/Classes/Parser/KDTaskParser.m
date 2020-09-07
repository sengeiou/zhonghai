//
//  KDTaskParser.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-7-3.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDTaskParser.h"
#import "KDUserParser.h"
#import "NSDictionary+Additions.h"
#import "KDUtility.h"
@implementation KDTaskParser

- (NSArray *)parseAsUserListDicInArray:(NSArray *)bodyList task:(KDTask *)task{
    NSUInteger count = 0;
    if (bodyList == nil || (count = [bodyList count]) == 0) return nil;
    
    KDUser *user = nil;
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:count];
    KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
    for (NSDictionary *item in bodyList) {
        NSDictionary *userDic = [item objectForKey:@"user"];
        user = [parser parseAsSimple:userDic];
        if (user != nil) {
            if ([user.userId isEqualToString:[[KDUtility defaultUtility]currentUserId] ]) {
                task.isCurrentUserFinish = [item boolForKey:@"isFinish"];
            }
            [users addObject:user];
        }
    }
    
    return users;
}

- (KDTask *)parse:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDTask *task = [[KDTask alloc] init];// autorelease];
    task.taskNewId = [body stringForKey:@"taskNewId"];
    NSArray *executorArray = [body objectNotNSNullForKey:@"executors"];
    KDUserParser *parser = [super parserWithClass:[KDUserParser class]];
    task.executors = [self parseAsUserListDicInArray:executorArray task:task];
    NSDictionary *finishUserDic = [body objectNotNSNullForKey:@"finishUser"];
    if (finishUserDic) {
        task.finishUser = [parser parseAsSimple:finishUserDic];
    }
    NSDictionary *creatorDic = [body objectNotNSNullForKey:@"createUser"];
    if (creatorDic) {
        task.creator = [parser parseAsSimple:creatorDic];
    }
    task.content = [body stringForKey:@"content"];
    task.createDate = [body ASCDatetimeWithMillionSecondsForKey:@"createDate"];
    task.needFinishDate = [body ASCDatetimeWithMillionSecondsForKey:@"needFinishDate"];
    task.finishDate = [body ASCDatetimeWithMillionSecondsForKey:@"finishDate"];
    task.groupId = [body stringForKey:@"groupId"];
    task.groupName = [body stringForKey:@"groupName"];
    task.statusId = [body stringForKey:@"statusId"];
    task.visibility = [body stringForKey:@"visibility"];
    task.threadId = [body stringForKey:@"orig_thread_id"];
    task.microblogId = [body stringForKey:@"microblogId"];
    task.commentId = [body stringForKey:@"commentId"];
    task.messageId = [body stringForKey:@"messageId"];
    task.hasViewDetailPermission = [body boolForKey:@"hasViewDetailPermission"];
    task.state = [body integerForKey:@"status"];
    task.isOver = (task.state == 50);
    
    return task;
}
@end
