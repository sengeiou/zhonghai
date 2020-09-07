//
//  KDExpressionCodeSola.m
//  kdweibo
//
//  Created by DarrenZheng on 14-7-28.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDExpressionCodeSola.h"

static NSDictionary *exps = nil;

@implementation KDExpressionCodeSola

+ (void)setExps {
    @synchronized(self) {
        if(exps == nil) {
            NSArray *values = [NSArray arrayWithObjects:
                               @"sola_hello.png",
                               @"sola_kaixin.png",
                               @"sola_nanguo.png",
                               @"sola_jingya.png",
                               @"sola_shengqi.png",
                               @"sola_bye.png",
                               @"sola_go.png",
                               @"sola_yiwen.png",
                               @"sola_bingbai.png",
                               @"sola_haixiu.png",
                               @"sola_jiayou.png",
                               @"sola_kun.png",
                               @"sola_tiaopi.png",
                               @"sola_wanan.png",
                               @"sola_wuliao.png",
                               @"sola_xiangwang.png",
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
                         @"Hello",
                         ASLocalizedString(@"开心"),
                         ASLocalizedString(@"难过"),
                         ASLocalizedString(@"惊讶"),
                         ASLocalizedString(@"生气"),
                         @"Bye",
                         @"Go",
                         ASLocalizedString(@"疑问"),
                         ASLocalizedString(@"明白"),
                         ASLocalizedString(@"害羞"),
                         ASLocalizedString(@"加油"),
                         ASLocalizedString(@"困"),
                         ASLocalizedString(@"调皮"),
                         ASLocalizedString(@"晚安"),
                         ASLocalizedString(@"无聊"),
                         ASLocalizedString(@"向往"),
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

