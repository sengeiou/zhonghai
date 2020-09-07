//
//  KDSignSchemaParser.h
//  kdweibo_common
//
//  Created by Tan yingqi on 13-8-26.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"
#import "KDSignInSchema.h"
@interface KDSignSchemaParser : KDBaseParser
- (KDSignInSchema *)parse:(NSDictionary *)body;
@end
