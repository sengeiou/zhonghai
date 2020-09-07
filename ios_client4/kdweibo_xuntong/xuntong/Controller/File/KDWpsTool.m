//
//  KDWpsTool.m
//  kdweibo
//
//  Created by fang.jiaxin on 15/5/19.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDWpsTool.h"
#import "BOSSetting.h"
#import <CommonCrypto/CommonCryptor.h>

static KDWpsTool *_instance;
static NSString *AESKey;
static NSString *EncryptHeader;
@implementation KDWpsTool


+(KDWpsTool *)shareInstance
{
    if(!_instance)
        _instance = [[KDWpsTool alloc] init];
    return _instance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        AESKey = [NSString stringWithFormat:@"%@%@",bundleId,@"_fangjiaxin"];
        EncryptHeader = [[NSString stringWithFormat:@"%@%@",bundleId,@"_KDWPSHEADER"] MD5DigestKey];
    }
    return self;
}

-(NSString *)fileCachePath
{
    if(self.filePath == nil)
        return nil;
    
    //后缀
    NSString *ext = [self.filePath pathExtension];
    
    //临时路径
    NSString *tempPath = [ContactUtils fileTempFilePath];
    
    NSString *fileCachePath = [NSString stringWithFormat:@"%@/%@.%@",tempPath,[[self.filePath stringByAppendingFormat:@"_%@",@"kdFile"] MD5DigestKey],ext];
    
    return fileCachePath;
}


-(BOOL)removeTempFile
{
    //临时路径
    NSString *tempPath = [ContactUtils fileTempFilePath];
    return [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
}

-(void)callBack:(KDWpsCompletionBlock)complectionBlock withResult:(BOOL)success andData:(NSData *)data andPath:(NSString *)path
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(complectionBlock)
            complectionBlock(success,data,path);
    });
}

-(void)encryptFile:(NSString *)filePath complectionBlock:(KDWpsCompletionBlock)complectionBlock
{
    self.filePath = filePath;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:filePath])
        {
            [self callBack:complectionBlock withResult:NO andData:nil andPath:filePath];
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if(!data)
        {
            [self callBack:complectionBlock withResult:NO andData:nil andPath:filePath];
            return;
        }
        
        //开始加密
        NSData *resultData = [self encryptData:data];
        if(![resultData isEqualToData:data])
            [resultData writeToFile:filePath atomically:YES];
        [self callBack:complectionBlock withResult:YES andData:resultData andPath:filePath];
    });
}

-(NSData *)encryptData:(NSData *)data
{
    NSData *headerData = [EncryptHeader dataUsingEncoding:NSASCIIStringEncoding];
    NSRange searchRange = NSMakeRange(0, data.length);
    NSRange resultRange = [data rangeOfData:headerData options:NSDataSearchAnchored range:searchRange];
    //假如加密过，直接返回原数据
    if(resultRange.location == 0)
        return data;
    
    //AES加密
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [AESKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
        //添加加密文件头
        NSMutableData *encryptData = [[NSMutableData alloc] initWithData:headerData];
        [encryptData appendBytes:buffer length:numBytesEncrypted];
        return encryptData;
    }
    free(buffer);
    return nil;
}


-(void)decryptFile:(NSString *)filePath complectionBlock:(KDWpsCompletionBlock)complectionBlock
{
    self.filePath = filePath;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:filePath])
        {
            [self callBack:complectionBlock withResult:NO andData:nil andPath:filePath];
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if(!data)
        {
            [self callBack:complectionBlock withResult:NO andData:nil andPath:filePath];
            return;
        }
        
        NSData *resultData = [self decryptData:data];
        //写到加密后的文件，原加密文件不动
        if(![resultData isEqualToData:data])
        {
            [resultData writeToFile:self.fileCachePath atomically:YES];
            [self callBack:complectionBlock withResult:YES andData:resultData andPath:self.fileCachePath];
        }
        else
        {
            [self callBack:complectionBlock withResult:YES andData:resultData andPath:filePath];
        }
    });
}

