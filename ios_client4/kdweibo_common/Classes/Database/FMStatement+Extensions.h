//
//  FMStatement+Extensions.h
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "FMDatabase.h"

@interface FMStatement (Extensions)

- (void)bindBool:(BOOL)val atIndex:(int)idx;
- (void)bindShort:(short)val atIndex:(int)idx;
- (void)bindInt:(int)val atIndex:(int)idx;
- (void)bindLong:(long)val atIndex:(int)idx;
- (void)bindLongLong:(long long)val atIndex:(int)idx;
- (void)bindUnsignedLongLong:(unsigned long long)val atIndex:(int)idx;

- (void)bindFloat:(float)val atIndex:(int)idx;
- (void)bindDouble:(double)val atIndex:(int)idx;

- (void)bindString:(NSString *)string atIndex:(int)idx;
- (void)bindDate:(NSDate *)date atIndex:(int)idx;
- (void)bindData:(NSData *)data atIndex:(int)idx;

- (BOOL)step; // call sqlite3_step()

@end
