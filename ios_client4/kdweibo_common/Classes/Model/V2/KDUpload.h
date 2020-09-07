//
//  KDUpload.h
//  kdweibo_common
//
//  Created by Tan yingqi on 13-5-16.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KDUpload : NSObject
@property(nonatomic,copy)NSString *uploadId;
@property(nonatomic,copy)NSString *path;
@property(nonatomic,assign)BOOL isUploaded;
@property(nonatomic,copy)NSString *thumbPath;
@property(nonatomic,copy)NSString *tempPath;

@end
