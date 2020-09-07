//
//  KDInboxParser.h
//
//  Created by kingdee  on 13-7-1
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
#import "KDBaseParser.h"
@interface KDInboxParser :KDBaseParser

@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) double total;
@property (nonatomic, retain) id error;

- (void)parse:(NSDictionary *)body;

@end
