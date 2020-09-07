//
//  KDFailureSignInTask.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/17.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDFailureSignInTask.h"
#import "BOSSetting.h"
#import "KDDatabaseHelper.h"
#import "KDSigninRecordDAO.h"
#import "KDWeiboDAOManager.h"
#import "KDPhotoUploadTask.h"
#import "KDSignInUtil.h"

@interface KDFailureSignInTask () <KDPhotoUploadTaskDelegate>
@property(nonatomic, strong) NSMutableArray *failuredSignInRecourds;
@property(nonatomic, assign) BOOL isRunning;
@property(nonatomic, strong) NSMutableArray *uploadTaskArray;
@property(nonatomic, assign) NSInteger uploadSuccessCount;
@property(nonatomic, assign) NSInteger uploadFailurdCount;
@end

@implementation KDFailureSignInTask

+ (id)sharedFailureSignInTask {
    static dispatch_once_t pred;
    static KDFailureSignInTask *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[KDFailureSignInTask alloc] init];
    });
    return instance;
}


- (void)setUpData {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:KDReachabilityDidChangeNotification object:nil];
}

- (void)stopFailureSignInTask {
    self.uploadSuccessCount = 0;
    self.uploadFailurdCount = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDReachabilityDidChangeNotification object:nil];
    if (self.isRunning) {
        self.isRunning = NO;
    }
    if (self.failuredSignInRecourds && self.failuredSignInRecourds.count > 0) {
        [self.failuredSignInRecourds removeAllObjects];
    }
    else if (!self.failuredSignInRecourds) {
        self.failuredSignInRecourds = [NSMutableArray new];
    }
    if (self.uploadTaskArray && self.uploadTaskArray.count > 0) {
        for (KDPhotoUploadTask *photoUpLoadTask in self.uploadTaskArray) {
            photoUpLoadTask.taskDelegate = nil;
            
        }
        [self.uploadTaskArray removeAllObjects];
    } else if (!self.uploadTaskArray) {
        self.uploadTaskArray = [NSMutableArray new];
    }
}


- (void)startSignInWithRecord:(KDSignInRecord *)record atIndex:(NSInteger)index {
    __weak KDFailureSignInTask *task = self;
    if (!task.isRunning) {
        return;
    }
    if (record.status != -1)
        return;
    
    if ([record.clockInType isEqualToString:@"manual"])//手动
    {
        //内勤 自定义
        if (record.manualType == KDSignInManualType_custom || record.manualType == KDSignInManualType_neiQin) {
            [task signinToServerWithRecord:record block:^(BOOL success, KDSignInRecord *record1) {
                if (success && record1) {
                    task.uploadSuccessCount++;
                    [task judgeShowNotifactionView];
                    //签到成功
                    record.status = 1;
                    [task saveRecordWhenSignInSuccess:record1 removedRecord:record];
                } else {
                    task.uploadFailurdCount++;
                    [task judgeShowNotifactionView];
                }
            }];
            
        } else if (record.manualType == KDSignInManualType_waiQin) {
            //外勤图片上传
            if (record.cachesUrl && record.cachesUrl.length > 0 && (!record.photoIds || record.photoIds.length == 0 || [record.photoIds isEqualToString:@""]) && ![task isCacheImageDleteAllWithCacheUrl:record.cachesUrl]) {
                KDPhotoUploadTask *uploadTask = [[KDPhotoUploadTask alloc] init];
                uploadTask.failuredIndex = index;
                uploadTask.taskDelegate = self;
                if (!task.uploadTaskArray) {
                    task.uploadTaskArray = [NSMutableArray new];
                }
                [task.uploadTaskArray addObject:uploadTask];
                [uploadTask startUploadActionWithCachePathArray:[[record.cachesUrl componentsSeparatedByString:@","] copy]];
            }
            else {
                [task reSigninToServerWithSignInRecord:record block:^(BOOL success, KDSignInRecord *record1) {
                    if (success && record1) {
                        task.uploadSuccessCount++;
                        [task judgeShowNotifactionView];
                        //签到成功
                        record.status = 1;
                        [task saveRecordWhenSignInSuccess:record1 removedRecord:record];
                    } else {
                        task.uploadFailurdCount++;
                        [task judgeShowNotifactionView];
                    }
                }];
            }
        }
    } else if ([record.clockInType isEqualToString:@"photo"])//拍照
    {
        if (record.cachesUrl && record.cachesUrl.length > 0) {
            if ([task isCacheImageDleteAllWithCacheUrl:record.cachesUrl]) {
                task.uploadFailurdCount++;
                [task judgeShowNotifactionView];
                return;
            }
            //上传图片＋调用签到接口
            KDPhotoUploadTask *uploadTask = [[KDPhotoUploadTask alloc] init];
            uploadTask.failuredIndex = index;
            uploadTask.taskDelegate = self;
            if (!task.uploadTaskArray) {
                task.uploadTaskArray = [NSMutableArray new];
            }
            [task.uploadTaskArray addObject:uploadTask];
            [uploadTask startUploadActionWithCachePathArray:[[record.cachesUrl componentsSeparatedByString:@","] copy]];
        } else {
            //直接调用接口
            [task signinToServerPhotoSignInWithRecord:record block:^(BOOL success, KDSignInRecord *record1) {
                if (success && record1) {
                    task.uploadSuccessCount++;
                    [task judgeShowNotifactionView];
                    if (!record1.featurename || record1.featurename.length == 0) {
                        record1.featurename = record.featurename;
                    }
                    [task saveRecordWhenSignInSuccess:record1 removedRecord:record];
                } else {
                    task.uploadFailurdCount++;
                    [task judgeShowNotifactionView];
                }
            }];
        }
    }
}


