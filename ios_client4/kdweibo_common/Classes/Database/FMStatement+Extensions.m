//
//  FMStatement+Extensions.m
//  kdweibo_common
//
//  Created by laijiandong on 12-11-29.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "FMStatement+Extensions.h"

@implementation FMStatement(Extensions)

- (void)bindBool:(BOOL)val atIndex:(int)idx {
    sqlite3_bind_int(self.statement, idx, (val ? 1 : 0));
}

- (void)bindShort:(short)val atIndex:(int)idx {
    sqlite3_bind_int(self.statement, idx, val);
}

- (void)bindInt:(int)val atIndex:(int)idx {
    sqlite3_bind_int(self.statement, idx, val);
}

- (void)bindLong:(long)val atIndex:(int)idx {
    sqlite3_bind_int(self.statement, idx, (int)val);
}

- (void)bindLongLong:(long long)val atIndex:(int)idx {
    sqlite3_bind_int64(self.statement, idx, val);
}

- (void)bindUnsignedLongLong:(unsigned long long)val atIndex:(int)idx {
    sqlite3_bind_int64(self.statement, idx, val);
}

- (void)bindFloat:(float)val atIndex:(int)idx {
    sqlite3_bind_double(self.statement, idx, val);
}

- (void)bindDouble:(double)val atIndex:(int)idx {
    sqlite3_bind_double(self.statement, idx, val);
}

- (void)bindString:(NSString *)string atIndex:(int)idx {
    sqlite3_bind_text(self.statement, idx, (string != nil) ? [string UTF8String] : nil, -1, SQLITE_STATIC);
}

- (void)bindDate:(NSDate *)date atIndex:(int)idx {
    sqlite3_bind_double(self.statement, idx, [date timeIntervalSince1970]);
}

- (void)bindData:(NSData *)data atIndex:(int)idx {
    const void *bytes = [data bytes];
    if (!bytes) {
        // it's an empty NSData object, aka [NSData data].
        // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
        bytes = "";
    }
    
    sqlite3_bind_blob(self.statement, idx, bytes, (int)[data length], SQLITE_STATIC);
}

- (BOOL)step {
    if (_statement) {
        int status = sqlite3_step(self.statement);
        if(status != SQLITE_DONE)
            NSLog(@"step error : %d", status);
        
        return SQLITE_DONE == status;
    }
    
    return NO;
}

@end
