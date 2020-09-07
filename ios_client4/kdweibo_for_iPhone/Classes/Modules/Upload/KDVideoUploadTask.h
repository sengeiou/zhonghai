//
//  KDVideoUploadTask.h
//  kdweibo
//
//  Created by Tan Yingqi on 13-12-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDDocumentUploadTask.h"
#import "KDAttachment.h"
@interface KDVideoUploadTask : KDDocumentUploadTask
@property(nonatomic,retain)KDAttachment *attachment;
+ (KDVideoUploadTask *)videoUploadTaskWithAttachements:(NSArray *)attachements;
@end
