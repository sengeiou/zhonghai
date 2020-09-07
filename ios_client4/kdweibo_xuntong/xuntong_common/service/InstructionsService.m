//
//  InstructionsService.m
//  Public
//
//  Created by Gil on 12-5-9.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "InstructionsService.h"
#import "BOSLogger.h"
#import "MCloudClient.h"
#import "InstructionsDataModel.h"
#import "BOSFileManager.h"
#import "BOSConfig.h"

@interface InstructionsService (Private)
-(void)startInstructions:(InstructionsDataModel *)instructionsDM;
-(void)startLogoutInstruction:(NSString *)desc;
-(void)finishLogoutInstruction:(NSString *)desc;
-(void)startDataEraseInstruction:(NSString *)desc;
-(void)finishDataEraseInstruction:(NSString *)desc;
-(void)startMessageTipInstruction:(NSString *)desc;
-(void)finishMessageTipInstruction:(NSString *)desc;
-(void)messageAlertInstruction:(NSString *)desc;
-(void)finishInstructions;

-(void)deleteAllFiles;
@end

@implementation InstructionsService
@synthesize delegate = _delegate_;

- (void)dealloc
{
    //BOSRELEASE_clientCloud_);
    //[super dealloc];
}

-(void)run
{
    BOSSetting *setting = [BOSSetting sharedSetting];
    if (setting.cust3gNo.length == 0 || setting.userName.length == 0) {
        return;
    }
    
    if (_clientCloud_ == nil) {
        _clientCloud_ = [[MCloudClient alloc] initWithTarget:self action:@selector(instructionsDidReceived:result:)];
    }
    [_clientCloud_ instructionsWithCust3gNo:setting.cust3gNo userName:setting.userName];
}

-(void)instructionsDidReceived:(MCloudClient *)client result:(BOSResultDataModel *)result
{
    if (client.hasError){
        return;
    }
    if (![result isKindOfClass:[BOSResultDataModel class]]) {
        return;
    }
    if (!result.success || result.data == nil) {
        return;
    }

    InstructionsDataModel *instructionsDM = [[InstructionsDataModel alloc] initWithDictionary:result.data] ;//autorelease];
    if ([instructionsDM.instructions count] <= 0) {
        return;
    }
    [self start:instructionsDM];
}

-(void)start:(InstructionsDataModel *)instructionsDM
{
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsDidStart:)]) {
        [_delegate_ instructionsDidStart:instructionsDM.desc];
        [self startInstructions:instructionsDM];
    }
}

-(void)startInstructions:(InstructionsDataModel *)instructionsDM
{
    BOSINFO(@"%@,%@",@"startInstructions",[NSDate date]);
    NSTimeInterval time = 0;
    for (InstructionsCodeDataModel *instruction in instructionsDM.instructions) {
        switch (instruction.code) {
            case InstructionsLogout:
                time += ShortTimeInterval;
                [self performSelector:@selector(startLogoutInstruction:) withObject:instruction.desc afterDelay:time];
                time += LongTimeInterval;
                [self performSelector:@selector(finishLogoutInstruction:) withObject:instruction.desc afterDelay:time];
                break;
            case InstructionsDataErase:
                [self deleteAllFiles];
                time += ShortTimeInterval;
                [self performSelector:@selector(startDataEraseInstruction:) withObject:instruction.desc afterDelay:time];
                time += LongTimeInterval;
                [self performSelector:@selector(finishDataEraseInstruction:) withObject:instruction.desc afterDelay:time];
                break;
            case InstructionsMessageTip:
            {
                NSString *msg = [instruction.extra objectForKey:@"msg"];
                if ([msg isKindOfClass:[NSNull class]] || msg == nil) {
                    msg = instruction.desc;
                }
                int type = 2;
                id typeValue = [instruction.extra objectForKey:@"type"];
                if (![typeValue isKindOfClass:[NSNull class]] && typeValue != nil) {
                    type = [typeValue intValue];
                }
                if (type == 1) {//alert
                    time += ShortTimeInterval;
                    [self performSelector:@selector(messageAlertInstruction:) withObject:msg afterDelay:time];
                } else {
                    time += ShortTimeInterval;
                    [self performSelector:@selector(startMessageTipInstruction:) withObject:msg afterDelay:time];
                    time += LongTimeInterval;
                    [self performSelector:@selector(finishMessageTipInstruction:) withObject:msg afterDelay:time];
                }
                break;
            }
            default:
                break;
        }
    }
    time += ShortTimeInterval;
    [self performSelector:@selector(finishInstructions) withObject:nil afterDelay:time];
}

-(void)startLogoutInstruction:(NSString *)desc
{
    BOSINFO(@"%@,%@",@"startLogoutInstruction",[NSDate date]);
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsDidStartLogout:)]) {
        [_delegate_ instructionsDidStartLogout:desc];
    }
}

-(void)finishLogoutInstruction:(NSString *)desc
{
    BOSINFO(@"%@,%@",@"finishLogoutInstruction",[NSDate date]);
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsDidFinishLogout:)]) {
        [_delegate_ instructionsDidFinishLogout:desc];
    }
}

-(void)startDataEraseInstruction:(NSString *)desc
{
    BOSINFO(@"%@,%@",@"startDataEraseInstruction",[NSDate date]);
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsDidStartDataErase:)]) {
        [_delegate_ instructionsDidStartDataErase:desc];
    }
}

-(void)finishDataEraseInstruction:(NSString *)desc
{
    BOSINFO(@"%@,%@",@"finishDataEraseInstruction",[NSDate date]);
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsDidFinishDataErase:)]) {
        [_delegate_ instructionsDidFinishDataErase:desc];
    }
}

-(void)startMessageTipInstruction:(NSString *)desc
{
    BOSINFO(@"%@,%@",@"startMessageTipInstruction",[NSDate date]);
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsDidStartMessageTip:)]) {
        [_delegate_ instructionsDidStartMessageTip:desc];
    }
}

-(void)finishMessageTipInstruction:(NSString *)desc
{
    BOSINFO(@"%@,%@",@"finishMessageTipInstruction",[NSDate date]);
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsDidFinishMessageTip:)]) {
        [_delegate_ instructionsDidFinishMessageTip:desc];
    }
}

-(void)messageAlertInstruction:(NSString *)desc
{
    BOSINFO(@"%@,%@",@"messageAlertInstruction",[NSDate date]);
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsMessageAlert:)]) {
        [_delegate_ instructionsMessageAlert:desc];
    }
}

-(void)finishInstructions
{
    BOSINFO(@"%@,%@",@"finishInstructions",[NSDate date]);
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(instructionsDidFinish)]) {
        [_delegate_ instructionsDidFinish];
    }
}

-(void)deleteAllFiles
{
    //删除应用下的所有文件
    BOSINFO(@"delete all files");
    [BOSFileManager deleteAllFilesAtDocumentsDirectory];
    [[BOSSetting sharedSetting] clearSetting];
    [[BOSConfig sharedConfig] clearConfig];
}

@end
