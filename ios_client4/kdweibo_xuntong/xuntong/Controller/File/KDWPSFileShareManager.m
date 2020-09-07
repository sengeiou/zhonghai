//
//  KDWPSFileShareManager.m
//  kdweibo
//
//  Created by lichao_liu on 10/22/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import "KDWPSFileShareManager.h"
#import "KDAgoraSDKManager.h"
#import "BOSConfig.h"
#import "KDAppOpen.h"

#if!(TARGET_IPHONE_SIMULATOR)

#import "KWOfficeApi.h"

#endif
static NSString *const KDWPSServerHost = @"cloudservice6.kingsoft-office-service.com:8082";

@interface KDWPSFileShareManager()

@end
@implementation KDWPSFileShareManager

+ (instancetype)sharedInstance
{
    static KDWPSFileShareManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KDWPSFileShareManager alloc] init];
     });
    return sharedInstance;
}

- (void)startSharePlay:(NSData *)data
          withFileName:(NSString *)fileName

{
    NSData *fileData = [[KDWpsTool shareInstance] decryptData:data];
    
    self.accessCode = nil;
    self.serverHost = nil;
    self.originatorPersonId = nil;
//    [KDEventAnalysis event:event_fileshare_open];
	[self commonFunctionWithBlock:^{
		NSError *error = nil;
#if!(TARGET_IPHONE_SIMULATOR)
        
        [[KWOfficeApi sharedInstance] startSharePlay:fileData
                                        withFileName:fileName
                                          serverHost:KDWPSServerHost
                                            callback:@"KDWeibostartFileShare"
                                            delegate:[KDWeiboAppDelegate getAppDelegate]
                                               error:&error];
#endif
		
	}];
}

- (void)joinWpsSharePlay
{
    if (![KDAppOpen isWPSInstalled]) {
        [KDAppOpen openWPSIntro:nil];
        return;
    }

  [self commonFunctionWithBlock:^{
      NSError *error = nil;
#if!(TARGET_IPHONE_SIMULATOR)
      
      BOOL isOk = [[KWOfficeApi sharedInstance] joinSharePlay:self.accessCode
                                                   serverHost:KDWPSServerHost
                                                     callback:@"KDWeibojoinFileShare"
                                                     delegate:[UIApplication sharedApplication].delegate
                                                        error:&error];
      if (!isOk) {
          dispatch_async(dispatch_get_main_queue(), ^{
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"共享播放开启失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
              [alert show];
          });
      }

#endif
      
    }];
}

- (void)setAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost
{
    self.accessCode = accessCode;
    self.serverHost = serverHost;
    if(!self.accessCode)
    {
        self.originatorPersonId = nil;
    }else{
        KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        if(agoraSDKManager.currentGroupDataModel)
        {
            self.originatorPersonId = agoraSDKManager.currentGroupDataModel.isExternalGroup ? [BOSConfig sharedConfig].user.externalPersonId : [BOSConfig sharedConfig].user.userId;
        }else
        {
        self.originatorPersonId = [BOSConfig sharedConfig].user.userId;
        }
    }
    if(self.accessCode && self.accessCode.length>0)
    {
        KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
        [agoraSDKManager sendShareFileChannelMessageWithAccessCode:self.accessCode serverHost:serverHost];
    }
}

- (void)commonFunctionWithBlock:(ShareManagerBlock)block
{
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    if([agoraSDKManager isAgoraTalkIng])
    {
        if(block)
        {
            block();
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"请开启语音会议"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)joinWpsSharePlayFailured
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"加入文件共享失败"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    [alert show];
}

- (BOOL)isExitFileShareWithAccessCode:(NSString *)accessCode serverHost:(NSString *)serverHost
{
    if(self.accessCode && self.accessCode.length>0){
        if(accessCode && accessCode.length>0)
        {
            if([accessCode isEqualToString:self.accessCode])
            {
                self.serverHost = nil;
                self.accessCode = nil;
                self.originatorPersonId = nil;
                return YES;
            }
        }
    }
    return  NO;
}
@end
