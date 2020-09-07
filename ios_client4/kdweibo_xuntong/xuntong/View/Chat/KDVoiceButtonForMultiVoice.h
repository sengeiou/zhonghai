//
//  KDVoiceButtonForMultiVoice.h
//  kdweibo
//
//  Created by wenbin_su on 15/7/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDAgoraSDKManager.h"
#if !(TARGET_IPHONE_SIMULATOR)
#import "agorasdk.h"
#import "AgoraAudioKit/AgoraRtcEngineKit.h"
#endif
typedef NS_ENUM(NSInteger, KDVoiceButtonType) {
    KDVoiceButtonType_Mute,                 //静音按钮
    KDVoiceButtonType_Speaker,              //扬声器按钮
    KDVoiceButtonType_HandsUp,              //举手按钮
    KDVoiceButtonType_Disable               //不可点击按钮
};

@class KDVoiceButtonForMultiVoice;

@interface KDVoiceButtonForMultiVoice : UIButton
@property(nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, assign) BOOL  speakerTureFlag;
@property (nonatomic, assign) BOOL modeTureFlag;
@property(nonatomic, assign) KDVoiceButtonType type;
+ (KDVoiceButtonForMultiVoice *)buildWithFrame:(CGRect)frame
                                        NorImg:(NSString *)normalImageName
                                        PreImg:(NSString *)pressImageName
                                          Type:(KDVoiceButtonType)type
                                        enable:(BOOL)enable
                                         agora:(id)agora;

//改变按钮状态
- (void)changeState;

//改变按钮类型以及图片
- (void)changeType:(KDVoiceButtonType)type NorImg:(NSString *)normalImageName PreImg:(NSString *)pressImageName enable:(BOOL)enable;

@end