//移除明文文件
-(BOOL)removeCacheFile:(NSString *)filePath
{
    self.filePath = filePath;
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm removeItemAtPath:self.fileCachePath error:nil];
}

-(NSData *)decryptData:(NSData *)data
{
    NSData *headerData = [EncryptHeader dataUsingEncoding:NSASCIIStringEncoding];
    NSRange searchRange = NSMakeRange(0, data.length);
    NSRange resultRange = [data rangeOfData:headerData options:NSDataSearchAnchored range:searchRange];
    //未加密过，直接返回原数据
    if(resultRange.location != 0)
        return data;
    
    //移除加密文件头
    NSMutableData *encryptData = [NSMutableData dataWithData:data];
    data = [encryptData subdataWithRange:NSMakeRange(headerData.length, encryptData.length-headerData.length)];
    
    //AES解密
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [AESKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess)
    {
        NSData *resultData = [NSMutableData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        return resultData;
    }
    free(buffer);
    return nil;
}

-(BOOL)openWPSWithFile:(NSString *)filePath
{
    #if !(TARGET_IPHONE_SIMULATOR)
    if(![KWOfficeApi isAppstoreWPSInstalled] && ![KWOfficeApi isEnterpriseWPSInstalled])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"本地没有安装WPS，是否去下载WPS？")delegate:self cancelButtonTitle:ASLocalizedString(@"不了")otherButtonTitles:ASLocalizedString(@"下载WPS"), nil];
        alertView.tag = 0x101;
        [alertView show];
        
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
        return NO;
    
    NSString *allowEdit = [NSString stringWithFormat:@"%d",![[BOSSetting sharedSetting] isWPSControlOpen]];
    NSString *allowShare =[NSString stringWithFormat:@"%d",![[BOSSetting sharedSetting] isWPSControlOpen]];
    NSString *allowSave = [NSString stringWithFormat:@"%d",![[BOSSetting sharedSetting] isWPSControlOpen]];
//    NSString *allowCopy = [NSString stringWithFormat:@"%d",[[BOSSetting sharedSetting]isWPSControlOpen]];
//    NSString *unEncrypt = [NSString stringWithFormat:@"%d",![[BOSSetting sharedSetting]isWPSControlOpen]];

    //先解密文件
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    data = [self decryptData:data];
    if(!data || data.length == 0)
    {
        //文件数据错误，移除文件
        [fileManager removeItemAtPath:filePath error:nil];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"打开的文件数据错误,请重新下载文件!")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];

        return NO;
    }
    
    NSError *error = nil;
    BOOL isOk = [[KWOfficeApi sharedInstance] sendFileData:data
                                              withFileName:self.fileName
                                                  callback:@"kdwps"
                                                  delegate:self
                                                    policy:@{
                                                             @"public.shell.backup":
                                                                 @"0",
                                                             @"wps.document.openInEditMode":
                                                                 allowEdit,
                                                             @"wps.document.editMode":
                                                                 allowEdit,
                                                             @"wps.document.toollist.share":
                                                                 allowShare,
                                                             @"wps.document.toollist.exportPDF":
                                                                 allowShare,
                                                             @"wps.document.toollist.sendMail":
                                                                 allowShare,
                                                             @"wps.document.toollist.print":
                                                                 allowShare,
                                                             @"wps.document.saveAs":
                                                                 allowSave,
                                                             @"wps.document.localization":
                                                                 @"0",
                                                             @"wps.shell.editmode.toolbar.mark":
                                                                 @"1",
                                                             @"wps.shell.editmode.toolbar.markEnable":
                                                                 @"0",
                                                             @"wps.shell.editmode.toolbar.revision":
                                                                 @"0",
                                                             @"wps.shell.editmode.toolbar.revisionEnable":
                                                                 @"1",
                                                             @"wps.shell.readmode.toolbar.revision":
                                                                 @"0",
                                                             
                                                             @"ppt.document.saveAs":
                                                                 allowSave,
                                                             @"ppt.document.localization":
                                                                 @"0",
                                                             @"ppt.document.toollist.sendMail":
                                                                 allowShare,
                                                             @"ppt.document.toollist.print":
                                                                 allowShare,
                                                             @"ppt.document.toollist.exportPDF":
                                                                 allowShare,
                                                             @"ppt.document.toollist.share":
                                                                 allowShare,
                                                             @"ppt.document.editMode":
                                                                 allowEdit,
                                                             
                                                             @"et.document.toollist.sendMail":
                                                                 allowShare,
                                                             @"et.document.toollist.share":
                                                                 allowShare,
                                                             @"et.document.localization":
                                                                 @"0",
                                                             @"et.document.saveAs":
                                                                 allowSave,
                                                             @"et.document.editMode":
                                                                 allowEdit,
                                                             
                                                             @"pdf.document.shareAndSendMail":
                                                                 allowShare,
                                                             @"pdf.document.saveAs":
                                                                 allowSave,
                                                             @"pdf.document.print":
                                                                 allowShare,
                                                             @"pdf.document.editEnable":
                                                                 allowEdit,
                                                             @"pdf.document.copyEnable":
                                                                 allowEdit
                                                             }
                                                     error:&error];
    if (isOk)
    {
        NSLog(ASLocalizedString(@"进入wps app"));
    }
    else
    {
        NSLog(ASLocalizedString(@"进入wps app 失败 %@"), error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"打开文件错误,请稍候重试!")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
        [alertView show];
    }
    
    return isOk;
    #endif
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:ASLocalizedString(@"模拟器不支持打开WPS")delegate:self cancelButtonTitle:ASLocalizedString(@"Global_Sure")otherButtonTitles:nil];
    [alertView show];
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 0x101)
    {
        if(buttonIndex == 1)
        {
            //去下载
            #if !(TARGET_IPHONE_SIMULATOR)
            [KWOfficeApi goDownloadWPS];
            #endif
        }
    }
}


