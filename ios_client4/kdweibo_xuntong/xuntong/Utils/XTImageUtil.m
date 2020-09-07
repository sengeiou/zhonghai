//
//  XTImageUtil.m
//  TestTabBar
//
//  Created by Gil on 13-7-3.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTImageUtil.h"

@implementation XTImageUtil

+ (UIImage *)imageNamed:(NSString *)name
{
    return [UIImage imageNamed:name];
}

#pragma mark - NavBar

+ (UIImage *)navBarBackgroundImage
{
    return  [self imageNamed:@"NavBar_Background-568h.png"];
}

#pragma mark - TabBar

+ (UIImage *)tabBarBackgroundImage
{
     return [[self imageNamed:@"toolbar_other_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 21, 0, 21)];
}

static NSArray *tabBarItemImageNames = nil;
+ (UIImage *)tabBarItemImageWithIndex:(NSInteger)index state:(UIControlState)state
{
    tabBarItemImageNames = [NSArray arrayWithObjects:@"TabBar_Timeline",@"TabBar_Contact",@"TabBar_App",@"TabBar_Setting",nil];
    if (state == UIControlStateNormal) {
        return [self imageNamed:[NSString stringWithFormat:@"%@.png",[tabBarItemImageNames objectAtIndex:index]]];
    }
    return [self imageNamed:[NSString stringWithFormat:@"%@_Highlight.png",[tabBarItemImageNames objectAtIndex:index]]];
}

+ (UIImage *)tabBarItemSelectedImage
{
    return nil;
}

#pragma mark - Header

//+ (UIImage *)headerBackgroundImage
//{
//    return [self imageNamed:@"Header_Background.png"];
//}

+ (UIImage *)headerDefaultImage
{
    return [self imageNamed:@"user_default_portrait"];
}

+ (UIImage *)headerXTAvailableImage
{
    //return [self imageNamed:@"common_img_weijihuo.png"];
    return [self imageNamed:@"common_img_unactivated"];
}

+ (UIImage *)headerAccountAvailableImage
{
    return [self imageNamed:@"Header_AccountAvailable.png"];
}

#pragma mark - Cell

+ (UIImage *)cellSeparateLineImage
{
    return [self imageNamed:@"Cell_Separate_Line.png"];
}

+ (UIImage *)cellUnreadNumberImage
{
    UIImage *image = [self imageNamed:@"common_img_new.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)cellAccessoryDisclosureIndicatorImageWithState:(UIControlState)state
{
    NSString *imageName = @"Cell_Accessory_DisclosureIndicator.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"Cell_Accessory_DisclosureIndicator_Highlight.png";
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)cellSelectStateImageWithState:(BOOL)state
{
    NSString *imageName = @"task_editor_finish";
    if (!state) {
        imageName = @"task_editor_select";
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)cellSelectDotImage
{
    return [self imageNamed:@"task_editor_finish"];
}

+ (UIImage *)cellThumbnailImageWithType:(int)type
{
    NSString *imageName = @"Cell_Thumbnail_Left";
    if (type == 1) {
        imageName = @"Cell_Thumbnail_Right";
    } else if (type == 2) {
        imageName = @"Cell_Thumbnail_Large";
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)cellSelectStateImageForFileWithState:(BOOL)state
{
    NSString *imageName = @"task_editor_finish";
    if (!state) {
        imageName = @"task_editor_select";
    }
    return [self imageNamed:imageName];
}

#pragma mark - Button

+ (UIImage *)buttonBackImageWithState:(UIControlState)state
{
    NSString *imageName = @"navigationItem_back.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"navigationItem_back_hl.png";
    }
    return [[self imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 24.0, 28.0, 34.0)];
}

+ (UIImage *)buttonCancelImageWithState:(UIControlState)state
{
    NSString *imageName = @"Button_Cancel.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"Button_Cancel_Highlight.png";
    }
    return [[self imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 24.0, 28.0, 34.0)];
}

+ (UIImage *)buttonChatDetailImageWithType:(ChatDetailType)type state:(UIControlState)state
{
    NSString *imageName = @"head_btn_details";
    if (type == ChatDetailTypeMutil) {
        imageName = @"head_btn_duoren";
    }
    
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    
    return [self imageNamed:imageName];
}

+ (UIImage *)buttonMarkImage
{
    NSString *imageName = @"nav_btn_mark_normal1";
    return [self imageNamed:imageName];
}

+ (UIImage *)buttonAddMenuImage
{
    NSString *imageName = @"nav_btn_plus_normal";
    return [self imageNamed:imageName];
}

+ (UIImage *)buttonCreateChatImageWithState:(UIControlState)state;
{
    NSString *imageName = @"message_drop_img_faqi.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"message_drop_img_faqi_press.png";
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)buttonQRscanImageWithState:(UIControlState)state;
{
    NSString *imageName = @"message_drop_img_saoyisao.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"message_drop_img_saoyisao_press.png";
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)buttonWeiboImageWithState:(UIControlState)state;
{
    NSString *imageName = @"message_drop_img_weibo.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"message_drop_img_weibo_press.png";
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)buttonInviteImageWithState:(UIControlState)state;
{
    NSString *imageName = @"message_drop_img_yaoqing.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"message_drop_img_yaoqing_press.png";
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)buttonClearInputImageWithState:(UIControlState)state
{
    NSString *imageName = @"Clear_Input_Button.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"Clear_Input_Button_Highlight.png";
    }
    return [self imageNamed:imageName];
}

#pragma mark - Chat

+ (UIImage *)chatVoiceImageWithDirection:(int)direction tag:(int)tag
{
    NSString *imageName = [NSString stringWithFormat:@"Chat_%@Dialog_Voice%d.png",direction == 0 ? @"Left" : @"Right",tag];
    return [self imageNamed:imageName];
}

+ (UIImage *)chatDialogBackgroundImageWithDirection:(int)direction state:(UIControlState)state
{
    NSString *imageName = nil;
    if (direction == 0 )
    {
        imageName = @"message_bg_speak_left";
    }
    else
    {
        imageName = @"message_bg_speak_right";
    }
    return [[self imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(25.0, 10.0, 10.0, 15.0)];
}
+ (UIImage *)chatPictureBackgroundImageWithDirection:(int)direction state:(UIControlState)state
{
    NSString *imageName = nil;
    if (direction == 0 )
    {
        imageName = @"message_bg_speak_left";
    }
    else
    {
        imageName = @"message_bg_other_right";
    }
    
    return [[self imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(25.0, 10.0, 10.0, 15.0)];
}


+ (UIImage *)chatNotificationDialogBackgroundImage
{
    return [[self imageNamed:@"Chat_NotificationDialog_Background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(25.0, 40.0, 24.0, 40.0)];
}

+ (UIImage *)chatUnreadVoiceImage
{
    return [self imageNamed:@"Chat_Unread_Voice.png"];
}

+ (UIImage *)chatSendFailueImage
{
    return [self imageNamed:@"Chat_SendFailue.png"];
}

+ (UIImage *)chatToolBarBackgroundImage
{
    return [[self imageNamed:@"Chat_ToolBar_Background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(24.0, 160.0, 24.0, 159.0)];
}

+ (UIImage *)chatToolBarChangeBtnImageWithTag:(int)tag state:(UIControlState)state
{
    NSString *imageName = [NSString stringWithFormat:@"message_btn_%@",tag == 0 ? @"micro" : @"keyboard"];
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)chatToolBarPhotoBtnImageWithState:(UIControlState)state
{
    NSString *imageName = @"dm_btn_picture";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@"_normal.png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)chatToolBarCameraBtnImageWithState:(UIControlState)state
{
    NSString *imageName = @"dm_btn_photo";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@"_normal.png"];
    }
    return [self imageNamed:imageName];
}
+ (UIImage *)chatToolBarShortVideoBtnImageWithState:(UIControlState)state
{
    NSString *imageName = @"icon_video";
//    if (state == UIControlStateHighlighted) {
//        imageName = [imageName stringByAppendingString:@"_press.png"];
//    } else {
//        imageName = [imageName stringByAppendingString:@"_normal.png"];
//    }
    return [self imageNamed:imageName];
}
+ (UIImage *)chatToolBarFileBtnImageWithState:(UIControlState)state
{
    NSString *imageName = @"dm_btn_file";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@"_normal.png"];
    }
    return [self imageNamed:imageName];
}

//+ (UIImage *)chatToolBarVoiceBtnImageWithState:(UIControlState)state
//{
//    NSString *imageName = @"yuyin_beta_ios.png";
////    if (state == UIControlStateHighlighted) {
////        imageName = [imageName stringByAppendingString:@"_press.png"];
////    } else {
////        imageName = [imageName stringByAppendingString:@"_normal.png"];
////    }
//    return [self imageNamed:imageName];
//}

+ (UIImage *)chatToolBarEmojiBtnImageWithState:(UIControlState)state
{
    NSString *imageName = @"message_btn_face";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)chatToolBarAddBtnImageWithState:(UIControlState)state
{
    NSString *imageName = @"message_btn_addlist";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)chatToolBarMenuBtnImageWithState:(UIControlState)state withUpDown:(int)upDown
{
    NSString *imageName = @"message_img_change";
    imageName = [imageName stringByAppendingString:(upDown == 1) ? @"1" : @"2"];
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)chatVoiceDeleteBackgroundImage
{
    return [self imageNamed:@"Chat_Voice_Delete_Background.png"];
}

+ (UIImage *)chatVoiceMicrophoneImage
{
    return [self imageNamed:@"Chat_Voice_Microphone.png"];
}

+ (UIImage *)chatVoiceTrashImage
{
    return [self imageNamed:@"Chat_Voice_Trash.png"];
}

+ (UIImage *)chatVoiceVolumeImage
{
    return [[self imageNamed:@"Chat_Voice_Volume.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 0, 7.0, 0)];
}

#pragma mark - Chat Detail

+ (UIImage *)chatDetailAddImageWithState:(UIControlState)state
{
    NSString *imageName = @"message_tip_add";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@".png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)chatDetailDeleteImageWithState:(UIControlState)state
{
    NSString *imageName = @"message_tip_delete";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@".png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)chatDetailDeletePersonImageWithState:(UIControlState)state
{
    NSString *imageName = @"dm_btn_delete";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@".png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)chatVoiceRecordImageWithState:(UIControlState)state
{
    NSString *imageName = @"message_btn_speak";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_press.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [[self imageNamed:imageName] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
}

#pragma mark - Contact

+ (UIImage *)contactUnexpendedIcon
{
    NSString *imageName = @"Unexpended.png";
    return [self imageNamed:imageName];
}

+ (UIImage *)contactExpendedIcon
{
    NSString *imageName = @"Expended.png";
    return [self imageNamed:imageName];
}

+ (UIImage *)contactFoldImageWithType:(ContactDataType)type
{
    NSString *imageName = nil;
    switch (type) {
        case ContactDataGroup:
            imageName = @"contacts_tip_session.png";
            break;
        case ContactDataPublic:
            imageName = @"college_img_public.png";
            break;
        case ContactDataNewCoworker:
            imageName = @"Contact_NewCoworker.png";
            break;
        case ContactDataOrg:
            imageName = @"college_img_organization.png";
            break;
        case ContactDataRecent:
            imageName = @"college_img_latest.png";
            break;
        case ContactDataFav:
            imageName = @"college_img_collection";
            break;
        default:
            imageName = @"contacts_tip_session.png";
            break;
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)contactIconImageWithType:(ContactIconType)type
{
    NSString *imageName = @"Contact_Icon_";
    switch (type) {
        case ContactIconFav:
            imageName = [imageName stringByAppendingString:@"Fav.png"];
            break;
        case ContactIconOrg:
            imageName = [imageName stringByAppendingString:@"Org.png"];
            break;
        case ContactIconPublic:
            imageName = [imageName stringByAppendingString:@"Public.png"];
            break;
        case ContactIconRecent:
            imageName = [imageName stringByAppendingString:@"Recent.png"];
            break;
        case ContactIconSearch:
            imageName = [imageName stringByAppendingString:@"Search.png"];
            break;
        default:
            imageName = [imageName stringByAppendingString:@"Fav.png"];
            break;
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)contactActionImageWithType:(ContactActionType)type state:(UIControlState)state
{
    NSString *imageName = @"Contact_Action_";
    switch (type) {
        case ContactActionSms:
            imageName = [imageName stringByAppendingString:@"Sms"];
            break;
        case ContactActionTel:
            imageName = [imageName stringByAppendingString:@"Tel"];
            break;
        case ContactActionFav:
            imageName = [imageName stringByAppendingString:@"Fav"];
            break;
        case ContactActionDetail:
            imageName = [imageName stringByAppendingString:@"Detail"];
            break;
        case ContactActionTriangle:
            imageName = [imageName stringByAppendingString:@"Triangle"];
            break;
        default:
            imageName = [imageName stringByAppendingString:@"Triangle"];
            break;
    }
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

#pragma mark - Search

+ (UIImage *)searchBarBackgroundImage
{
    return [self imageNamed:@"Search_Bar_Background.png"];
}

+ (UIImage *)searchBarFieldBackgroundImage
{
    return [self imageNamed:@"Search_Bar_Field_Background.png"];
}

+ (UIImage *)searchBarIconSeacrchImage
{
    return [self imageNamed:@"Search_Bar_IconSearch.png"];
}

+ (UIImage *)searchBarIconVoiceImageWithState:(UIControlState)state
{
    NSString *imageName = @"Search_Bar_IconVoice";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)searchBarIconDeleteImageWithState:(UIControlState)state
{
    NSString *imageName = @"Search_Bar_IconDelete";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)searchBarIconChangeKeyBoardImageWithTag:(int)tag state:(UIControlState)state
{
    NSString *imageName = @"Search_Bar_IconSystem";
    if (tag == 1) {
        imageName = @"Search_Bar_IconT9";
    }
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)searchBackgroundT9GuideImage
{
    return [self imageNamed:@"Search_T9_Guide.png"];
}

#pragma mark - Prompt

+ (UIImage *)promptArrowImageWithDirection:(int)direction
{
    NSString *imageName = @"Prompt_Arrow_Down.png";
    if (direction == 0) {
        imageName = @"Prompt_Arrow_Up.png";
    }
    return [self imageNamed:imageName];
}

#pragma mark - Tool

+ (UIImage *)toolDefaultPersonSelectImage
{
    return [self imageNamed:@"Tool_PersonSelect_Default.png"];
}
#pragma mark - Login and scrollview
+ (UIImage *)ScroViewBgImage1
{
    return [self imageNamed:@"Login_Picture1.png"];
}

+ (UIImage *)ScroViewBgImage2
{
    return [self imageNamed:@"Login_Picture2.png"];
}

+ (UIImage *)ScroViewBgImage3
{
    return [self imageNamed:@"Login_Picture3.png"];
}

+ (UIImage *)ScroViewCutOver1
{
    return [self imageNamed:@"Login_cutoverB.png"];
}

+ (UIImage *)ScroViewCutOver2
{
    return [self imageNamed:@"Login_cutoverA.png"];
}

+ (UIImage *)LoginImageCloud
{
    return [self imageNamed:@"Login_Cloud-House.png"];
}

+ (UIImage *)LoginPassWord
{
    return [self imageNamed:@"Login_icon-Password.png"];
}

+ (UIImage *)LoginUserName
{
    return [self imageNamed:@"Login_icon-Username.png"];
}

+ (UIImage *)LoginUserNamecloud
{
    return [self imageNamed:@"Login_icon-cloud.png"];
}

#pragma mark - Person

+ (UIImage *)personDetailMailImage
{
    return [self imageNamed:@"Person_Detail_Mail.png"];
}

+ (UIImage *)personDetailPhoneImage
{
    return [self imageNamed:@"Person_Detail_Phone.png"];
}

+ (UIImage *)personDetailFavImageWithState:(UIControlState)state
{
    NSString *imageName = @"Person_Detail_Fav";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)personDetailBackgroundImage
{
    return [self imageNamed:@"user_img_bg.png"];
}

#pragma mark - Setting

+ (UIImage *)settingXTIconImage
{
    return [self imageNamed:@"Setting_Icon_XT.png"];
}

+ (UIImage *)settingSetIconImage
{
    return [self imageNamed:@"Setting_Icon_Setting.png"];
}

+ (UIImage *)settingFeedbackIconImage
{
    return [self imageNamed:@"Setting_Icon_Feedback.png"];
}

#pragma mark - Guide

+ (UIImage *)guideContentImageWithTag:(int)tag
{
    return [self imageNamed:[NSString stringWithFormat:@"Guide_Content_%d",tag]];
}

+ (UIImage *)guideButtonNextImgaeWithState:(UIControlState)state
{
    NSString *imageName = @"Guide_Button_Next";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)guideButtonPreviousImgaeWithState:(UIControlState)state
{
    NSString *imageName = @"Guide_Button_Previous";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)guideButtonStartImgaeWithState:(UIControlState)state
{
    NSString *imageName = @"Guide_Button_Start";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)guideButtonShareImgae
{
    return [self imageNamed:@"Guide_Button_Share.png"];
}

#pragma mark - About

+ (UIImage *)aboutApplicationIconImage
{
    return [self imageNamed:@"About_ApplicationIcon.png"];
}

+ (UIImage *)aboutKingdeeLogoImage
{
    return [self imageNamed:@"About_KingdeeLogo.png"];
}

#pragma mark - QR

+ (UIImage *)qrLoginXTWebImage
{
    return [self imageNamed:@"message_img_loginweb.png"];
}

+ (UIImage *)qrLoginMyKingdeeImage
{
    return [self imageNamed:@"QR_Login_ThirdPart.png"];
}

+ (UIImage *)qrButtonScanImageWithState:(UIControlState)state
{
    NSString *imageName = @"Button_QR_Scan";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [[self imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 24.0, 28.0, 34.0)];
}

+ (UIImage *)deleteButtonImageWithState:(UIControlState)state
{
    NSString *imageName = @"Invite_Delete";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_Highlight.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [[self imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 24.0, 28.0, 34.0)];
}




+ (UIImage *)newsBackgroundImage
{
     return [[self imageNamed:@"message_text_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(79.0, 10, 78.0, 10)];
}

#pragma mark - Share

+ (UIImage *)shareOKImage
{
    return [self imageNamed:@"Share_OK.png"];
}

+ (UIImage *)publicheadimage
{
    return [self imageNamed:@"college_img_public.png"];
}

+ (UIImage *)chatImage
{
    return [self imageNamed:@"Contact_chat.png"];
}
+ (UIImage *)phoneImage
{
    return [self imageNamed:@"Contact_phone.png"];
}
+ (UIImage *)XTappShadeImage
{
    return [self imageNamed:@"XTapp_shade_background.png"];
}
+ (UIImage *)addAppImageWithState:(UIControlState)state
{
    NSString *imageName = @"app_addimage.png";
    if (state == UIControlStateHighlighted) {
        imageName = @"app_addimage_Highlight.png";
    }
    return [self imageNamed:imageName];
}

+ (UIImage *)personInfoBtnWithState:(UIControlState)state
{
    NSString *imageName = @"Setting_infobtn_backgroud";
    if (state == UIControlStateHighlighted) {
        imageName = [imageName stringByAppendingString:@"_hl.png"];
    } else {
        imageName = [imageName stringByAppendingString:@".png"];
    }
    return [self imageNamed:imageName];
}

#pragma mark -- Public
+ (UIImage *)menuFlagImage
{
    return [self imageNamed:@"menu_flag.png"];
}

@end
