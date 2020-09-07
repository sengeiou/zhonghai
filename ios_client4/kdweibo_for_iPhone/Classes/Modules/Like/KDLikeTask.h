//
//  KDLikeTask.h
//  kdweibo
//
//  Created by Tan yingqi on 13-6-5.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDUploadTask.h"
#import "KDStatus.h"
@interface KDLikeTask : KDUploadTask
@property(nonatomic,retain)KDStatus *status;
@end