#pragma mark - KWOfficeApi delegate
//wps回传文件数据
-(void)KWOfficeApiDidReceiveData:(NSDictionary *)dict
{
    //解析file数据
    NSData *fileData = [dict objectForKey:@"Body"];
    self.data = fileData;
    
    
    //将file data 写入本地
//    NSString *strDocPath = [[NSString alloc] initWithString:[self getDocPath]];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error;
//    [fileManager createDirectoryAtPath:strDocPath withIntermediateDirectories:NO attributes:nil error:&error];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyyMMddhhmmss"];
//    NSString *strTime = [formatter stringFromDate:[NSDate date]];
//    
//    NSString *keyContent = [dict objectForKey:@"FileType"];
//    NSString *fileType = [NSString stringWithFormat:@".%@",keyContent];
//    
//    NSString *strName = [strTime stringByAppendingString:fileType];
//    [self writeFile:[strDocPath stringByAppendingPathComponent:strName] writeData:fileData];
//    
//    //存储文件路径
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@",strDocPath,strName];
//    [[NSUserDefaults standardUserDefaults] setObject:filePath forKey:@"KWFilePath"];
}

//wps编辑完成返回 结束与WPS链接
- (void)KWOfficeApiDidFinished
{
    NSLog(ASLocalizedString(@"=====> wps编辑完成返回 结束与WPS链接"));
//    if([[BOSSetting sharedSetting] isWPSControlOpen])
//    {
//        NSData *encryptData = [self encryptData:self.data];
//        if(encryptData)
//           [encryptData writeToFile:self.filePath atomically:YES];
//    }
//    else
//        [self.data writeToFile:self.filePath atomically:YES];
}

//wps退出后台
- (void)KWOfficeApiDidAbort
{
    NSLog(ASLocalizedString(@"wps编辑结束，并退出后台"));
}

//断开链接
- (void)KWOfficeApiDidCloseWithError:(NSError*)error
{
    NSLog(ASLocalizedString(@"=====> 错误 与 wps 断开链接 %@"),error);
    self.data = nil;
}

-(void)dealloc
{
    NSLog(@"dealloc");
}
@end
