//
//  KDVideoCoverUploadTask.m
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDVideoCoverUploadTask.h"

@implementation KDVideoCoverUploadTask
- (NSString *)documentType {
    return nil;
}

- (void)taskDidSuccess {
    DLog(@"video cover upload success...");
    [super taskDidSuccess];
}
@end
