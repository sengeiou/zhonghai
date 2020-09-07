//
//  NSDictionary+NULL.m
//  kdweibo
//
//  Created by 王 松 on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "NSDictionary+File.h"

@implementation NSDictionary (File)

-(BOOL)writeToArchivedFile:(NSString*)path
{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
    BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];
    return didWriteSuccessfull;
}

+(instancetype)dictionaryWithArchivedFile:(NSString*)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary * settingData = nil;
    @try {
        settingData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException * e) {
        settingData = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    @finally {
    }
    
    return settingData;
}

@end
