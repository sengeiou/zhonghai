//
//  KDTipView.h
//  kdweibo_common
//
//  Created by shen kuikui on 13-1-11.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDManagerContext.h"

UIKIT_EXTERN NSString *const KDDidTapOnTipViewNotification;


typedef enum {
    KDTipViewMessageType_Mention = 1,
    KDTipViewMessageType_Comments,
    KDTipViewMessageType_DirectMessage,
    KDTipViewMessageType_SendError
}KDTipViewMessageType;

@interface KDTipView : UIButton<KDUnreadListener, UIGestureRecognizerDelegate> {
@private
    NSString *content_;
    NSString *badgeValue_;
    NSString *name_;
    KDTipViewMessageType _type;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *badgeValue;
@property (nonatomic, readonly) KDTipViewMessageType msgType;
@property (nonatomic, assign) BOOL isVisible;

- (void)setName:(NSString *)name content:(NSString *)content andBadgeValue:(NSString *)badgeValue;

+ (KDTipView *)sharedTipView;

+ (KDTipView *)weiboStatusTipView;

@end
