//
//  KDUserParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDUserParser.h"
#import "KDParserManager.h"
#import "KDUser.h"

@implementation KDUserParser

- (KDUser *)parse:(NSDictionary *)body withStatus:(BOOL)contains {
    if (body == nil || [body count] == 0) return nil;
    
    KDUser *user = [self parseAsSimple:body];
    
	user.email = [body stringForKey:@"email"];
	user.summary = [body stringForKey:@"description"];
    
	user.friendsCount = [body intForKey:@"friends_count"];
	user.followersCount = [body intForKey:@"followers_count"];
	user.statusesCount = [body intForKey:@"statuses_count"];
    user.favoritesCount = [body intForKey:@"favourites_count"];
    user.topicsCount = [body intForKey:@"topic_count"];
    
	user.location = [body stringForKey:@"location"];
    
    user.jobTitle = [body stringForKey:@"job_title" defaultValue:@""];
    user.department = [body stringForKey:@"department" defaultValue:@""];
    user.companyName = [body stringForKey:@"companyName" defaultValue:@""];
    
    user.defaultNetworkType = [body stringForKey:@"defaultNetworkType" defaultValue:@""];
    
    user.domain = [body stringForKey:@"domain"];
    
    user.isPublicUser = [body boolForKey:@"publicUser"];
    user.isTeamUser = [body boolForKey:@"teamUser"];
    user.openId = [body stringForKey:@"xtId"];
    user.wbNetworkId = [body stringForKey:@"companyId"];
    
    if (contains) {
        NSDictionary *statusBody = [body objectNotNSNullForKey:@"status"];
        if(statusBody != nil) {
            KDStatusParser *parser = [super parserWithClass:[KDStatusParser class]];
            user.latestStatus = [parser parseAsStatus:statusBody type:KDTLStatusTypeUndefined];
        }
    }
    
    return user;
}

- (KDUser *)parseAsSimple:(NSDictionary *)body {
    if (body == nil || [body count] == 0||![body stringForKey:@"id"]) return nil;
    
    KDUser *user = [[KDUser alloc] init];//;／／ autorelease];
    
    user.userId = [body stringForKey:@"id"];
    user.username = [body stringForKey:@"name"];
	user.screenName = [body stringForKey:@"screen_name"];
    user.department = [body stringForKey:@"department"];
    user.jobTitle = [body stringForKey:@"job_title"];
    user.companyName = [body stringForKey:@"companyName"];
    
    user.defaultNetworkType = [body stringForKey:@"defaultNetworkType" defaultValue:@""];
    
	NSString *url = [body stringForKey:@"profile_image_url"];
	if(url != nil && [url length] > 0) {
		user.profileImageUrl = [url stringByAppendingString:@"&spec=180"];
	}
    
    user.isPublicUser = [body boolForKey:@"publicUser"];
    user.isTeamUser = [body boolForKey:@"teamUser"];
    
    return user;
}

- (NSArray *)parseAsUserList:(NSArray *)body withStatus:(BOOL)contains {
    NSUInteger count = 0;
    if (body == nil || (count = [body count]) == 0) return nil;
    
    KDUser *user = nil;
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:count];
    
    for (NSDictionary *item in body) {
        user = [self parse:item withStatus:contains];
        if (user != nil) {
            [users addObject:user];
        }
    }
    
    return users;
}

- (NSArray *)parseAsUserListSimple:(NSArray *)bodyList {
    NSUInteger count = 0;
    if (bodyList == nil || (count = [bodyList count]) == 0) return nil;
    
    KDUser *user = nil;
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:count];
    
    for (NSDictionary *item in bodyList) {
        user = [self parseAsSimple:item];
        if (user != nil) {
            [users addObject:user];
        }
    }
    
    return users;
}

//- (NSArray *)parseAsUserListDicInArray:(NSArray *)bodyList {
//    NSUInteger count = 0;
//    if (bodyList == nil || (count = [bodyList count]) == 0) return nil;
//    
//    KDUser *user = nil;
//    NSMutableArray *users = [NSMutableArray arrayWithCapacity:count];
//    
//    for (NSDictionary *item in bodyList) {
//        NSDictionary *uerDic = [item objectForKey:@"user"];
//        user = [self parseAsSimple:uerDic];
//        if (user != nil) {
//            BOOL isFinish = [userDic boolForKey:@"isFinish"];
//            [users addObject:user];
//        }
//    }
//    
//    return users;
//}
@end
