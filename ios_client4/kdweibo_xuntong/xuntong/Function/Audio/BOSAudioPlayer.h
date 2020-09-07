//
//  BOSAudioPlayer.h
//  ContactsLite
//
//  Created by Gil on 12-11-29.
//  Copyright (c) 2012年 kingdee eas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "BubbleVoiceView.h"

@protocol KDCommonAudioCell <NSObject>
@property (nonatomic, strong) BubbleVoiceView *voiceView;
@end

extern NSString* const kNotifyAudioFinishPlaying;
extern NSString* const kKeyCurSpeechCell;
@class BubbleTableViewCell;
@interface BOSAudioPlayer : NSObject <AVAudioPlayerDelegate> {
    //定义一个声音的播放器
    AVAudioPlayer *_player;
    
    NSString *_playerIdentifier;
    id<KDCommonAudioCell> _currentCell;
}

+(BOSAudioPlayer *)sharedAudioPlayer;

-(void)createPlayerWithData:(NSData *)fileData identifier:(NSString *)identifier cell:(id<KDCommonAudioCell>)cell;

-(BOOL)isPlaying;
-(void)startPlay;
-(void)stopPlay;
-(void)disableAudioSession;

@end
