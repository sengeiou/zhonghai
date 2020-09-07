//
//  InstructionsService.h
//  Public
//
//  Created by Gil on 12-5-9.
//  Edited by Gil on 2012.09.12
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCloudDelegate.h"

#define ShortTimeInterval 0.5
#define LongTimeInterval 1.0

@class MCloudClient;
@class InstructionsDataModel;
@interface InstructionsService : NSObject{
    MCloudClient *_clientCloud_;
//    id<InstructionsDelegate> _delegate_;
}

//操作指令代理
@property (nonatomic,assign) id<InstructionsDelegate> delegate;

/*
 @desc 运行指令服务
 @return void;
 */
-(void)run;

/*
 @desc 开始指令
 @param instructionsDM; -- 需要执行的指令
 @return void;
 */
-(void)start:(InstructionsDataModel *)instructionsDM;

@end
