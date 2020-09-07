//
//  KDRequestProgressMonitor.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-14.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KDCommon.h"

@interface KDRequestProgressMonitor : NSObject {
@private
    NSString *name_; // filename
    NSString *source_; // request URL
    
    KDInt64 maxBytes_; // the total content length of current file  
    KDInt64 currentBytes_; // the content length has been uploading/downloading
    KDInt64 bytesForLiveSpeedLastTime_;
    
    NSTimeInterval startTime_; // the start time of transfering
    NSTimeInterval endTime_; // the end time of transfering
    NSTimeInterval lastUpdateSpeedTime_;
    
    NSTimeInterval lastNotifyTime_; // notify the transfering progress to request delegate at last time
    
    NSString *speed_;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *source;

@property (nonatomic, assign) KDInt64 maxBytes;
@property (nonatomic, assign) KDInt64 currentBytes;

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, assign) NSTimeInterval lastNotifyTime;

@property (nonatomic, retain, readonly) NSString *speed;

- (id) initWithName:(NSString *)name source:(NSString *)source maxBytes:(KDUInt64)maxBytes;

- (void) requestWillStart;

- (BOOL) isUnknownResponseLength;
- (float) finishedPercent;
- (NSString *) finishedPercentAsString;
- (NSString *) finishedBytesAsString;
- (NSString * )finishedByteToMaxByteAsString;

@end
