//
//  KDVoiceMeetingMeImageView.h
//  kdweibo
//
//  Created by 张培增 on 16/9/7.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    KDVoiceMeetingMeImageViewType_None = 0,
    KDVoiceMeetingMeImageViewType_Mute,                 //静音
    KDVoiceMeetingMeImageViewType_Speak,                //说话
    KDVoiceMeetingMeImageViewType_HandsUp,              //举手
    KDVoiceMeetingMeImageViewType_HandsDown,            //取消举手
    KDVoiceMeetingMeImageViewType_BadNetwork            //网络不好
} KDVoiceMeetingMeImageViewType;

@interface KDVoiceMeetingMeImageView : UIImageView

@property (nonatomic, assign) KDVoiceMeetingMeImageViewType imageViewType;

//网络不好的时候记录上一次的type,恢复网络时候使用
@property (nonatomic, assign) KDVoiceMeetingMeImageViewType lastImageViewType;

@end
