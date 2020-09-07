//
//  KDTaskParser.h
//  kdweibo_common
//
//  Created by Tan yingqi on 13-7-3.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDBaseParser.h"
#import "KDTask.h"
@interface KDTaskParser : KDBaseParser
- (KDTask *)parse:(NSDictionary *)body;
@end
