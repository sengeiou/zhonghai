//
//  KDExpressionCodeYuki.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-28.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDExpressionCodeYuki.h"

static NSDictionary *exps = nil;
static NSArray *values = nil;
static NSArray *fileIds = nil;
static NSArray *codeStrs = nil;

@implementation KDExpressionCodeYuki

+ (void)setExps {
    @synchronized(self)
    {
        if (exps == nil) {
            exps = [[NSDictionary alloc] initWithObjects:[self allValues] forKeys:[self allCodeString]];
        }
    }
}

+ (NSArray *)allValues {
    @synchronized(self)
    {
        if (!values) {
            
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion_yuki" ofType:@"plist"];
            NSArray *emoticonArray = [NSArray arrayWithContentsOfFile:plistPath];
            NSMutableArray *valuesArray = [NSMutableArray array];
            for (NSDictionary *valueDic in emoticonArray) {
                [valuesArray addObject:[valueDic objectForKey:@"fileName"]];
            }
            
            values = [NSArray arrayWithArray:valuesArray];// retain];
            
//            values = [[NSArray arrayWithObjects:
//                       @"yuki_dazhaohu",
//                       @"yuki_jingxia",
//                       @"yuki_duibuqi",
//                       @"yuki_shengqi",
//                       @"yuki_bukaixin",
//                       @"yuki_daku",
//                       @"yuki_haobang",
//                       @"yuki_wuyu",
//                       @"yuki_baituoma",
//                       @"yuki_xiuse",
//                       @"yuki_memeda",
//                       @"yuki_daxiao",
//                       @"yuki_yihuo",
//                       @"yuki_fankun",
//                       @"yuki_qingzhu",
//                       @"yuki_haochi",
//                       nil] retain];
        }
    }
    
    return values;
}

+ (NSArray *)allCodeString {
    @synchronized(self)
    {
        if (!codeStrs) {
            
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion_yuki" ofType:@"plist"];
            NSArray *emoticonArray = [NSArray arrayWithContentsOfFile:plistPath];
            NSMutableArray *valuesArray = [NSMutableArray array];
            for (NSDictionary *valueDic in emoticonArray) {
                [valuesArray addObject:[valueDic objectForKey:@"name"]];
            }
            
            codeStrs = [NSArray arrayWithArray:valuesArray] ;//retain];
            
//            codeStrs = [[NSArray arrayWithObjects:
//                         ASLocalizedString(@"打招呼"),
//                         ASLocalizedString(@"惊吓"),
//                         ASLocalizedString(@"对不起"),
//                         ASLocalizedString(@"生气"),
//                         ASLocalizedString(@"不开心"),
//                         ASLocalizedString(@"大哭"),
//                         ASLocalizedString(@"好棒"),
//                         ASLocalizedString(@"无语"),
//                         ASLocalizedString(@"拜托嘛"),
//                         ASLocalizedString(@"羞涩"),
//                         ASLocalizedString(@"么么哒"),
//                         ASLocalizedString(@"大笑"),
//                         ASLocalizedString(@"疑惑"),
//                         ASLocalizedString(@"犯困"),
//                         ASLocalizedString(@"庆祝"),
//                         ASLocalizedString(@"好吃"),
//                         nil] retain];
        }
    }
    
    return codeStrs;
}

+ (NSArray *)allFileIds {
    @synchronized(self)
    {
        if (!fileIds) {
            
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion_yuki" ofType:@"plist"];
            NSArray *emoticonArray = [NSArray arrayWithContentsOfFile:plistPath];
            NSMutableArray *valuesArray = [NSMutableArray array];
            for (NSDictionary *valueDic in emoticonArray) {
                [valuesArray addObject:[valueDic objectForKey:@"fileId"]];
            }
            
            fileIds = [NSArray arrayWithArray:valuesArray];// retain];
            
//            fileIds = [[NSArray arrayWithObjects:
//                        @"55b5ab9824acee5607dc8c5d",
//                        @"55b5abb524acee5607dc9460",
//                        @"55b5ab9824acee5607dc8c57",
//                        @"55b5abb524acee5607dc9474",
//                        @"55b5ab9824acee5607dc8c51",
//                        @"55b5ab9824acee5607dc8c63",
//                        @"55b5ab9924acee5607dc8ca5",
//                        @"55b5abb524acee5607dc946a",
//                        @"55b5ab9824acee5607dc8c4b",
//                        @"55b5abb524acee5607dc94c1",
//                        @"55b5abb524acee5607dc9456",
//                        @"55b5ab9824acee5607dc8c69",
//                        @"55b5abb524acee5607dc94d7",
//                        @"55b5ab9924acee5607dc8cab",
//                        @"55b5abb524acee5607dc9488",
//                        @"55b5abb524acee5607dc945e",
//                        nil] retain];
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
