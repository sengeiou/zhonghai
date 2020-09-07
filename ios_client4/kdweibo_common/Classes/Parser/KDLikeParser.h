//
//  KDLikeParser.h
//  kdweibo_common
//
//  Created by kingdee on 14-9-2.
//  Copyright (c) 2014年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@class KDLike;

@interface KDLikeParser : KDBaseParser

- (NSArray *)parserLikes:(NSArray *)jsonList;

@end
