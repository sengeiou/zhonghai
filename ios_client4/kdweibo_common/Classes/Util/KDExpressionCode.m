//
//  KDExpressionCode.m
//  kdweibo_common
//
//  Created by shen kuikui on 13-2-26.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDExpressionCode.h"

static NSDictionary *exps = nil;

@implementation KDExpressionCode

+ (void)setExps {
    @synchronized(self) {
        if(exps == nil) {
            NSArray *values = [NSArray arrayWithObjects:
                               @"smile_hehe@2x.png",
                               @"smile_xixi@2x.png",
                               @"smile_haha@2x.png",
                               @"smile_keai@2x.png",
                               @"smile_aini@2x.png",
                               @"smile_qinqin@2x.png",
                               @"smile_taikaixin@2x.png",
                               @"smile_guzhang@2x.png",
                               @"smile_touxiao@2x.png",
                               @"smile_zuoguilian@2x.png",
                               @"smile_haixiu@2x.png",
                               @"smile_ku@2x.png",
                               @"smile_huaxin@2x.png",
                               @"smile_qian@2x.png",
                               @"smile_fendou@2x.png",
                               @"smile_chijing@2x.png",
                               @"smile_chanzui@2x.png",
                               @"smile_landelini@2x.png",
                               @"smile_sikao@2x.png",
                               @"smile_xu@2x.png",
                               @"status_btn_delete_normal@2x.png",
                               @"smile_yiwen@2x.png",
                               @"smile_han@2x.png",
                               @"smile_kun@2x.png",
                               @"smile_dahaqi@2x.png",
                               @"smile_shuijiao@2x.png",
                               @"smile_heng@2x.png",
                               @"smile_bizui@2x.png",
                               @"smile_bishi@2x.png",
                               @"smile_ding@2x.png",
                               @"smile_weiqu@2x.png",
                               @"smile_wabishi@2x.png",
                               @"smile_shengbing@2x.png",
                               @"smile_yun@2x.png",
                               @"smile_tu@2x.png",
                               @"smile_shiwang@2x.png",
                               @"smile_kelian@2x.png",
                               @"smile_lei@2x.png",
                               @"smile_shuai@2x.png",
                               @"smile_kulutou@2x.png",
                               @"smile_zhuakuang@2x.png",
                               @"status_btn_delete_normal@2x.png",
                               @"smile_numa@2x.png",
                               @"smile_nu@2x.png",
                               @"smile_zuohengheng@2x.png",
                               @"smile_youhengheng@2x.png",
                               @"dog@2x.png",
                               @"smile_good@2x.png",
                               @"smile_ruo@2x.png",
                               @"smile_lai@2x.png",
                               @"smile_ok@2x.png",
                               @"smile_buyao@2x.png",
                               @"smile_ye@2x.png",
                               @"smile_woshou@2x.png",
                               @"smile_ainiyo@2x.png",
                               @"smile_chajin@2x.png",
                               @"smile_baoquan@2x.png",
                               @"smile_quantou@2x.png",
                               @"smile_rose@2x.png",
                               @"smile_diaoxie@2x.png",
                               @"smile_xin@2x.png",
                               @"smile_shangxin@2x.png",
                               @"status_btn_delete_normal@2x.png",
                               @"smile_zhong@2x.png",
                               @"smile_taiyang@2x.png",
                               @"smile_yueliang@2x.png",
                               @"smile_dangao@2x.png",
                               @"smile_liwu@2x.png",
                               @"smile_ganbei@2x.png",
                               @"smile_kafei@2x.png",
                               @"smile_zhutou@2x.png",
                               @"smile_huatong@2x.png",
                               @"smile_lazhu@2x.png",
                               @"smile_shandian@2x.png",
                               @"smile_baobao@2x.png",
                               @"smile_chifan@2x.png",
                               @"smile_zuqiu@2x.png",
                               @"smile_yusan@2x.png",
                               @"smile_bangbangtang@2x.png",
                               @"smile_qiqiu@2x.png",
                               @"smile_shafa@2x.png",
                               @"smile_feiji@2x.png",
                               @"status_btn_delete_normal@2x.png",
                               
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
                        @"[微笑]",
                        @"[嘻嘻]",
                        @"[哈哈]",
                        @"[可爱]",
                        @"[爱你]",
                        @"[亲亲]",
                        @"[太开心]",
                        @"[鼓掌]",
                        @"[偷笑]",
                        @"[做鬼脸]",
                        @"[害羞]",
                        @"[酷]",
                        @"[花心]",
                        @"[钱]",
                        @"[奋斗]",
                        @"[吃惊]",
                        @"[馋嘴]",
                        @"[懒得理你]",
                        @"[思考]",
                        @"[嘘]",
                        @"delete",
                        @"[疑问]",
                        @"[汗]",
                        @"[困]",
                        @"[打哈气]",
                        @"[睡觉]",
                        @"[哼]",
                        @"[闭嘴]",
                        @"[鄙视]",
                        @"[顶]",
                        @"[委屈]",
                        @"[挖鼻屎]",
                        @"[生病]",
                        @"[晕]",
                        @"[吐]",
                        @"[失望]",
                        @"[可怜]",
                        @"[泪]",
                        @"[衰]",
                        @"[骷颅头]",
                        @"[抓狂]",
                        @"delete",
                        @"[怒骂]",
                        @"[怒]",
                        @"[左哼哼]",
                        @"[右哼哼]",
                        @"[doge]",
                        @"[赞]",
                        @"[弱]",
                        @"[来]",
                        @"[ok]",
                        @"[不要]",
                        @"[耶]",
                        @"[握手]",
                        @"[爱你哟]",
                        @"[差劲]",
                        @"[抱拳]",
                        @"[拳头]",
                        @"[玫瑰]",
                        @"[凋谢]",
                        @"[心]",
                        @"[伤心]",
                        @"delete",
                        @"[钟]",
                        @"[太阳]",
                        @"[月亮]",
                        @"[蛋糕]",
                        @"[礼物]",
                        @"[干杯]",
                        @"[咖啡]",
                        @"[猪头]",
                        @"[话筒]",
                        @"[蜡烛]",
                        @"[闪电]",
                        @"[拥抱]",
                        @"[吃饭]",
                        @"[足球]",
                        @"[雨伞]",
                        @"[棒棒糖]",
                        @"[气球]",
                        @"[沙发]",
                        @"[飞机]",
                        @"delete",
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