- (BOOL)isCacheImageDleteAllWithCacheUrl:(NSString *)cacheUrl {
    NSArray *cacheArray = [cacheUrl componentsSeparatedByString:@","];
    NSInteger deletedImageCount = 0;
    for (NSString *cacheStr in cacheArray) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:cacheStr];
        if (!data) {
            deletedImageCount++;
        }
    }
    if (deletedImageCount == cacheArray.count) {
        return YES;
    }
    return NO;
}

/**
 *  签到的方法
 * 自定义签到   内勤签到
 *  @param address 自定义签到的地址名（如果为nil，则是正常签到，否则为自定义签到）
 *  @param block
 *
 */
- (void)signinToServerWithRecord:(KDSignInRecord *)signInRecord block:(void (^)(BOOL success, KDSignInRecord *record))block {
    __weak KDFailureSignInTask *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if (results) {
            BOOL success = [[results objectForKey:@"success"] boolValue];
            NSArray *signs = [results objectForKey:@"singIns"];
            if (success && [signs count] > 0) {
                KDSignInRecord *record = (KDSignInRecord *) [signs lastObject];
                if (KD_IS_BLANK_STR(record.featurename)) {
                    record.featurename = [BOSSetting sharedSetting].customerName;
                }
                if (block) {
                    block(success, record);
                }
            }
            else {
                if (block) {
                    block(NO, nil);
                }
            }
        } else {
            if (block) {
                block(NO, nil);
            }
        }
    };
    
    
    KDQuery *query = [KDQuery query];
    [query setProperty:signInRecord forKey:@"signin"];
    if (signInRecord.featurenamedetail && signInRecord.featurenamedetail.length > 0) {
        [signInRecord setProperty:signInRecord.featurenamedetail forKey:@"featurenamedetail"];
    }
    if (signInRecord.manualType == KDSignInManualType_custom) {
        if (signInRecord.message) {
            [query setParameter:@"address" stringValue:signInRecord.message];
        }
    }
    [query setParameter:@"clockInTime" longLongValue:[signInRecord.singinTime timeIntervalSince1970] * 1000];
    [query setParameter:@"deviceInfo" stringValue:[KDSignInUtil getSignInDeviceInfo]];
    
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:sign"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
}


/**
 *  首次定位不合法，重新定位请求
 *  外勤签到失败
 *  @param block
 */
