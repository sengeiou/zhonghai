//
//  KDVoiceButtonForMultiVoice.m
//  kdweibo
//
//  Created by 陈彦安 on 15/4/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDVoiceButtonForMultiVoice.h"
@interface KDVoiceButtonForMultiVoice ()
@property(nonatomic, strong) UIImage *normalImage;
@property(nonatomic, strong) UIImage *pressImage;
@property(nonatomic, assign) BOOL enable;
@property (nonatomic, strong) id agora;
@end

@implementation KDVoiceButtonForMultiVoice
+ (KDVoiceButtonForMultiVoice *)buildWithFrame:(CGRect)frame
                                        NorImg:(NSString *)normalImageName
                                        PreImg:(NSString *)pressImageName
                                          Type:(KDVoiceButtonType)type
                                        enable:(BOOL)enable
                                         agora:(id)agora{
    KDVoiceButtonForMultiVoice *button = [KDVoiceButtonForMultiVoice buttonWithType:UIButtonTypeCustom];
    
    
    button.normalImage = [UIImage imageNamed:normalImageName];
    button.pressImage = [UIImage imageNamed:pressImageName];
    button.type = type;
    button.enable = enable;
    button.agora = agora;
    [button setFrame:frame];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    [button setImage:enable ? button.pressImage : button.normalImage forState:UIControlStateNormal];
    
    if (type == KDVoiceButtonType_Speaker) {
        [(AgoraRtcEngineKit *)agora setEnableSpeakerphone:enable];
    }
    
#endif
    
    return button;
}

- (void)changeState {
    if (self.type == KDVoiceButtonType_Speaker) {
        [self setSpeaker];
    }
    else if (self.type == KDVoiceButtonType_Mute) {
        [self setMult];
    }
    else if (self.type == KDVoiceButtonType_HandsUp) {
        [self setHandsUp];
    }
}

- (void)setSpeaker {
    self.enable = !self.enable;
    [KDAgoraSDKManager sharedAgoraSDKManager].speakerEnable = self.enable;
    [self setImage: self.enable ? self.pressImage : self.normalImage forState:UIControlStateNormal];
#if !(TARGET_IPHONE_SIMULATOR)
    [(AgoraRtcEngineKit *)self.agora setEnableSpeakerphone:self.enable];
#endif
    
}

- (void)setMult {
    self.enable = !self.enable;
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    agoraSDKManager.modeEnable = self.enable;
    [self setImage: self.enable ? self.pressImage : self.normalImage forState:UIControlStateNormal];
#if !(TARGET_IPHONE_SIMULATOR)
    [(AgoraRtcEngineKit *)self.agora muteLocalAudioStream:self.enable];
    if(self.enable)
    {
        [agoraSDKManager sendMuteselfMessage];
    }else{
        [agoraSDKManager sendUnMuteSelfMessage];
    }
#endif
}

- (void)setHandsUp {
    self.enable = !self.enable;
    [self setImage: self.enable ? self.pressImage : self.normalImage forState:UIControlStateNormal];
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    if (self.enable) {
        [agoraSDKManager sendPersonStatusMessage:2 personId:nil];
    }
    else {
        [agoraSDKManager sendPersonStatusMessage:3 personId:nil];
    }
}

- (void)setSpeakerTureFlag:(BOOL)speakerTureFlag
{
    _speakerTureFlag = speakerTureFlag;
    self.enable = speakerTureFlag;
    [KDAgoraSDKManager sharedAgoraSDKManager].speakerEnable = self.enable;
    [self setImage: self.enable ? self.pressImage : self.normalImage forState:UIControlStateNormal];
#if !(TARGET_IPHONE_SIMULATOR)
    [(AgoraRtcEngineKit *)self.agora setEnableSpeakerphone:speakerTureFlag];
#endif
}

- (void)setModeTureFlag:(BOOL)modeTureFlag
{
    _modeTureFlag = modeTureFlag;
    self.enable = modeTureFlag;
    KDAgoraSDKManager *agoraSDKManager = [KDAgoraSDKManager sharedAgoraSDKManager];
    agoraSDKManager.modeEnable = self.enable;
#if !(TARGET_IPHONE_SIMULATOR)
    [(AgoraRtcEngineKit *)self.agora muteLocalAudioStream:self.enable];
    if(self.enable)
    {
        [agoraSDKManager sendMuteselfMessage];
    }else{
        [agoraSDKManager sendUnMuteSelfMessage];
    }
#endif
    [self setImage: self.enable ? self.pressImage : self.normalImage forState:UIControlStateNormal];
    
}


- (void)changeSpeakerEnable
{
#if !(TARGET_IPHONE_SIMULATOR)
    if(self.type == KDVoiceButtonType_Speaker)
    {
        [(AgoraRtcEngineKit *)self.agora setEnableSpeakerphone:NO];
        self.enable = NO;
        [self setSpeaker];
    }
#endif
}

- (void)changeType:(KDVoiceButtonType)type NorImg:(NSString *)normalImageName PreImg:(NSString *)pressImageName enable:(BOOL)enable
{
    self.type = type;
    self.normalImage = [UIImage imageNamed:normalImageName];
    self.pressImage = [UIImage imageNamed:pressImageName];
    self.enable = enable;
    [self setImage:enable ? self.pressImage : self.normalImage forState:UIControlStateNormal];
}

@end
