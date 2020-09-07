//
//  KDSignShareUploadTask.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDSignShareUploadTask.h"

@implementation KDSignShareUploadTask

- (void)handleResults:(id)results {
    
}

- (NSString *)actionPath {
    if (!actionPath_) {
        actionPath_ =  [[NSString alloc] initWithString:@"/statuses/:sharesignin"];
    }
    return actionPath_;
}

@end
