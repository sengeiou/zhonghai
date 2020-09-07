//
//  NSDictionary+NULL.h
//  kdweibo
//
//  Created by 王 松 on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (File)

- (BOOL)writeToArchivedFile:(NSString*)path; //将字典序列化保存

+ (instancetype)dictionaryWithArchivedFile:(NSString*)path; //将字典序列化保存

@end
