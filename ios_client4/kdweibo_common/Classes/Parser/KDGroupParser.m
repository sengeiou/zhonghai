//
//  KDGroupParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-12.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDGroupParser.h"

#import "KDGroup.h"

static NSString * const kKDPrivateGroupIndetifier = @"PRIVATE";

@implementation KDGroupParser

- (KDGroup *)parse:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDGroup *group = [[KDGroup alloc] init];// autorelease];
    
    group.groupId = [body stringForKey:@"id"];
    group.name = [body stringForKey:@"name"];
    
    NSString *url = [body stringForKey:@"profile_image_url"];
    if (url != nil && [url length] > 0) {
        group.profileImageURL = url;
    }
    
	group.summary = [body stringForKey:@"description"];
    group.bulletin = [body objectForKey:@"bulletin"];
    group.latestMsgDate = nil;//[body ASCDatetimeWithMillionSecondsForKey:@"latestMsgDate"];
    group.latestMsgContent = [body stringForKey:@"latestMsgContent"];

    BOOL isPrivate = [kKDPrivateGroupIndetifier isEqualToString:[body stringForKey:@"type"]];
    group.type = isPrivate ? KDGroupTypePrivate : KDGroupTypePublic;
    NSDictionary *details = [body objectNotNSNullForKey:@"detail"];
    if (details) {
        group.memberCount = [details integerForKey:@"memberCount"];
        group.messageCount = [details integerForKey:@"messageCount"];
    }
    return group;
}

- (NSArray *)parseAsGroupList:(NSArray *)body {
    NSUInteger count = 0;
    if (body == nil || (count = [body count]) == 0) return nil;
    
    KDGroup *g = nil;
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:count];
    for (NSDictionary *item in body) {
        g = [self parse:item];
        if (g != nil) {
            [groups addObject:g];
        }
    }
    
    return groups;
}

@end
