//
//  KDSignInParser.h
//  kdweibo_common
//
//  Created by Tan yingqi on 13-8-23.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDBaseParser.h"
#import "KDSignInRecord.h"
@interface KDSignInParser : KDBaseParser
- (NSArray *)parseSignIns:(NSArray *)array;
- (KDSignInRecord *)parse:(NSDictionary *)body;
@end
