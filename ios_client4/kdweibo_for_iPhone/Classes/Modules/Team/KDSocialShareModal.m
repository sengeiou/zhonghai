//
//  KDScocialShareModal.m
//  kdweibo
//
//  Created by DarrenZheng on 14-9-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSocialShareModal.h"

@implementation KDSocialShareModal

+ (void)postNoteSuccWithShareWay:(KDSheetShareWay)shareWay
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KD_NOTE_SHARE_DID_SUCC
                                                        object:nil
                                                      userInfo:@{KD_NOTE_USERINFO_KEY_SHAREWAY:[NSNumber numberWithInt:shareWay]}];
}

+ (void)postNoteFailWithShareWay:(KDSheetShareWay)shareWay
                           error:(NSString *)strError
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KD_NOTE_SHARE_DID_FAIL
                                                        object:nil
                                                      userInfo:@{KD_NOTE_USERINFO_KEY_SHAREWAY:[NSNumber numberWithInt:shareWay],
                                                                 KD_NOTE_USERINFO_KEY_ERROR: strError}];
}

+ (BOOL)isSingleSelection:(KDSheetShareWay)shareWay
{
    BOOL bResult;
    if (shareWay == KDSheetShareWaySMS      ||
        shareWay == KDSheetShareWayWechat   ||
        shareWay == KDSheetShareWayMoment   ||
        shareWay == KDSheetShareWayQQ       ||
        shareWay == KDSheetShareWayQzone    ||
        shareWay == KDSheetShareWayWeibo)
    {
        bResult = YES;
    }
    else
    {
        bResult = NO;
    }
    return bResult;
}

@end
