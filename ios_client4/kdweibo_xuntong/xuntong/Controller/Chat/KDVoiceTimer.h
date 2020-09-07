//
//  KDVoiceTimer.h
//  kdweibo
//
//  Created by wenbin_su on 15/7/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDVoiceTimer : NSObject
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) NSUInteger agoraUid;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSMutableArray *personArray;
@property (nonatomic, strong) NSString *lastUpdateTime;



- (void)startTimer;
- (void)cancelTimer;



- (void)join;
- (void)quit;
- (void)postWithUids:(NSMutableArray *)uids;
- (void)postWithPersonids:(NSMutableArray *)personids;
@end
