//
//  KDUserParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@class KDUser;

@interface KDUserParser : KDBaseParser

- (KDUser *)parse:(NSDictionary *)body withStatus:(BOOL)contains; // parse all the items for user if need
- (KDUser *)parseAsSimple:(NSDictionary *)body; // just parse the basic info about user

- (NSArray *)parseAsUserList:(NSArray *)body withStatus:(BOOL)contains; // parse user info and latest status for users
- (NSArray *)parseAsUserListSimple:(NSArray *)bodyList; // just parse basic info about each user
//- (NSArray *)parseAsUserListDicInArray:(NSArray *)bodyList; // 数组成员为‘user’为key 的字典

@end
