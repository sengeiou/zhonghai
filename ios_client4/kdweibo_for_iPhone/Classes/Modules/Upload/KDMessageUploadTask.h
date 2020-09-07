//
//  KDMessageUploadTask.h
//  kdweibo
//
//  Created by Tan yingqi on 13-5-18.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDUploadTask.h"
@class KDDMMessage;
@interface KDMessageUploadTask : KDUploadTask

//@property(nonatomic,retain)KDDMMessage *message;

+(KDMessageUploadTask *)taskWithMessage:(KDDMMessage *)message sendEmail:(BOOL)send;
@end
