//
//  KDCommon.h
//  kdweibo
//
//  Created by Jiandong Lai on 12-3-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIButton+KDV6.h"


///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Common MACROs

#define __KDWEIBO_FOR_IPHONE_VERSION_18300__         183000     // v1.8.3
#define __KDWEIBO_FOR_IPHONE_VERSION_18400__         184000     // v1.8.4
#define __KDWEIBO_FOR_IPHONE_VERSION_18500__         185000     // v1.8.5
#define __KDWEIBO_FOR_IPHONE_VERSION_18600__         186000     // v1.8.6
#define __KDWEIBO_FOR_IPHONE_VERSION_18700__         187000     // v1.8.7
#define __KDWEIBO_FOR_IPHONE_VERSION_18800__         188000     // v1.8.8

#define KD_IS_IPAD   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 

// UMeng app analyzer
#ifndef KDWEIBO_UMENG_ENABLED
#define KDWEIBO_UMENG_ENABLED   0
#endif

#define KDWKWebViewEnable 1
// type define

typedef long long KDInt64;
typedef unsigned long long KDUInt64;


#define ASLocalizedString(key)  [NSString stringWithFormat:@"%@", [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:nil table:@"ASLocalized"]]

#define AppLanguage  @"appLanguage"

// debug

#ifdef DEBUG

#define DLog(fmt, ...) NSLog((@"[%d] %s " fmt), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);

#else

#define DLog(...)

#endif

//[[[NSUserDefaults standardUserDefaults] objectForKey:@"xt_preference_ip"] length] > 0
#define Test_Environment YES

// about auth
#define KD_DEFAULT_APPNAME          @"kdweibo"
#define KD_APPNAME                  [[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] isEqualToString:@"zh-Hans"]?@"zh_CN":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]]) ofType:@"lproj"]] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"]
#define KD_DEFAULT_SERVER_URL           @" "

// kdweibo RESTful api base URL
#define KD_DEFAULT_REST_BASE_URL        @" "



//#define KD_DEFAULT_OAUTH_CONSUMER_KEY       @"UBLgpcoLlHpvzDqt"
//#define KD_DEFAULT_OAUTH_CONSUMER_SECRET    @"HTZRsEeQ664sXsFbc07Lm3sGK8WvLWAEMiJQUfVETc"

#define kNewsBigPictureHeight (ScreenFullWidth - 24) * 5 / 11.0 //单图文图片高度
//v4.0
#define KD_APP_KEY_IPHONE @"vIf3DAstj3ma5zq6"
#define KD_APP_SECRET_IPHONE @"0WQnGrSodwsMag8Lf6zgLj7cbb896uhtScM7qEd2Cd"

//V2.0h
//#define KD_APP_KEY_IPHONE @"Dkt6PaDq630NJD3R"
//#define KD_APP_SECRET_IPHONE @"BR9J34KgcSzK5PJss0v4KXUsMRqIXHnKv3YJUFrQD4"


//v1.0
//#define KD_APP_KEY_IPAD @"RpZKNlvTQDrcl0hH"
//#define KD_APP_SECRET_IPAD @"0cVPB6AKhw1VkAaxN2FLRdAGTIzqzC8aX7Uez6fiZJ"
// v2.0
#define KD_APP_KEY_IPAD @"fWEULOWadYiboRyU"
#define KD_APP_SECRET_IPAD @"odmcTjjQp13m5lBdO3KAynvgqIPpg6iMa9y9V7BQ4q"


#define KD_DEFAULT_OAUTH_CONSUMER_KEY       KD_IS_IPAD?KD_APP_KEY_IPAD:KD_APP_KEY_IPHONE
#define KD_DEFAULT_OAUTH_CONSUMER_SECRET    KD_IS_IPAD?KD_APP_SECRET_IPAD:KD_APP_SECRET_IPHONE

