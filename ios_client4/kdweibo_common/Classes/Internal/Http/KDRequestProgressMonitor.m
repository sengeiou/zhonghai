//
//  KDRequestProgressMonitor.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-5-14.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDRequestProgressMonitor.h"

#import "NSString+Additions.h"

@implementation KDRequestProgressMonitor

@synthesize name=name_;
@synthesize source=source_;

@synthesize maxBytes=maxBytes_;
@dynamic currentBytes;

@synthesize startTime=startTime_;
@synthesize endTime=endTime_;
@synthesize lastNotifyTime=lastNotifyTime_;

@dynamic speed;

- (id) init {
    self = [super init];
    if(self){
        name_ = nil;
        source_ = nil;
        
        maxBytes_ = NSURLResponseUnknownLength;
        currentBytes_ = 0;
        bytesForLiveSpeedLastTime_ = 0;
        
        startTime_ = [[NSDate date] timeIntervalSince1970];
        endTime_ = 0.0;
        lastUpdateSpeedTime_ = 0.0;
        lastNotifyTime_ = 0.0;
        
        speed_ = nil;
    }
    
    return self;
}

- (id) initWithName:(NSString *)name source:(NSString *)source maxBytes:(KDUInt64)maxBytes {
    self = [self init];
    if(self){
        name_ = name;// retain];
        source_ = source;// retain];
        maxBytes_ = maxBytes;
    }
    
    return self;
}

- (void) setCurrentBytes:(KDInt64)currentBytes {
    // The ASI http request calculate the body size as content length
    if(currentBytes > maxBytes_) return;
    
    currentBytes_ = currentBytes;
}

- (KDInt64) currentBytes {
    return currentBytes_;
}


// this method will call at did receive response from server
- (void) requestWillStart {
    // update request start time
    startTime_ = [[NSDate date] timeIntervalSince1970];
}

- (BOOL) isUnknownResponseLength {
    // If there is not exists "Content-Length" field in response headers.
    return NSURLResponseUnknownLength == maxBytes_;
}

- (float) finishedPercent {
    if([self isUnknownResponseLength]){
        return 0.0;
    }
    
    // the boundary in [0.0, 1.0], example 50% map to 0.5
    
    return (currentBytes_ + 0.0f) / (maxBytes_ + 0.0f);
}

- (NSString *) finishedPercentAsString {
    if([self isUnknownResponseLength]){
        return NSLocalizedString(@"UNKNOWN_CONTENT_LENGTH", @"");
    }
    
    // format like: 50%
    float percent = [self finishedPercent];
    return [NSString stringWithFormat:@"%0.0f%%", percent * 100];
}

// calculate the live speed in per 2 seconds.
static const NSTimeInterval kKDMinimalLiveSpeedIntervalInSeconds = 2.0;

- (NSString *) speed {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timeDiff = now - lastUpdateSpeedTime_;
    
    if(timeDiff + 0.01 > kKDMinimalLiveSpeedIntervalInSeconds || bytesForLiveSpeedLastTime_ == 0){
        // this issue just happens on first calcaulate the live speed
        if(bytesForLiveSpeedLastTime_ == 0){
            timeDiff = now - startTime_; // adjust time diff value
        }
        
        lastUpdateSpeedTime_ = now;
        
        KDInt64 bytesDiff = currentBytes_ - bytesForLiveSpeedLastTime_;
        bytesForLiveSpeedLastTime_ = currentBytes_;
        
        KDUInt64 bytesInUnitTimes = (KDUInt64)((bytesDiff + 0.0) / timeDiff);
        NSString *speedInfo = [NSString formatContentLengthWithBytes:bytesInUnitTimes];
        
//        if(speed_ != nil)
//            [speed_ release];
        
        // format like: 50.00 KB/s
        speed_ = [[NSString alloc] initWithFormat:@"%@/s", speedInfo];
    }
    
    if(speed_ == nil){
        return @"0.0 KB/s";
    }
    
    return speed_;
}

- (NSString *) finishedBytesAsString {
    return [NSString formatContentLengthWithBytes:currentBytes_];
}

- (NSString *)finishedByteToMaxByteAsString {
    return [NSString stringWithFormat:@"%@/%@",[self finishedBytesAsString],
            [NSString formatContentLengthWithBytes:maxBytes_]];
}

- (void) dealloc {
    //KD_RELEASE_SAFELY(name_);
    //KD_RELEASE_SAFELY(source_);
    
    //KD_RELEASE_SAFELY(speed_);
    
    //[super dealloc];
}

@end

