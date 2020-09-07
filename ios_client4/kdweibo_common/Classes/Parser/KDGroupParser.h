//
//  KDGroupParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-12.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@class KDGroup;

@interface KDGroupParser : KDBaseParser

- (KDGroup *)parse:(NSDictionary *)body;
- (NSArray *)parseAsGroupList:(NSArray *)body;

@end
