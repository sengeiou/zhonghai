//
//  EMPLoginDelegate.h
//  Public
//
//  Created by Gil on 12-5-7.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 登录过程相关代理
 */

@class BOSResultDataModel;
@class InstructionsDataModel;

@protocol EMPLoginDelegate <NSObject>

/*
 @desc 认证成功后回调,下载企业的Logo文件;
 @return void;
 */
@optional
-(void)customerLogoDownloadAfterAuthFinished;

/*
 @desc 得到指令错误时回调,执行相应指令;
 @param instructionsDM; -- 得到的相应指令
 @return void;
 */
@optional
-(void)instructionsWhenDeviceStateError:(InstructionsDataModel *)instructionsDM;

/*
 @desc 登录成功后回调;
 @param result; -- 登录接口的返回值，可能为nil
 @return void;
 */
@required
-(void)loginFinished:(BOSResultDataModel *)result;

/*
 @desc 登录失败后回调;since 3.0
 @param result; -- 登录接口的返回值，可能为nil
 @return void;
 */
@optional
-(void)loginFailed:(BOSResultDataModel *)result;

/*
 @desc 使用不同的登录方式,回调,目前可用来做统计分析;since 3.0
 */
-(void)loginWithAuto;//自动登录
-(void)loginWithLoginButton;//手动登录
-(void)loginWithDemoButton;//点击演示按钮登录

/*
 @desc 登录按钮按下时回调。如果未实现此方法，则按正常的认证逻辑运行;since 3.0
 @return void;
 */
-(void)loginButtonDidPressed;

/*
 @desc 登录成功，但是用户改变了帐号，用来通知客户端删除缓存数据;since 3.0
 @return void;
 */
- (void)loginByChangeAccount;

@end
