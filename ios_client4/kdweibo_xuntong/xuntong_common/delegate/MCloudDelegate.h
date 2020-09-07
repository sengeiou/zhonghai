//
//  CustomerSearchDelegate.h
//  Public
//
//  Created by Gil on 12-5-7.
//  Edited by Gil on 2012.09.11
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

/*
 云平台相关协议
 */


//企业搜索协议
@protocol CustomerSearchDelegate <NSObject>
/*
 @desc 选择了一个企业后回调;
 @param cust3gNo; -- 企业3g号
 @param customerName; -- 企业名称
 @return void;
 */
-(void)didSelectedCustomer:(NSString *)cust3gNo name:(NSString *)customerName;
@end

//隐私签署协议
@protocol SignTOSDelegate <NSObject>
/*
 @desc 是否签署协议;
 @param success; -- 标示是否同意客户端协议
 @return void;
 */
-(void)signedTOS:(BOOL)success;
@end

//指令接口协议
@protocol InstructionsDelegate <NSObject>
@optional
/*
 @desc 指令队列开始;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsDidStart:(NSString *)desc;

/*
 @desc 注销指令开始;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsDidStartLogout:(NSString *)desc;

/*
 @desc 注销指令结束;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsDidFinishLogout:(NSString *)desc;

/*
 @desc 数据擦除指令开始;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsDidStartDataErase:(NSString *)desc;

/*
 @desc 数据擦除指令结束;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsDidFinishDataErase:(NSString *)desc;

/*
 @desc 消息提示指令开始;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsDidStartMessageTip:(NSString *)desc;

/*
 @desc 消息提示指令结束;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsDidFinishMessageTip:(NSString *)desc;
/*
 @desc 消息提示指令,使用弹出框;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsMessageAlert:(NSString *)desc;

/*
 @desc 指令队列结束;
 @param desc; -- 描述语，用于界面显示
 @return void;
 */
-(void)instructionsDidFinish;
@end
