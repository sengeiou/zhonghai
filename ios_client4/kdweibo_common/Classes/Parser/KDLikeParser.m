//
//  KDLikeParser.m
//  kdweibo_common
//
//  Created by kingdee on 14-9-2.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDLike.h"
#import "KDLikeParser.h"
#import "KDUserParser.h"

@implementation KDLikeParser

- (KDLike *)parserLike:(NSDictionary *)dic
{
    KDLike *like = [[KDLike alloc] init];
    
    like.likeId = [dic stringForKey:@"id"];
    like.networkId = [dic stringForKey:@"networkId"];
    like.refId = [dic stringForKey:@"refId"];
    like.refType = [dic stringForKey:@"refType"];
    like.time = [dic ASCDatetimeForKey:@"time"];
    
    KDUserParser *parser = (KDUserParser *)[super parserWithClass:[KDUserParser class]];
    like.user = [parser parse:[dic objectForKey:@"user"] withStatus:NO];
    
    like.userId = [dic stringForKey:@"userId"];
    
    return like;// autorelease];
}

- (NSArray *)parserLikes:(NSArray *)jsonList
{
    if(jsonList.count == 0) return nil;
    
    NSMutableArray *likers = [NSMutableArray array];
    for(NSDictionary *dic in jsonList) {
        if(dic && dic.count > 0) {
            [likers addObject:[self parserLike:dic]];
        }
    }
    
    return likers;
}


@end