#define KD_DEFAULT_OAUTH_ACCESS_TOKEN       nil
#define KD_DEFAULT_OAUTH_ACCESS_SECRET      nil

#define KD_DEFAULT_OAUTH_REQUEST_TOKEN_URL          nil
#define KD_DEFAULT_OAUTH_AUTHORIZATION_TOKEN_URL    nil
#define KD_DEFAULT_OAUTH_ACCESS_TOKEN_URL           nil

// Safe releases


#define KD_RELEASE_SAFELY(obj_) { [obj_ release]; obj_ = nil; }

// color converter

#define RGBCOLOR(r, g, b)			[UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]
#define RGBACOLOR(r, g, b, a)		[UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

//消息页面 灰色背景色值
#define MESSAGE_BG_COLOR [UIColor colorWithRed:237/255.0f green:237/255.0f blue:237/255.0f alpha:1.0f]
//消息页面 白色衬底色值
#define MESSAGE_CT_COLOR [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f]
//消息页面 描边色值
#define MESSAGE_LINE_COLOR [UIColor colorWithRed:203/255.0f green:203/255.0f blue:203/255.0f alpha:1.0f]

//消息页面 主要文字
#define MESSAGE_TOPIC_COLOR [UIColor colorWithRed:62/255.0f green:62/255.0f blue:62/255.0f alpha:1.0f]
//消息页面 次一级文字
#define MESSAGE_NAME_COLOR [UIColor colorWithRed:109/255.0f green:109/255.0f blue:109/255.0f alpha:1.0f]
//消息页面 最次一级文字
#define MESSAGE_DATE_COLOR [UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0f]
//消息页面 次级文字
#define MESSAGE_ACTNAME_COLOR [UIColor colorWithRed:128/255 green:128/255 blue:128/255 alpha:1.0f]
//消息页面 日期
#define MESSAGE_ACTDATE_COLOR [UIColor colorWithRed:174/255 green:174/255 blue:174/255 alpha:1.0f]

#define UIColorFromRGB(rgbValue)	[UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 \
                                                            green:((float)(((rgbValue) & 0x00FF00) >> 8))/255.0 \
                                                            blue:((float)((rgbValue) & 0x0000FF))/255.0 \
                                                            alpha:1.0]


#define UIColorFromRGBA(rgbValue, alphaValue)		[UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 \
                                                                          green:((float)(((rgbValue) & 0x00FF00) >> 8))/255.0 \
                                                                          blue:((float)((rgbValue) & 0x0000FF))/255.0 \
                                                                          alpha:(alphaValue)]

// object common macros

#define KD_IS_NULL_JSON_OBJ(obj) ((obj) == nil || [NSNull null] == (obj))


// string common macros

#define KD_IS_BLANK_STR(str)    (((str) == nil) || ([@"" isEqualToString:(str)]))


#define KD_BLANK_STR_TO_NIL(str) (((str) == nil || [@"" isEqualToString:(str)]) ? nil : (str))

#define FORMATE_FORWARD_STATUS_TEXT(x,y)   (x)?[NSString stringWithFormat:@"%@: %@", (x), (y)]:(y)

#define KD_LOCALIZED_STRING_FUNC(key, comment)      NSLocalizedString(key, comment)
#define KD_LOCALIZED_STRING_FUNC_KEY_ONLY(key)      NSLocalizedString(key, @"")


#define KD_MAX_WEIBO_TEXT_LENGTH    1000   //微博限制字数

#define KD_MAX_WEIBO_TEXT_LENTH_IN_GROUP 1000  //小组微博限制字数


#define KD_MAX_DM_TEXT_LENTH     1000   // 短邮限制字数
#define all_chat_send_photo_compress_ratio 0.6

//////////////////////////////////////////////////////////////////
// CGRect
//////////////////////////////////////////////////////////////////

#pragma mark - CGRect

