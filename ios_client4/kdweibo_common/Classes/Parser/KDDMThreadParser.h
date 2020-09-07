//
//  KDDMThreadParser.h
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@class KDDMThread;
@interface KDDMThreadParser : KDBaseParser
- (NSArray *)parseTop:(NSArray *)body;
- (NSArray *)parse:(NSArray *)body;
- (KDDMThread *)parseSingle:(NSDictionary *)item;

@end
