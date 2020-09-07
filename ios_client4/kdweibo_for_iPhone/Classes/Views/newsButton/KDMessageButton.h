//
//  KDLeftMsgButton.h
//  kdweibo
//
//  Created by gordon_wu on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDBadgeIndicatorView.h"
typedef enum BUTTON_TYPE
{
    COMPANY_BTN       ,
    NETWORK_BTN       ,
    TAME_BTN          ,
    DIRECTMESSAGE_BTN ,   //信息
    PERSON_BTN        ,   //通讯录
    DYNAMIC_BTN       ,   // 发现
    APPLICTION_BTN        // 应用
}BUTTON_TYPE;

@interface KDMessageButton : UIButton
@property (nonatomic,retain) UIImage * msgImage;

@property (nonatomic, retain) KDBadgeIndicatorView *bageImageView;

- (void) showMsgImage:(BOOL) isShow;

- (void)setBadgeValue:(NSInteger)badgeValue;

@end
