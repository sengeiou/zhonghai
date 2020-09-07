//
//  KDXTUnread.m
//  kdweibo_common
//
//  Created by weihao_xu on 14-7-22.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDXTUnread.h"

@implementation KDXTUnread
@synthesize unreadDictionary = unreadDictionary_;
- (id)init{
    if(self = [super init]){
    }
    return self;
}


- (NSUInteger )unreadCountForUserId : (NSString *)userId{
    NSDictionary *dic = [unreadDictionary_ valueForKey:userId];
    NSNumber *unreadCount = dic[@"unreadCount"];
    return unreadCount.integerValue;
}
@end
