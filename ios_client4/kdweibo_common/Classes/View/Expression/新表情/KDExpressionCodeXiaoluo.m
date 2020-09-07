//
//  KDExpressionCodeXiaoluo.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-28.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDExpressionCodeXiaoluo.h"

static NSDictionary *exps = nil;
static NSArray *values = nil;
static NSArray *fileIds = nil;
static NSArray *codeStrs = nil;

@implementation KDExpressionCodeXiaoluo

+ (void)setExps {
    @synchronized(self)
    {
        if (exps == nil) {
            exps = [[NSDictionary alloc] initWithObjects:[self allValues]  forKeys:[self allCodeString]];
        }
    }
}

+ (NSArray *)allValues {
    @synchronized(self)
    {
        if (!values) {
            
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion_xiaoluo" ofType:@"plist"];
            NSArray *emoticonArray = [NSArray arrayWithContentsOfFile:plistPath];
            NSMutableArray *valuesArray = [NSMutableArray array];
            for (NSDictionary *valueDic in emoticonArray) {
                [valuesArray addObject:[valueDic objectForKey:@"fileName"]];
            }
            
            values = [NSArray arrayWithArray:valuesArray];
//            values = [NSArray arrayWithObjects:
//                      @"xiaoluo_hi",
//                      @"xiaoluo_paomeiyan",
//                      @"xiaoluo_niupigu",
//                      @"xiaoluo_feiwen",
//                      @"xiaoluo_maimeng",
//                      @"xiaoluo_se",
//                      @"xiaoluo_xianhua",
//                      @"xiaoluo_baosanwei",
//                      @"xiaoluo_fangbianpao",
//                      @"xiaoluo_fazhaopian",
//                      @"xiaoluo_huanying",
//                      @"xiaoluo_laladui",
//                      @"xiaoluo_paishou",
//                      @"xiaoluo_sahua",
//                      @"xiaoluo_woshou",
//                      @"xiaoluo_baobao",
//                      nil];
        }
    }
    
    return values;
}

+ (NSArray *)allCodeString {
    @synchronized(self)
    {
        if (!codeStrs) {
            
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion_xiaoluo" ofType:@"plist"];
            NSArray *emoticonArray = [NSArray arrayWithContentsOfFile:plistPath];
            NSMutableArray *valuesArray = [NSMutableArray array];
            for (NSDictionary *valueDic in emoticonArray) {
                [valuesArray addObject:[valueDic objectForKey:@"name"]];
            }
            
            codeStrs = [NSArray arrayWithArray:valuesArray];
            
//            codeStrs = [NSArray arrayWithObjects:
//                        @"打招呼",
//                        @"你好棒",
//                        @"扭屁股",
//                        @"谢谢",
//                        @"期待",
//                        @"羡慕",
//                        @"鲜花",
//                        @"报三围",
//                        @"庆祝",
//                        @"发图片",
//                        @"欢迎",
//                        @"加油",
//                        @"拍手",
//                        @"开心",
//                        @"握手",
//                        @"求抱抱",
//                        nil];
        }
    }
    
    return codeStrs;
}

+ (NSArray *)allFileIds {
    @synchronized(self)
    {
        if (!fileIds) {
            
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion_xiaoluo" ofType:@"plist"];
            NSArray *emoticonArray = [NSArray arrayWithContentsOfFile:plistPath];
            NSMutableArray *valuesArray = [NSMutableArray array];
            for (NSDictionary *valueDic in emoticonArray) {
                [valuesArray addObject:[valueDic objectForKey:@"fileId"]];
            }
            
            fileIds = [NSArray arrayWithArray:valuesArray];
            
//            fileIds = [NSArray arrayWithObjects:
//                       @"53faa7b224ac5a01da0304ed",
//                       @"53faaa9624ac5a01da030fc8",
//                       @"53faaa9624ac5a01da030fc4",
//                       @"53faa7b224ac5a01da0304ef",
//                       @"53faaa9624ac5a01da030fc2",
//                       @"53faaa9624ac5a01da030fce",
//                       @"53faaa9724ac5a01da030fd0",
//                       @"53faa7b224ac5a01da0304e9",
//                       @"53faa7b224ac5a01da0304e7",
//                       @"53faa7b224ac5a01da0304e5",
//                       @"53faa7b224ac5a01da0304eb",
//                       @"53faa7b224ac5a01da0304f1",
//                       @"53faaa9624ac5a01da030fc6",
//                       @"53faaa9624ac5a01da030fcc",
//                       @"53faaa9624ac5a01da030fca",
//                       @"53faa7b224ac5a01da0304e3",
//                       nil];
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
