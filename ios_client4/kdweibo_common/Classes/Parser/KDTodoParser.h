//
//  KDTodoParser.h
//  kdweibo_common
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDBaseParser.h"

@interface KDTodoParser : KDBaseParser

@property (nonatomic, assign) double doneCount;
@property (nonatomic, assign) double itemstotal;
@property (nonatomic, assign) double undoCount;
@property (nonatomic, assign) double ignoreCount;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, retain) id errormsg;
@property (nonatomic, retain) NSArray *items;

- (void)parse:(NSDictionary *)body;
@end
