//
//  KDUserDefaults.m
//  kdweibo
//
//  Created by DarrenZheng on 15/1/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

@implementation KDUserDefaults

+ (KDUserDefaults *)sharedInstance {
    static KDUserDefaults *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KDUserDefaults alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)runOnceWithFlag:(NSString *)flag logic:(void (^)())logic {
    if (flag.length == 0) {
        return;
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:flag]) {
        logic();
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:flag];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)consumeFlag:(NSString *)flag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:flag];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isFlagConsumed:(NSString *)flag {
    if (flag.length == 0) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:flag];
}

// object -> data -> user default
- (void)saveObject:(id)obj forKey:(NSString *)strKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [defaults setObject:data forKey:strKey];
    [defaults synchronize];
}

// user default -> data -> object
- (id)loadObjectForKey:(NSString *)strKey; {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults dataForKey:strKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)removeObjectForKey:(NSString *)strKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:strKey];
}

@end
