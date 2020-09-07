//
//  KDMessageUploadTaskHelper.h
//  kdweibo
//
//  Created by Tan yingqi on 13-6-7.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDUploadTask.h"
#import "KDImageUploadTask.h"
#import "KDForwardStatusUploadTask.h"
#import "KDCommentUploadTask.h"
#import "KDNormalStatusUploadTask.h"

@interface KDUploadTaskHelper : NSObject
- (void)handleTask:(KDUploadTask *)task entityId:(NSString *)theId;
- (BOOL)isTaskOnRunning:(NSString *)theId;
-(id)entityById:(NSString *)theId;
+(KDUploadTaskHelper *)shareUploadTaskHelper;
@end
