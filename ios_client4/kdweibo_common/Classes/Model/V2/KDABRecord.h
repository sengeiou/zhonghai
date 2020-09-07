//
//  KDABRecord.h
//  kdweibo
//
//  Created by shen kuikui on 13-10-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    KDABRecordState_Default = 0,
    KDABRecordState_Joined,
    KDABRecordState_Actived,
    KDABRecordState_Unactived,
    KDABRecordState_Peding,
}KDABRecordState;

@interface KDABRecord : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, assign) KDABRecordState state;

@end
