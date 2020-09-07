//
//  KDFavoriteTask.h
//  kdweibo
//
//  Created by shen kuikui on 13-7-29.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDUploadTask.h"
#import "KDStatus.h"
@interface KDFavoriteTask : KDUploadTask
@property (nonatomic, retain) KDStatus *status;
@end
