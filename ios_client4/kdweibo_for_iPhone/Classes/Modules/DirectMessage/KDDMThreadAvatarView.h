//
//  KDDMThreadAvatarView.h
//  kdweibo
//
//  Created by laijiandong on 12-9-6.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KDAvatarProtocol.h"
@class KDInbox;
@class KDDMThread;

#define KD_DM_THREAD_AVATAR_VIEW_COUNT  0x04

@interface KDDMThreadAvatarView : UIButton <KDCompositeAvatarLoader> {
 @private
    KDDMThread *dmThread_;
    KDInbox    *dmInbox_;
    DmType      type_;
    NSUInteger avatarCount_;
    
    BOOL loadingAvatars_;
    
    UIImageView *maskImageView_;
    UIView *stageView_;
    NSMutableArray *avatarRenderViews_;
    
    struct {
        unsigned int layoutOnce:1;
        unsigned int compositeMode:1; // public dm thread
        unsigned int loadedMasks[KD_DM_THREAD_AVATAR_VIEW_COUNT]; // the flag for record avatar did loaded
    }dmThreadAvatarViewFlags_;
    
    NSArray     *urls_;
    NSInteger   userCount_;
    BOOL        isMutil_;
}

@property(nonatomic, retain) KDDMThread *dmThread;
@property(nonatomic, retain) KDInbox    *dmInbox;
@property(nonatomic, assign) BOOL loadingAvatars;
@property(nonatomic, assign, readonly) BOOL hasUnloadAvatars;

+ (KDDMThreadAvatarView *)dmThreadAvatarView;

@end
