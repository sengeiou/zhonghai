//
//  KDFileDownloadManager.h
//  kdweibo
//
//  Created by fang.jiaxin on 2017/11/3.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileModel.h"

@interface KDFileDownloadManager : NSObject

+(KDFileDownloadManager *)shareManager;
//-(void)downloadFileWithUrl:(NSString *)url result:(id (^)(BOOL success))resultBlock;
-(void)downloadFile:(FileModel *)fileModel result:(void (^)(BOOL success))resultBlock;
-(void)cancelDownload;
@end