- (void)reSigninToServerWithSignInRecord:(KDSignInRecord *)signInRecord block:(void (^)(BOOL success, KDSignInRecord *record))block {
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response) {
        if (results) {
            BOOL success = [[results objectForKey:@"success"] boolValue];
            NSArray *signs = [results objectForKey:@"singIns"];
            if ([signs count] > 0) {
                KDSignInRecord *record = (KDSignInRecord *) [signs lastObject];
                
                if (block) {
                    block(success, record);
                }
            } else {
                if (block) {
                    block(NO, nil);
                }
            }
        } else {
            if (block) {
                block(NO, nil);
            }
        }
    };
    
    if (signInRecord.featurenamedetail && signInRecord.featurenamedetail.length > 0) {
        [signInRecord setProperty:signInRecord.featurenamedetail forKey:@"featurenamedetail"];
    }
    
    KDQuery *query = [KDQuery query];
    
    [query setProperty:signInRecord forKey:@"signin"];
    [query setParameter:@"org_latitude" doubleValue:signInRecord.org_latitude];
    [query setParameter:@"org_longitude" doubleValue:signInRecord.org_longitude];
    if (signInRecord.address && signInRecord.address.length > 0) {
        [query setParameter:@"remark" stringValue:[signInRecord.message copy]];
        
    }
    
    if (signInRecord.photoIds && signInRecord.photoIds.length > 0) {
        [query setParameter:@"photoId" stringValue:signInRecord.photoIds];
    }
    [query setParameter:@"clockInTime" longLongValue:[signInRecord.singinTime timeIntervalSince1970] * 1000];
    [query setParameter:@"deviceInfo" stringValue:[KDSignInUtil getSignInDeviceInfo]];
    
    [KDServiceActionInvoker invokeWithSender:self actionPath:@"/signId/:resign" query:query
                                 configBlock:nil completionBlock:completionBlock];
}

- (void)signinToServerPhotoSignInWithRecord:(KDSignInRecord *)record block:(void (^)(BOOL success, KDSignInRecord *record))block {
    
    __weak KDFailureSignInTask *weakSelf = self;
    KDServiceActionDidCompleteBlock completionBlock = ^(id results, KDRequestWrapper *request, KDResponseWrapper *response){
        if (results) {
            KDSignInRecord *serverRecord = ((NSArray *)([results objectForKey:@"singIns"])).firstObject;
            if (serverRecord) {
                if (safeString(serverRecord.featurename).length == 0) {
                    serverRecord.featurename = record.featurename;
                }
                if (block) { block(YES, serverRecord); }
            }
            else {
                if (block) { block(NO, nil); }
            }
        } else {
            if (block)
                block(NO, nil);
        }
    };
    
    KDQuery *query = [KDQuery query];
    [query setParameter:@"clockInType" stringValue:@"photo"];
    [query setParameter:@"remark" stringValue:(record.featurename?record.featurename:@"")];
    [query setParameter:@"photoId" stringValue:record.photoIds];
    [query setParameter:@"inCompany" integerValue:record.inCompany];
    
    [query setParameter:@"longitude" doubleValue:record.longitude];
    [query setParameter:@"latitude" doubleValue:record.latitude];
    [query setParameter:@"featurename" stringValue:record.featurename];
    if(record.status == -1)
        [query setParameter:@"clockInTime" longLongValue:[record.singinTime timeIntervalSince1970] * 1000];
    
    
    [KDServiceActionInvoker invokeWithSender:weakSelf
                                  actionPath:@"/signId/:sign"
                                       query:query
                                 configBlock:nil
                             completionBlock:completionBlock];
}

/**
 *  将打卡记录保存至数据库
 *
 *  @param records
 */

- (void)saveRecords:(NSArray *)records date:(NSDate *)date reload:(BOOL)reload completionBlock:(void (^)(id results))block removeRecord:(KDSignInRecord *)removedRecord {
    if (!date) {
        date = [NSDate date];
    }
    __block id results = nil;
    [KDDatabaseHelper asyncInDatabase:(id) ^(FMDatabase *fmdb) {
        id <KDSigninRecordDAO> signinDAO = [[KDWeiboDAOManager globalWeiboDAOManager] signinDAO];
        [signinDAO removeRecordWithId:removedRecord.singinId database:fmdb];
        [signinDAO saveRecords:records withDate:date database:fmdb rollback:NULL];
        if (reload) {
            results = [signinDAO queryRecordsWithLimit:NSUIntegerMax withDate:date database:fmdb];
        }
        return results;
    }                 completionBlock:block];
    
}

