//
//  XTImageUtil.h
//  TestTabBar
//
//  Created by Gil on 13-7-3.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTContactDataModel.h"

typedef enum _ChatDetailType
{
    ChatDetailTypeSingle = 0,
    ChatDetailTypeMutil = 1
}ChatDetailType;

typedef enum _ContactIconType
{
    ContactIconFav,
    ContactIconOrg,
    ContactIconPublic,
    ContactIconRecent,
    ContactIconSearch
}ContactIconType;

typedef enum _ContactActionType
{
    ContactActionSms,
    ContactActionTel,
    ContactActionFav,
    ContactActionDetail,
    ContactActionTriangle
}ContactActionType;

@interface XTImageUtil : NSObject

+ (UIImage *)imageNamed:(NSString *)name;

#pragma mark - NavBar
+ (UIImage *)navBarBackgroundImage;
#pragma mark - TabBar
+ (UIImage *)tabBarBackgroundImage;
+ (UIImage *)tabBarItemImageWithIndex:(NSInteger)index state:(UIControlState)state;
+ (UIImage *)tabBarItemSelectedImage;
#pragma mark - Header
//+ (UIImage *)headerBackgroundImage;
+ (UIImage *)headerDefaultImage;
+ (UIImage *)headerXTAvailableImage;
+ (UIImage *)headerAccountAvailableImage;
#pragma mark - Cell
+ (UIImage *)cellSeparateLineImage;
+ (UIImage *)cellUnreadNumberImage;
+ (UIImage *)cellAccessoryDisclosureIndicatorImageWithState:(UIControlState)state;
+ (UIImage *)cellSelectStateImageWithState:(BOOL)state;
+ (UIImage *)cellSelectDotImage;
+ (UIImage *)cellSelectStateImageForFileWithState:(BOOL)state;
+ (UIImage *)cellThumbnailImageWithType:(int)type;
#pragma mark - Button
+ (UIImage *)buttonBackImageWithState:(UIControlState)state;
+ (UIImage *)buttonCancelImageWithState:(UIControlState)state;
+ (UIImage *)buttonChatDetailImageWithType:(ChatDetailType)type state:(UIControlState)state;
+ (UIImage *)buttonAddMenuImage;
+ (UIImage *)buttonClearInputImageWithState:(UIControlState)state;
+ (UIImage *)buttonCreateChatImageWithState:(UIControlState)state;
+ (UIImage *)buttonQRscanImageWithState:(UIControlState)state;
+ (UIImage *)buttonWeiboImageWithState:(UIControlState)state;
+ (UIImage *)buttonInviteImageWithState:(UIControlState)state;

