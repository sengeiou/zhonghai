//
//  KDSheet.h
//  kdweibo
//
//  Created by DarrenZheng on 14-9-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

/* `````````````````使用指南```````````````
 
 // 初始化
 --------------------------------------------
 @property (nonatomic, strong) KDSheet *sheet;
 
 - (KDSheet *)sheet
 {
    if (!_sheet)
    {
        NSString *message = @"xxxx"
        _sheet = [[KDSheet alloc]initTextWithShareWay:KDSheetShareWayAll text:message viewController:self];
    }
    return _sheet;
 }
 
 // 调用
 -------------------------------------------------
 [self.sheet share];
 
 // 回调
 -------------------------------------------------
 
 #通知:
 
 KD_NOTE_SHARE_DID_SUCC ASLocalizedString(@"KDSheet_Share_Success")// userInfo:{shareWay:NSNumber}
 KD_NOTE_SHARE_DID_FAIL ASLocalizedString(@"KDSheet_Share_Fail")// userInfo:{shareWay:NSNumber, error:NSString}
 
 #userInfo key:
 
 KD_NOTE_USERINFO_KEY_ERROR      @"error"
 KD_NOTE_USERINFO_KEY_SHAREWAY   @"shareWay"
 
 #addObserver:
 
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoteDidSucc:) name:KD_NOTE_SHARE_DID_SUCC object:nil];
 
 - (void)onNoteDidSucc:(NSNotification *)note
 {
    NSLog(@"%@",note.userInfo[KD_NOTE_USERINFO_KEY_SHAREWAY]);
 }
 
 */

#import <Foundation/Foundation.h>
#import "KDSocialShareModal.h"

@protocol KDSheetDelegate <NSObject>

- (void)buttonPressedWithShareWay:(KDSheetShareWay)shareWay;

@end

@interface KDSheet : NSObject

@property (nonatomic, assign) id <KDSheetDelegate> delegate;
@property (nonatomic, assign) KDSheetShareType shareType;

// 文本
- (KDSheet *)initTextWithShareWay:(KDSheetShareWay)shareWay
                             text:(NSString *)strText
                   viewController:(UIViewController *)vcParent;

// 图片
- (KDSheet *)initImageWithShareWay:(KDSheetShareWay)shareWay
                         imageData:(NSData *)dataImage
                    viewController:(UIViewController *)vcParent;

// 多媒体
- (KDSheet *)initMediaWithShareWay:(KDSheetShareWay)shareWay
                             title:(NSString *)strTitle
                       description:(NSString *)strDesc
                         thumbData:(NSData *)dataThumb
                        webpageUrl:(NSString *)strWebPageUrl
                    viewController:(UIViewController *)vcParent;

// 激活选择菜单, 或者直接分享(如果shareWay只有一个)
- (void)share;
- (void)hideSheet;

- (void)shareWithShareType:(KDSheetShareType)shareType
                  shareWay:(KDSheetShareWay)shareWay;
@end


