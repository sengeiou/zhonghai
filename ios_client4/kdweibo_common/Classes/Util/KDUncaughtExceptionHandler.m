//
//  KDUncaughtExceptionHandler.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-19.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#include <execinfo.h>

#import "KDUncaughtExceptionHandler.h"
#import "KDUtility.h"

#import "NSDate+Additions.h"


NSString * const kUncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const kUncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const kUncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

// more details? please see http://cocoawithlove.com/2010/05/handling-unhandled-exceptions-and.html

@implementation KDUncaughtExceptionHandler

- (id) init {
    self = [super init];
    if(self){
        
    }
    
    return self;
}

+ (NSArray *) backtrace {
    void *callback[128];
    int frames = backtrace(callback, 128);
    char **strs = backtrace_symbols(callback, frames);
    
    int i = 0;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for(; i<frames; i++){
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);
    strs = NULL;
    
    return backtrace;
}

- (void) handleException:(NSException *)exception {
    // write exception to logging file
    NSArray *callstack = [[exception userInfo] objectForKey:kUncaughtExceptionHandlerAddressesKey];
    NSMutableString *message = [NSMutableString stringWithFormat:@"name:%@  reason:%@", [exception name], [exception reason]];
    for(NSString *item in callstack){
        [message appendFormat:@"\r\n%@", item];
    }
    
    NSString *filename = [[NSDate date] formatWithFormatter:KD_DATE_ISO_8601_LONG_NUMERIC_FORMATTER];
    filename = [filename stringByAppendingString:@".txt"];
    
    NSString *path = [[KDUtility defaultUtility] searchDirectory:KDUserLogsDirectory inDomainMask:KDTemporaryDomainMask needCreate:YES];
    path = [path stringByAppendingPathComponent:filename];
    
    [message writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
    
    if([kUncaughtExceptionHandlerSignalExceptionName isEqualToString:[exception name]]){
        kill(getpid(), [[[exception userInfo] objectForKey:kUncaughtExceptionHandlerSignalKey] intValue]);
    }else {
        [exception raise];
    }
}

- (void) dealloc {
    
    //[super dealloc];
}


@end

void KDHandleException(NSException *exception) {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    NSArray *callstack = [KDUncaughtExceptionHandler backtrace];
    [userInfo setObject:callstack forKey:kUncaughtExceptionHandlerAddressesKey];
    
    KDUncaughtExceptionHandler *exceptionHandler = [[KDUncaughtExceptionHandler alloc] init];
    [exceptionHandler handleException:[NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo]];
//    [exceptionHandler release];
}

void KDSignalHandler(int signal) {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:kUncaughtExceptionHandlerSignalKey];
    
    NSArray *callstack = [KDUncaughtExceptionHandler backtrace];
    [userInfo setObject:callstack forKey:kUncaughtExceptionHandlerAddressesKey];
    
    NSString *reason = [NSString stringWithFormat:@"Received signal %d.", signal];
    NSException *exception = [NSException exceptionWithName:kUncaughtExceptionHandlerSignalExceptionName reason:reason userInfo:userInfo];
    
    KDUncaughtExceptionHandler *exceptionHandler = [[KDUncaughtExceptionHandler alloc] init];
    [exceptionHandler handleException:exception];
//    [exceptionHandler release];
}


void KDInstallUncaughtExceptionHandler() {
    NSSetUncaughtExceptionHandler(&KDHandleException);
    signal(SIGABRT, KDSignalHandler);
	signal(SIGILL, KDSignalHandler);
	signal(SIGSEGV, KDSignalHandler);
	signal(SIGFPE, KDSignalHandler);
	signal(SIGBUS, KDSignalHandler);
	signal(SIGPIPE, KDSignalHandler);
}