#pragma mark - Chat
+ (UIImage *)chatVoiceImageWithDirection:(int)direction tag:(int)tag;
+ (UIImage *)chatDialogBackgroundImageWithDirection:(int)direction state:(UIControlState)state;
+ (UIImage *)chatPictureBackgroundImageWithDirection:(int)direction state:(UIControlState)state;
+ (UIImage *)chatNotificationDialogBackgroundImage;
+ (UIImage *)chatUnreadVoiceImage;
+ (UIImage *)chatSendFailueImage;
+ (UIImage *)chatToolBarBackgroundImage;
+ (UIImage *)chatToolBarShortVideoBtnImageWithState:(UIControlState)state;
+ (UIImage *)chatToolBarChangeBtnImageWithTag:(int)tag state:(UIControlState)state;
+ (UIImage *)chatToolBarAddBtnImageWithState:(UIControlState)state;
+ (UIImage *)chatToolBarPhotoBtnImageWithState:(UIControlState)state;
+ (UIImage *)chatToolBarCameraBtnImageWithState:(UIControlState)state;
+ (UIImage *)chatToolBarFileBtnImageWithState:(UIControlState)state;
//+ (UIImage *)chatToolBarVoiceBtnImageWithState:(UIControlState)state;
+ (UIImage *)chatToolBarEmojiBtnImageWithState:(UIControlState)state;
+ (UIImage *)chatToolBarMenuBtnImageWithState:(UIControlState)state withUpDown:(int)upDown;
+ (UIImage *)chatVoiceDeleteBackgroundImage;
+ (UIImage *)chatVoiceMicrophoneImage;
+ (UIImage *)chatVoiceTrashImage;
+ (UIImage *)chatVoiceVolumeImage;
+ (UIImage *)chatDetailAddImageWithState:(UIControlState)state;
+ (UIImage *)chatDetailDeleteImageWithState:(UIControlState)state;
+ (UIImage *)chatDetailDeletePersonImageWithState:(UIControlState)state;
+ (UIImage *)chatVoiceRecordImageWithState:(UIControlState)state;
#pragma mark - Contact
+ (UIImage *)contactUnexpendedIcon;
+ (UIImage *)contactExpendedIcon;
+ (UIImage *)contactFoldImageWithType:(ContactDataType)type;
+ (UIImage *)contactIconImageWithType:(ContactIconType)type;
+ (UIImage *)contactActionImageWithType:(ContactActionType)type state:(UIControlState)state;
#pragma mark - Search
+ (UIImage *)searchBarBackgroundImage;
+ (UIImage *)searchBarFieldBackgroundImage;
+ (UIImage *)searchBarIconSeacrchImage;
+ (UIImage *)searchBarIconVoiceImageWithState:(UIControlState)state;
+ (UIImage *)searchBarIconDeleteImageWithState:(UIControlState)state;
+ (UIImage *)searchBarIconChangeKeyBoardImageWithTag:(int)tag state:(UIControlState)state;
+ (UIImage *)searchBackgroundT9GuideImage;
#pragma mark - Prompt
+ (UIImage *)promptArrowImageWithDirection:(int)direction;
#pragma mark - Tool
+ (UIImage *)toolDefaultPersonSelectImage;
#pragma mark - Login and scrollview
+ (UIImage *)ScroViewBgImage1;
+ (UIImage *)ScroViewBgImage2;
+ (UIImage *)ScroViewBgImage3;
+ (UIImage *)ScroViewCutOver1;
+ (UIImage *)ScroViewCutOver2;
+ (UIImage *)LoginImageCloud;
+ (UIImage *)LoginPassWord;
+ (UIImage *)LoginUserName;
+ (UIImage *)LoginUserNamecloud;
#pragma mark - Person
+ (UIImage *)personDetailMailImage;
+ (UIImage *)personDetailPhoneImage;
+ (UIImage *)personDetailFavImageWithState:(UIControlState)state;
+ (UIImage *)personDetailBackgroundImage;
#pragma mark - Setting
+ (UIImage *)settingXTIconImage;
+ (UIImage *)settingSetIconImage;
+ (UIImage *)settingFeedbackIconImage;
#pragma mark - Guide
+ (UIImage *)guideContentImageWithTag:(int)tag;
+ (UIImage *)guideButtonNextImgaeWithState:(UIControlState)state;
+ (UIImage *)guideButtonPreviousImgaeWithState:(UIControlState)state;
+ (UIImage *)guideButtonStartImgaeWithState:(UIControlState)state;
+ (UIImage *)guideButtonShareImgae;
#pragma mark - About
+ (UIImage *)aboutApplicationIconImage;
+ (UIImage *)aboutKingdeeLogoImage;
#pragma mark - QR
+ (UIImage *)qrLoginXTWebImage;
+ (UIImage *)qrLoginMyKingdeeImage;
+ (UIImage *)qrButtonScanImageWithState:(UIControlState)state;
+ (UIImage *)newsBackgroundImage;
#pragma mark - Share
+ (UIImage *)shareOKImage;
+ (UIImage *)publicheadimage;
+ (UIImage *)chatImage;
+ (UIImage *)phoneImage;
+ (UIImage *)XTappShadeImage;
+ (UIImage *)addAppImageWithState:(UIControlState)state;
+ (UIImage *)personInfoBtnWithState:(UIControlState)state;
#pragma mark -- Delete
+ (UIImage *)deleteButtonImageWithState:(UIControlState)state;
#pragma mark -- Public
+ (UIImage *)menuFlagImage;
//标记
+ (UIImage *)buttonMarkImage;

@end