- (void)saveRecordWhenSignInSuccess:(KDSignInRecord *)record removedRecord:(KDSignInRecord *)removedRecord {
    
    [self saveRecords:@[record]
                 date:nil
               reload:NO
      completionBlock:^(id results) {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"KDAUTOWifiSignInSuccessNotification" object:nil];
      } removeRecord:removedRecord];
}

- (void)judgeShowNotifactionView {
    if (self.failuredSignInRecourds && (self.uploadFailurdCount + self.uploadSuccessCount >= self.failuredSignInRecourds.count && self.uploadSuccessCount > 0)) {
        self.isRunning = NO;
        [KDPopup showHUDToast:ASLocalizedString(@"签到数据上传成功")];
    }
}

#pragma mark - KDPhotoUploadTaskDelegate

- (void)whenPhotoUploadTaskFailure:(NSDictionary *)dict task:(KDPhotoUploadTask *)task {
    task.taskDelegate = nil;
}

- (void)whenPhotoUploadTaskSuccess:(NSDictionary *)dict task:(KDPhotoUploadTask *)task {
    task.taskDelegate = nil;
    [self photoUploadTaskWithDict:dict];
}

- (void)photoUploadTaskWithDict:(NSDictionary *)dict {
    if (dict && dict[@"failuredIndex"]) {
        NSInteger failuredIndex = [dict[@"failuredIndex"] integerValue];
        
        if (self.failuredSignInRecourds && self.failuredSignInRecourds.count > failuredIndex) {
            KDSignInRecord *record = [self.failuredSignInRecourds objectAtIndex:failuredIndex];
            if (![record.clockInType isEqualToString:@"photo"] && (![record.clockInType isEqualToString:@"manual"])) {
                self.uploadFailurdCount++;
                [self judgeShowNotifactionView];
                return;
            }
            NSMutableArray *filesArray = dict[@"fileIds"];
            if (filesArray && filesArray.count > 0) {
                NSString *fileidStr = @"";
                for (int i = 0; i < filesArray.count; i++) {
                    NSString *fileid = filesArray[i];
                    if (i > 0 && i < filesArray.count) {
                        fileidStr = [NSString stringWithFormat:@"%@,%@", fileidStr, fileid];
                    } else if (i == 0) {
                        fileidStr = [NSString stringWithFormat:@"%@", fileid];
                    }
                }
                record.photoIds = fileidStr;
                
                
                if ([record.clockInType isEqualToString:@"photo"]) {
                    [self signinToServerPhotoSignInWithRecord:record block:^(BOOL success, KDSignInRecord *record1) {
                        if (success && record1) {
                            self.uploadSuccessCount++;
                            [self judgeShowNotifactionView];
                            record.status = 1;
                            if (!record1.featurename || record1.featurename.length == 0) {
                                record1.featurename = record.featurename;
                            }
                            [self saveRecordWhenSignInSuccess:record1 removedRecord:record];
                        } else {
                            self.uploadFailurdCount++;
                            [self judgeShowNotifactionView];
                        }
                    }];
                } else if ([record.clockInType isEqualToString:@"manual"]) {
                    [self reSigninToServerWithSignInRecord:record block:^(BOOL success, KDSignInRecord *record1) {
                        if (success && record1) {
                            self.uploadSuccessCount++;
                            [self judgeShowNotifactionView];
                            //签到成功
                            record.status = 1;
                            [self saveRecordWhenSignInSuccess:record1 removedRecord:record];
                        } else {
                            self.uploadFailurdCount++;
                            [self judgeShowNotifactionView];
                        }
                    }];
                }
            } else {
                if ([record.clockInType isEqualToString:@"manual"] && record.manualType == KDSignInManualType_waiQin) {
                    [self reSigninToServerWithSignInRecord:record block:^(BOOL success, KDSignInRecord *record1) {
                        if (success && record1) {
                            self.uploadSuccessCount++;
                            [self judgeShowNotifactionView];
                            //签到成功
                            record.status = 1;
                            [self saveRecordWhenSignInSuccess:record1 removedRecord:record];
                        } else {
                            self.uploadFailurdCount++;
                            [self judgeShowNotifactionView];
                        }
                    }];
                }
            }
        }
    }
}


