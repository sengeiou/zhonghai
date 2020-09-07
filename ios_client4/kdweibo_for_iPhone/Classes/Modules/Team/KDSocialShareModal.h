//
//  KDScocialShareModal.h
//  kdweibo
//
//  Created by DarrenZheng on 14-9-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, KDSheetShareWay)
{
    KDSheetShareWayNone    = 0,
    KDSheetShareWaySMS     = 1 << 0,
    KDSheetShareWayWechat  = 1 << 1,
    KDSheetShareWayMoment  = 1 << 2,
    KDSheetShareWayQQ      = 1 << 3,
    KDSheetShareWayQzone   = 1 << 4,
    KDSheetShareWayWeibo   = 1 << 5,
    KDSheetShareWayBuluo   = 1 << 6, // 公有云是部落，在是有云表示分享到动态
    KDSheetShareWayAll     = 0x3F 
};

typedef NS_ENUM(NSUInteger, KDSheetShareType)
{
    KDSheetShareTypeText,
    KDSheetShareTypeImage,
    KDSheetShareTypeMedia
};

#define KD_NOTE_SHARE_DID_SUCC ASLocalizedString(@"分享成功")// userInfo:{shareWay:NSNumber}
#define KD_NOTE_SHARE_DID_FAIL ASLocalizedString(@"分享失败")// userInfo:{shareWay:NSNumber, error:NSString}

#define KD_NOTE_USERINFO_KEY_ERROR      @"error"
#define KD_NOTE_USERINFO_KEY_SHAREWAY   @"shareWay"

@interface KDSocialShareModal : NSObject

+ (void)postNoteSuccWithShareWay:(KDSheetShareWay)shareWay;
+ (void)postNoteFailWithShareWay:(KDSheetShareWay)shareWay
                           error:(NSString *)strError;
+ (BOOL)isSingleSelection:(KDSheetShareWay)shareWay;

@end
