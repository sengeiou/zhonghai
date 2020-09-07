//
//  KDSignInRemind.h
//  kdweibo
//
//  Created by lichao_liu on 9/8/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KDSignInRemindRepeatType) {
    KDSignInRemindRepeatNone = 0x00,
    KDSignInRemindRepeatSun = 0x01 << 0,
    KDSignInRemindRepeatMon = 0x01 << 1,
    KDSignInRemindRepeatTues = 0x01 << 2,
    KDSignInRemindRepeatWed = 0x01 << 3,
    KDSignInRemindRepeatThur = 0x01 << 4,
    KDSignInRemindRepeatFri = 0x01 << 5,
    KDSignInRemindRepeatSat = 0x01 << 6,
    
    KDSignInRemindRepeatEveryDay = (KDSignInRemindRepeatMon | KDSignInRemindRepeatTues | KDSignInRemindRepeatWed | KDSignInRemindRepeatThur | KDSignInRemindRepeatFri | KDSignInRemindRepeatSat | KDSignInRemindRepeatSun),
    KDSignInRemindRepeatWorkDay = (KDSignInRemindRepeatMon | KDSignInRemindRepeatTues | KDSignInRemindRepeatWed | KDSignInRemindRepeatThur | KDSignInRemindRepeatFri)
};

@interface KDSignInRemind : NSObject

@property (nonatomic, strong) NSString *remindId;
@property (nonatomic, assign) BOOL isRemind;
@property (nonatomic, strong) NSString *remindTime;
@property (nonatomic, assign) KDSignInRemindRepeatType repeatType;

+(NSArray *)parseWithDicArray:(NSArray *)array;
-(KDSignInRemind *)initWithDic:(NSDictionary *)dic;
@end
