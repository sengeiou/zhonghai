//
//  CheckVersionService.m
//  Public
//
//  Created by Gil on 12-5-8.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "CheckVersionService.h"
#import "MCloudClient.h"
#import "CheckVersionDataModel.h"

@implementation CheckVersionService
@synthesize updateURL = _updateURL_;
@synthesize newversion = _newversion_;

-(void)run
{
    //判断版本更新
    if (_clientCloud_ == nil) {
        _clientCloud_ = [[MCloudClient alloc] initWithTarget:self action:@selector(checkVersionDidReceived:result:)];
    }
    [_clientCloud_ checkVersion];
}

-(void)checkVersionDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError) {
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (!result.success || result.data == nil) {
        return;
    }
    
    CheckVersionDataModel *checkVersionDM = [[CheckVersionDataModel alloc] initWithDictionary:result.data];// autorelease];
    //不需要更新
    if (checkVersionDM.updateFlag != UpdateNeed) return;
    //找不到更新的版本
    if ([checkVersionDM.newversion isEqualToString:@""]) return;
    
    bool isAlerted = [[NSUserDefaults standardUserDefaults] boolForKey:checkVersionDM.newversion];
    //如果已经提示，则不需要再提示了
    if (isAlerted) return;
    //如果未提示过，则提示用户更新
    self.newversion = [NSString stringWithString:checkVersionDM.newversion];
    UIAlertView *alert = nil;
    if ([checkVersionDM.iosURL isEqualToString:@""]) {//如果不存在url
        alert = [[UIAlertView alloc] initWithTitle:checkVersionDM.message message:checkVersionDM.updateNote delegate:self cancelButtonTitle:ASLocalizedString(@"CheckVersionService_Sure")otherButtonTitles:nil];
    }else{
        self.updateURL = [NSString stringWithString:checkVersionDM.iosURL];
        alert = [[UIAlertView alloc] initWithTitle:checkVersionDM.message message:checkVersionDM.updateNote delegate:self cancelButtonTitle:ASLocalizedString(@"CheckVersionService_Sure")otherButtonTitles:ASLocalizedString(@"CheckVersionService_Update"), nil];
    }
    [alert show];
//    [alert release];
}

-(void)dealloc
{
    //BOSRELEASE_clientCloud_);
    //BOSRELEASE_updateURL_);
    //BOSRELEASE_newversion_);
    //[super dealloc];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateURL]];
    }
    //提示完成后保存标志，保证每个版本只提示一次
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.newversion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