- (void)taskDidEnterBackground {
    self.isRunning = NO;
    self.uploadFailurdCount = 0;
    self.uploadSuccessCount = 0;
    if (self.failuredSignInRecourds && self.failuredSignInRecourds.count > 0) {
        [self.failuredSignInRecourds removeAllObjects];
    }
    else if (!self.failuredSignInRecourds) {
        self.failuredSignInRecourds = [NSMutableArray new];
    }
    if (self.uploadTaskArray && self.uploadTaskArray.count > 0) {
        for (KDPhotoUploadTask *uploadTask in self.uploadTaskArray) {
            uploadTask.taskDelegate = nil;
        }
        [self.uploadTaskArray removeAllObjects];
    }
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    NSDictionary* dict = notification.userInfo;
    KDReachabilityStatus status = [dict[KDReachabilityStatusKey] integerValue];
    __weak KDFailureSignInTask *task = self;
    if(status == KDReachabilityStatusNotReachable || status == KDReachabilityStatusUnknown)
    {
        if (task.isRunning) {
            task.isRunning = NO;
        }
        if (task.failuredSignInRecourds && task.failuredSignInRecourds.count > 0) {
            [task.failuredSignInRecourds removeAllObjects];
        }
        if (task.uploadTaskArray && task.uploadTaskArray.count > 0) {
            for (KDPhotoUploadTask *photoUpLoadTask in task.uploadTaskArray) {
                photoUpLoadTask.taskDelegate = nil;
            }
            [task.uploadTaskArray removeAllObjects];
        }
    }else{
        [self uploadFailedRecord];
    }
}

- (void)uploadFailedRecord {
    __weak KDFailureSignInTask *task = self;
    
    if (task.isRunning) {
        return;
    } else {
        task.isRunning = YES;
    }
    task.uploadFailurdCount = 0;
    task.uploadSuccessCount = 0;
    if (task.failuredSignInRecourds && task.failuredSignInRecourds.count > 0) {
        [task.failuredSignInRecourds removeAllObjects];
    }
    else if (!task.failuredSignInRecourds) {
        task.failuredSignInRecourds = [NSMutableArray new];
    }
    if (task.uploadTaskArray && task.uploadTaskArray.count > 0) {
        for (KDPhotoUploadTask *uploadTask in task.uploadTaskArray) {
            uploadTask.taskDelegate = nil;
        }
        [task.uploadTaskArray removeAllObjects];
    } else if (!task.uploadTaskArray) {
        task.uploadTaskArray = [NSMutableArray new];
    }
    
    [KDDatabaseHelper asyncInDatabase:(id) ^(FMDatabase *fmdb) {
        id <KDSigninRecordDAO> signinDAO = [[KDWeiboDAOManager globalWeiboDAOManager] signinDAO];
        [task.failuredSignInRecourds addObjectsFromArray:[signinDAO queryFailuredSignInRecordsWithLimit:NSUIntegerMax withDate:[NSDate date] database:fmdb]];
        
        if (task.failuredSignInRecourds && task.failuredSignInRecourds.count > 0) {
            task.isRunning = YES;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_t group = dispatch_group_create();
            for (NSInteger index = 0; index < task.failuredSignInRecourds.count; index++) {
                KDSignInRecord *record = [task.failuredSignInRecourds objectAtIndex:index];
                dispatch_group_async(group, queue, ^{
                    [task startSignInWithRecord:record atIndex:index];
                });
            }
        } else {
            task.isRunning = NO;
        }
        return nil;
    } completionBlock:nil];
}

@end
