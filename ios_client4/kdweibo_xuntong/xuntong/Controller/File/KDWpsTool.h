//
//  KDWpsTool.h
//  kdweibo
//
//  Created by fang.jiaxin on 15/5/19.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#if!(TARGET_IPHONE_SIMULATOR)

#import "KWOfficeApi.h"

#endif

typedef void (^KDWpsCompletionBlock) (BOOL success,NSData *data,NSString *fileCachePath);

@interface KDWpsTool : NSObject<UIAlertViewDelegate
#if!(TARGET_IPHONE_SIMULATOR)
,KWOfficeApiDelegate
 #endif
>

+(KDWpsTool *)shareInstance;

@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,strong)NSData *data;
@property(nonatomic,strong)id tempWPSTool;//用于临时存储该对象，某些情况下防止被释放

@property(nonatomic,readonly)NSString *fileCachePath;//解密后的文件路径

//aes加密解密
-(void)encryptFile:(NSString *)filePath complectionBlock:(KDWpsCompletionBlock)complectionBlock;
-(void)decryptFile:(NSString *)filePath complectionBlock:(KDWpsCompletionBlock)complectionBlock;
-(BOOL)removeCacheFile:(NSString *)filePath;
-(NSData *)encryptData:(NSData *)data;
-(NSData *)decryptData:(NSData *)data;
-(BOOL)removeTempFile;

-(BOOL)openWPSWithFile:(NSString *)filePath;
@end