#define SetX(frame, x)               frame = CGRectMake(x, frame.origin.y, frame.size.width, frame.size.height)
#define SetY(frame, y)               frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height)
#define SetWidth(frame, w)           frame = CGRectMake(frame.origin.x, frame.origin.y, w, frame.size.height)
#define SetHeight(frame, h)          frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, h)
#define SetOrigin(frame, x, y)       frame = CGRectMake(x, y, frame.size.width, frame.size.height)
#define SetSize(frame, w, h)         frame = CGRectMake(frame.origin.x, frame.origin.y, w, h)
#define SetFrame(frame, x, y, w, h)  frame = CGRectMake(x, y, w, h)
#define AddX(frame, offset)          frame = CGRectMake(frame.origin.x + offset, frame.origin.y, frame.size.width, frame.size.height)
#define AddY(frame, offset)          frame = CGRectMake(frame.origin.x, frame.origin.y + offset, frame.size.width, frame.size.height)
#define AddHeight(frame, offset)     frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height+offset)
#define AddWidth(frame, offset)      frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width+offset, frame.size.height)
#define X(frame)                     frame.origin.x
#define Y(frame)                     frame.origin.y
#define Width(frame)                 frame.size.width
#define Height(frame)                frame.size.height
#define Origin(frame)                frame.origin
#define Size(frame)                  frame.size
#define SetCenterX(center, x)        center = CGPointMake(x, center.y)
#define SetCenterY(center, y)        center = CGPointMake(center.x, y)
#define MaxY(frame)                  CGRectGetMaxY(frame)
#define MaxX(frame)                  CGRectGetMaxX(frame)

#define CGRectFullScreen             CGRectMake(0, 0, ScreenFullWidth, MainHeight - NavigationBarHeight - TabBarHeight)
#define CGRectFullScreenWithoutNavigationBar    CGRectMake(0, 0, ScreenFullWidth, ScreenFullHeight)


// 状态栏的高度 20或44 （注意，要是statusBar隐藏时，这个值会变成 0 ）
#define kd_StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kd_StatusBarAndNaviHeight (44.0 + kd_StatusBarHeight)
#define kd_BottomSafeAreaHeight (isiPhoneX ? 34.0 : 0)

//////////////////////////////////////////////////////////////////
// Tester
//////////////////////////////////////////////////////////////////

#define SetBorder(view, color)      view.layer.borderColor = [color CGColor]; view.layer.borderWidth = 1
#define LogRect(frame)              NSLog(@"x(%.2f), y(%.2f), w(%.2f), h(%.2f)",frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)

#define AppWindow [[[UIApplication sharedApplication] delegate] window]


// common notification names
#pragma mark - common notification names
extern NSString * const KDDMThreadSubjectDidChangeNofication;

extern NSString * const KDDMThreadHasBeenDeleted;

extern NSString * const KDDMThreadHasBeenToped;

extern NSString * const  KDDMParticipantShouldDeleted;

extern NSString * const KDDMThreadHasBeenCancelTope;

extern NSString * const KDDMPaticipantGridCellAvatarDidTouched;

extern NSString * const KDGridCellAddingViewTouched;

extern NSString * const KDGridCellDeltingViewTouched;

extern NSString * const KDProfileUserAvatarUpdateNotification;

extern NSString * const KDProfileUserNameUpdateNotification;

extern NSString * const KDTeamTipsViewDidTapNotification;
//////////////////////////////////////////////////////////////////////////////

extern NSString *const KDNewFunctionContacts;

extern NSString * const KDWeiboSendErrorNotification;

extern NSString * const kKDPostViewControllerDraftSendNotification;

extern NSString * const kKDModalViewShowNotification;

extern NSString * const kKDModalViewHideNotification;

extern NSString * const kKDCommunityDidChangedNotification;

extern NSString * const  kKDStatusDetailShouldFresh;

extern NSString * const  kKDStatusShouldDeleted;

extern NSString * const kKDStatusOnPosting;

