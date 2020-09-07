//
//  KDUserDefaults.h
//  kdweibo
//
//  Created by DarrenZheng on 15/1/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDUserDefaultsKeys.h"

/* 
 
【说明】
 
 这个模型的好处是将NSObject整体存入NSUserDefaults
 适用于要缓存一些数据，但不想建SQL的情况。
 这些数据往往不需要复杂的Query，也不是表结构，只是几个变量。
 
 实现采用NSUserDefaults来存储NSData，
 这个Data来自于NSKeyedArchiver转换的符合NSCoding的NSObject。
 
 save过程：
 NSObject<NSCoding> -> NSKeyedArchiver -> NSData -> NSUserDefaults
 
 load过程：
 NSUserDafaults -> NSData -> NSKeyedUnarchiver -> NSObject<NSCoding>
 
 ----------------------------【新增】-----------------------------
 1、先建立Modal类，并NSCoding化
 2、实例化Modal，赋值，存库
 KDModalTimelineAdvert *modal = self.modalTimelineAdvert;
 modal.strDetailUrl = @"xxx";
 modal.strPicUrl = @"xxx";
 modal.iTime = @"xxx";
 modal.strVersion = @"xxx";
 [KD_USER_DEFAULTS saveObject:modal forKey:kModalTimelineAdvert];
 
 ----------------------------【查询】----------------------------
 一般在所在类建立一个属性
 @property (nonatomic, retain) KDModalTimelineAdvert *modalTimelineAdvert;
 
 并重写Getter
 - (KDModalTimelineAdvert *)modalTimelineAdvert
 {
    return [KD_USER_DEFAULTS loadObjectForKey:kModalTimelineAdvert];
 }
 
 这有别与“懒加载”，原因是要及时更新数据。
 
 ----------------------------【更新】----------------------------
 存的时候要注意，如果是更新某些字段，要把实例先取出来，用临时变量做更改，然后把临时变量【整体存入】。
 如下：
 KDModalTimelineAdvert *modal = self.modalTimelineAdvert;
 modal.strDetailUrl = @"xxx";
 modal.strPicUrl = nil;
 modal.iTime = nil;
 [KD_USER_DEFAULTS saveObject:modal forKey:kModalTimelineAdvert];
 
 ----------------------------【删除】----------------------------
 全部删除
 [KD_USER_DEFAULTS removeObjectForKey: kModalTimelineAdvert];
 
 删除Modal的某些字段同更新
 
 */

#define KD_USER_DEFAULTS [KDUserDefaults sharedInstance]

@interface KDUserDefaults : NSObject

+ (KDUserDefaults *)sharedInstance;

// 一次性消费
- (void)runOnceWithFlag:(NSString *)flag logic:(void (^)())logic;
// 分段消费
- (void)consumeFlag:(NSString *)flag;
// 消费了吗
- (BOOL)isFlagConsumed:(NSString *)flag;

- (void)saveObject:(id)obj forKey:(NSString *)strKey;
- (id)loadObjectForKey:(NSString *)strKey;
- (void)removeObjectForKey:(NSString *)strKey;

@end
