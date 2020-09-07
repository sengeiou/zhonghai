//
//  KDNormalStatusUploadTask.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-20.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDNormalStatusUploadTask.h"
#import "KDDatabaseHelper.h"

@implementation KDNormalStatusUploadTask
- (KDQuery *)query {
    if (!query_) {
         query_ = [super query];
         [query_ setParameter:@"status" stringValue:status_.text];
    }
    return query_;
}

- (NSString *)actionPath {
    if (!actionPath_) {
        if (status_.groupId) {
            actionPath_ =  [[NSString alloc] initWithString:@"/group/statuses/:update"];
        }else {
            actionPath_ =  [[NSString alloc] initWithString:@"/statuses/:update"];
        }
    }
    return actionPath_;
}

@end