extern NSString * const  kKDStatusAttributionShouledUpdated;

extern NSString * const kKDTokenExpiredNotification;

extern NSString * const kKDMessageNoticeNumChangeNotification;

extern NSString * chineseWeek[];

#if!(TARGET_IPHONE_SIMULATOR)

 NSString *const KD_Share_Open_Link = @"kdweibo://";

#endif



#define kLeftNegativeSpacerWidth -0.f
#define kRightNegativeSpacerWidth -0.f

#define KApplicationCornerRadius(side) (14.f/55.f*side)

//所有头像圆角大小，设置－1为全圆(应用界面除外)
#define ImageViewCornerRadius -1

//应用界面头像圆角大小，设置－1为全圆
#define AppImageViewCornerRadius 14

//keys
#pragma mark - keys
#define kYZJPersonId @"XT-10000"    //云之家助手的personId
#define kFilePersonId   @"XT-0060b6fb-b5e9-4764-a36d-e3be66276586" //文件的personId
#define kSignInPublicAccountID      @"XT-0dad7306-714b-49ed-b24c-2512d5d46550"

//固定高德key：5f2af8e75444cfd42acd211fb90ef96c 脚本根据这个固定值替换，不能修改！
#define GAODE_MAP_KEY_IPHONE @"5f2af8e75444cfd42acd211fb90ef96c"
#define kTodoPersonId @"XT-10001" // 代办的personId
#define KD_TODOLIST_STATE_NOTIFICATION         @"kd_todolist_state_notification"

#define kNotShowInviteHint @"kNotShowInviteHint"
#define kContactMaskHidenForever @"kContactMaskHidenForever"
#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#define LightAppId_Appointment @"10001" // 预约语音会议的轻应用id
#define LightAppId_WXSQ @"80009" // 微信社区的轻应用appId

//以下几个key都是固定值，不可修改，脚本根据这个固定值替换
#define KD_WECHAT_APP_KEY @"wx6515426b438c7520"
#define KD_QQ_APP_KEY @"1101093724"
#define KD_Buluo_ConsumerKey @"4OBobmNyrDbedZhE"  // 微信社区key
#define KD_Buluo_ConsumerSecret @"yqLZfDN1nYEni20cnV2JKW1wQI2MUVo7Y8eoPdJqo6"  // 微信社区secret

#define kHeaderWidth_Big 48.f

#define USER_APP_PATH                 @"/User/Applications/"

#pragma mark -
#pragma mark - KDCommon class

@interface KDCommon : NSObject {
@private
    
}

+ (NSString *) visibleClientVersion;
+ (NSString *) clientVersion;
+ (NSString *) userAgent;
////add by lee
+ (NSString *) buildNo;
+ (NSString *) getCountly_Server;

+ (NSString *) readForceUpdateNo;

+ (BOOL) hasNewClientVersion;
+ (BOOL) needShowAppTutorials;

+ (void) openURLInApplication:(NSString *)appURL;

+ (NSInteger) initNewFunctionFlag;
+ (BOOL) isNewFunction:(NSString *)function;
+ (void)setNewFuctionflag:(NSString *)function isNew:(BOOL)isNew;
+ (NSInteger)versionLastBit;
+ (NSInteger)lastBitOfVersion:(NSString *)versionString;

+ (NSArray *)rightNavigationItemWithTitle:(NSString *)title target:(id)target action:(SEL)selector;

+ (NSArray *)leftNavigationItemWithTarget:(id)target action:(SEL)selector;

+ (BOOL)hasChinese:(NSString *)string;

+ (NSString *)getProjectCode;

+ (BOOL)isJailBreak;
@end


CGRect scaleRectToFitStage(CGRect contentRect, CGSize stageSize);
CGSize aspectScaleConstrainedSize(CGSize originalSize, CGSize constrainedSize);
CGRect textboundsByContrainedWidth(CGFloat width ,UIFont *font ,NSString *text);

