//
//  KDLockControl.m
//  SaleProcess
//
//  Created by 曾昭英 on 12-10-13.
//  Copyright (c) 2012年 Achievo. All rights reserved.
//

#import "KDLockControl.h"

@implementation KDLockControl
@synthesize lockPassword = _lockPassword;
@synthesize isSetDone = _isSetDone;
@synthesize stopTime = _stopTime;
@synthesize hasBeenUsed =  _hasBeenUsed;
+ (KDLockControl *)shared
{
    static KDLockControl *KDLockControl_P = nil;
    @synchronized(self)
    {
        if (KDLockControl_P == nil) {
            KDLockControl_P = [[self alloc] init];
            KDLockControl_P.stopTime = -1;
        }
    }
    return KDLockControl_P;
}

- (void)setLockPassword:(NSString *)lockPassword
{
    _lockPassword = lockPassword;
    [[NSUserDefaults standardUserDefaults] setObject:lockPassword forKey:kLockPW];
}

- (NSString *)lockPassword
{
    if (_lockPassword == nil) {
        _lockPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kLockPW];
    }
    return _lockPassword;
}

- (void)setIsSetDone:(BOOL)isSetDone
{
    _isSetDone = isSetDone;
    [[NSUserDefaults standardUserDefaults] setObject:@(isSetDone) forKey:kIsSetDone];
}

- (BOOL)isSetDone
{
    _isSetDone = [[[NSUserDefaults standardUserDefaults] objectForKey:kIsSetDone] boolValue];
    return _isSetDone;
}
-(void)setHasBeenUsed:(BOOL)hasBeenUsed{
    _hasBeenUsed = hasBeenUsed;
    [[NSUserDefaults standardUserDefaults] setObject:@(_hasBeenUsed) forKey:kHasBeenUsed];
}
-(BOOL)hasBeenUsed{
    _hasBeenUsed = [[[NSUserDefaults standardUserDefaults] objectForKey:kHasBeenUsed] boolValue];
    return _hasBeenUsed;
}


-(void)setStopTime:(double)stopTime{
    _stopTime = stopTime;
    [[NSUserDefaults standardUserDefaults] setObject:@(_stopTime) forKey:kStopTime];
    
}

-(double)stopTime{
    if (_stopTime < 0 ) {
         _stopTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kStopTime] doubleValue];
    }
    return _stopTime;
}

@end
