//
//  KDExpressionCodeXiaoYun.m
//  kdweibo
//
//  Created by Darren Zheng on 7/10/16.
//  Copyright © 2016 www.kingdee.com. All rights reserved.
//

#import "KDExpressionCodeXiaoYun.h"
#import "KDPlistHelper.h"

static NSDictionary *exps = nil;
static NSArray *values = nil;
static NSArray *fileIds = nil;
static NSArray *codeStrs = nil;

@implementation KDExpressionCodeXiaoYun

+ (void)setExps {
    @synchronized(self)
    {
        if (exps == nil) {
            exps = [[NSDictionary alloc] initWithObjects:[self allValues] forKeys:[self allCodeString]];
        }
    }
}

+ (NSArray *)plist {
    return [KDPlistHelper arrayWithPlistName:@"emotion_xiaoyun"];
}

+ (NSArray *)allValues {
    @synchronized(self)
    {
        if (!values) {
            NSMutableArray *mArray = [NSMutableArray new];
            for (NSDictionary *dict in [self plist]) {
                [mArray addObject: [dict objectForKey:@"fileName"]];
            }
            values = mArray;
        }
    }
    
    return values;
}

+ (NSArray *)allCodeString {
    @synchronized(self)
    {
        if (!codeStrs) {
            NSMutableArray *mArray = [NSMutableArray new];
            for (NSDictionary *dict in [self plist]) {
                [mArray addObject: [dict objectForKey:@"fileName"]];
            }
            codeStrs = mArray;
        }
    }
    
    return codeStrs;
}

+ (NSArray *)allFileIds {
    @synchronized(self)
    {
        if (!fileIds) {
            NSMutableArray *mArray = [NSMutableArray new];
            for (NSDictionary *dict in [self plist]) {
                [mArray addObject: [dict objectForKey:@"fileId"]];
            }
            fileIds = mArray;
        }
    }
    
    return fileIds;
}

+ (NSString *)fileIdOfExpressionCode:(NSString *)code {
    NSInteger index = [[self allCodeString] indexOfObject:code];
    
    return [[self allFileIds] objectAtIndex:index];
}

+ (NSString *)fileNameOfExpressionCode:(NSString *)code {
    NSInteger index = [[self allCodeString] indexOfObject:code];
    
    return [[self allValues] objectAtIndex:index];
}

+ (NSString *)fileNameOfFileId:(NSString *)fileId {
    NSInteger index = -1;
    
    if ([[self allFileIds] containsObject:fileId]) {
        index = [[self allFileIds] indexOfObject:fileId];
    }
    NSString *strResult = nil;
    
    if (index != -1) {
        strResult = [[self allValues] objectAtIndex:index];
    }
    return strResult;
}

+ (NSString *)codeStringToImageName:(NSString *)codeStr {
    [self setExps];
    
    return [exps objectForKey:codeStr];
}

+ (NSString *)imageNameToCodeString:(NSString *)imageName {
    [self setExps];
    
    for (NSString *key in exps.allKeys) {
        if ([[exps objectForKey:key] isEqualToString:imageName]) {
            return key;
        }
    }
    
    return nil;
}

@end
