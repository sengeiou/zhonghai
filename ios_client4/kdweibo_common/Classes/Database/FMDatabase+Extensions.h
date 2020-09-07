//
//  FMDatabase+Extensions.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "FMDatabase.h"

@interface FMDatabase (Extensions)

- (FMStatement *)preparedStatementWithSQL:(NSString *)sql;

@end
