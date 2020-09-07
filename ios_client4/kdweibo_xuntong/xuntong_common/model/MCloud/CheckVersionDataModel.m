//
//  CheckVersionDataModel.m
//  Public
//
//  Created by Gil on 12-4-26.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "CheckVersionDataModel.h"

@implementation CheckVersionDataModel
@synthesize updateFlag = _updateFlag_;
@synthesize newversion = _newversion_;
@synthesize iosURL = _iosURL_;
@synthesize message = _message_;
@synthesize updateNote = _updateNote_;

- (id)init {
    self = [super init];
    if (self) {
        _updateFlag_ = UpdateNotNeed;
        _newversion_ = [[NSString alloc] init];
        _iosURL_ = [[NSString alloc] init];
        _message_ = [[NSString alloc] init];
        _updateNote_ = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id updateFlag = [dict objectForKey:@"updateFlag"];
        id newVersion = [dict objectForKey:@"newVersion"];
        id iosURL = [dict objectForKey:@"iosURL"];
        id message = [dict objectForKey:@"message"];
        id updateNote = [dict objectForKey:@"updateNote"];
        
        if (![updateFlag isKindOfClass:[NSNull class]] && updateFlag) {
            self.updateFlag = [updateFlag intValue];
        }
        if (![newVersion isKindOfClass:[NSNull class]] && newVersion) {
            self.newversion = newVersion;
        }
        if (![iosURL isKindOfClass:[NSNull class]] && iosURL) {
            self.iosURL = iosURL;
        }
        if (![message isKindOfClass:[NSNull class]] && message) {
            self.message = message;
        }
        if (![updateNote isKindOfClass:[NSNull class]] && updateNote) {
            self.updateNote = updateNote;
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_newversion_);
    //BOSRELEASE_iosURL_);
    //BOSRELEASE_message_);
    //BOSRELEASE_updateNote_);
    //[super dealloc];
}

@end
