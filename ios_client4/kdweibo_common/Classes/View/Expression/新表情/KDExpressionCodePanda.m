//
//  KDExpressionCodePanda.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-28.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDExpressionCodePanda.h"

static NSDictionary *exps = nil;

@implementation KDExpressionCodePanda

+ (void)setExps {
    @synchronized(self) {
        if(exps == nil) {
            NSArray *values = [NSArray arrayWithObjects:
                               @"fant_dazhaohu.png",
                               @"fant_kaixin.png",
                               @"fant_nanguo.png",
                               @"fant_shuijiao.png",
                               @"fant_songhua.png",
                               @"fant_xiangshou.png",
                               @"fant_shiluo.png",
                               @"fant_shengqi.png",
                               @"fant_baogao.png",
                               @"fant_gongzuo.png",
                               @"fant_huahua.png",
                               @"fant_jihua.png",
                               @"fant_qingzhu.png",
                               @"fant_wuliao.png",
                               @"fant_yihuo.png",
                               @"fant_zhaopian.png",
                                nil];
            exps = [[NSDictionary alloc] initWithObjects:values forKeys:[self allCodeString]];
        }
    }
}

+ (NSArray *)allCodeString {
    static NSArray *codeStrs = nil;
    
    @synchronized(self) {
        if(!codeStrs) {
            codeStrs = [NSArray arrayWithObjects:
                         @"Hi",
                         ASLocalizedString(@"好开心"),
                         ASLocalizedString(@"好难过"),
                         ASLocalizedString(@"休息咯"),
                         ASLocalizedString(@"很赞哦"),
                         ASLocalizedString(@"好轻松"),
                         ASLocalizedString(@"无语了"),
                         ASLocalizedString(@"抓狂啊"),
                         ASLocalizedString(@"作报告"),
                         ASLocalizedString(@"好忙啊"),
                         ASLocalizedString(@"创作中"),
                         ASLocalizedString(@"做计划"),
                         ASLocalizedString(@"庆祝去"),
                         ASLocalizedString(@"打酱油"),
                         ASLocalizedString(@"不明白"),
                         ASLocalizedString(@"求照片"),
                         nil] ;//retain];
        }
    }
    
    return codeStrs;
}

+ (NSString *)codeStringToImageName:(NSString *)codeStr {
    [self setExps];
    
    return [exps objectForKey:codeStr];
}

+ (NSString *)imageNameToCodeString:(NSString *)imageName {
    [self setExps];
    
    for(NSString *key in exps.allKeys) {
        if([[exps objectForKey:key] isEqualToString:imageName])
            return key;
    }
    
    return nil;
}

@end
