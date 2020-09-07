//
//  KDApplicationCommon.h
//  kdweibo
//
//  Created by sevli on 15/9/1.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#ifndef kdweibo_KDApplicationCommon_h
#define kdweibo_KDApplicationCommon_h

#define RecommendCount          -1      //表示所有
#define kTableviewCellHeight    65.f
#define kSearchbarHeight        44.0f   //搜索栏高度

#define kQRScanName                 @"QRScan"
#define kFileTransName              @"FileTrans"
#define kYunzhijia                  @"Yunzhijia"
#define kTask                       @"KDTaskListViewController"
#define kSignIn                     @"KDSignInViewController"
#define kImageDefaultIcon           @"app_default_icon.png"
#define kNFReloadAppView            @"Notify_ReloadAppView"
#define kNFAddApp                   @"Personal_App_Add"
#define kNFremoveApp                @"Personal_App_Delete"

#define kSignAppId          @"900001"          // 签到
#define kQRScanAppId        @"800001"          // 扫一扫
#define kFileTransAppId     @"900003"          // 文件
#define kTaskAppId          @"900002"          // 任务
#define kBuluoAppId         @"103"             // 部落
#define kLeaveAppId         @"1010914"         // 请假
#define kApprovalId         @"10104"           // 审批
#define kReportAppId        @"101091429"       // 工作汇报
#define kAnnouncementAppId  @"101091432"       // 公告
#define kTalkmeeting        @"101091433"       // 语音会议
#define KDKingdeeYun        @"101091498"       // 金蝶云盘
#define kWorkbenchAppID     @"101091520"       // 工作台

#define KMicroSaleAppId          @"10457"    //微订货



#define kKeyAppClientID             @"appClientId"
#define kAppViewOrigin(x, y)         CGRectMake(x, y, kAppViewWidth, kAppViewHeight)
#define kAppIconWidth               48                       //已添加应用图标宽
#define kAppIconHeight              48                       //已添加应用图标高
#define kAppViewWidth               (kAppIconWidth + 7 * 4)     //已添加应用视图的宽 （左右边距 ＋ 图标宽度）
#define kAppViewHeight              (12 + kAppIconWidth + 38)   //已添加应用视图的高 （上边距 ＋ 图标高度 ＋ 下边距
#define kAppViewXMagin              10                          //已添加应用视图的横向间距  （图标间距 － 视图内图标的左右连距）
#define kAppViewStartX              10                          //已添加应用视图的第行的x起始坐标
#define kTopMargin                  6.0f                        //最上边的间距
#define kWholeViewBGHeight          MainHeight - 44 - 44 - 5    //应用整个视图的高度 (手机屏幕高度 － 导航栏高 － 切换页签高 － 搜索栏高 － 调整高度
#define kTableViewCellHeight        80.0f                       //应用推荐表格的行高
#define kHeaderInsectionHeight      (float)20.f                 //应用推荐表格的标题栏高度
#define kViewTableMagin             (float)10.f                 //已添加应用区域与应用推荐表格的间距
#define kRecommendCount             3                           //推荐应用的最大条数
#define kInternalAppClientID        @"-1"                       //内置应用的id标识

#define kDNotifyLight [NSString stringWithFormat:@"NotifyLight_%@_%@", [BOSConfig sharedConfig].user.openId, [BOSConfig sharedConfig].user.eid]

/**
 重新写了 appViewController布局     -------2015-09-01------- 李文博
 */

#define MAX_COUNT_INLINE 4 //(isiPhone6Plus||isiPad?4:3) //单行图标数量

#define DISTANCE (CGRectGetWidth(self.view.frame) - MAX_COUNT_INLINE* kAppViewWidth)/(MAX_COUNT_INLINE + 1) //左右间隔

#define KAppView_orginX(a)  ((a%MAX_COUNT_INLINE+1)*DISTANCE + a%MAX_COUNT_INLINE *kAppViewWidth) //图标orginX

#define KAppView_orginY(a)  ((a/MAX_COUNT_INLINE+1)*kTopMargin + a/MAX_COUNT_INLINE *kAppViewHeight) //图标orginY

#define KAppView_rect(a)  CGRectMake(KAppView_orginX(a), KAppView_orginY(a), kAppViewWidth, kAppViewHeight) //图标Frame

#define KAppView_Edit_orginY(a)  ((a/MAX_COUNT_INLINE+1)*kTopMargin + a/MAX_COUNT_INLINE *kAppViewHeight)

#define KAppView_Edit_rect(a) CGRectMake(KAppView_orginX(a), KAppView_Edit_orginY(a), kAppViewWidth, kAppViewHeight)


#define KAppViewScrollCondition 35.0f


#define kScroll_dis_scale 10

#define kScroll_max_speed 5

#define KSlideSwitchViewHeigh 40.0f

#define KAppViewFeaturesCellHeight 94.0f

#define KAppViewAppCellHeight 68.0f


#define KAppViewCategoryCellHeight 68.0f

#define KAppBrandScrollViewHeight (ScreenFullWidth*248.0/750.0)

#define KApplicationCornerRadius(side) (2.f/21.f*side)


/**
 sheet页item类型
 */
typedef enum : NSUInteger {
    
    KApplicationTableTypeFeatured = 1,  // 精品
    KApplicationTableTypeCategory,      // 分类
    KApplicationTableTypeSearch,        // 搜索
    KApplicationTableTypeCase,          // 案例
    KApplicationTableTypeOpened         // 企业已开通
} KApplicationTableType;


typedef enum : NSInteger {
    KDOpenCellButtonType_None = -1,
    KDOpenCellButtonType_Open = 1,    //打开
    KDOpenCellButtonType_Add    //添加
} KDOpenCellButtonType;

typedef enum : NSInteger {
    KDOpenCellTypeNone = -1,
    KDOpenCellTypeNormal = 1,        // 普通用户应用列表
    KDOpenCellTypeAdmin,             // 管理员应用列表
    KDOpenCellTypeOpened_All,        // 企业已开通
    KDOpenCellTypeMore,              // 普通用户更多应用列表
    KDOpenCellTypeOther,
} KDOpenCellType;

typedef enum : NSUInteger {
    KDApplicationType_Default,     //我的企业应用
    KDApplicationType_Custom,       //个人自选应用
    KDApplicationType_EnterOpened,      //企业已开通应用
    KDApplicationType_YZJ_Recommend,   //云之家推荐应用
} KDApplicationType;




#pragma mark - Notification

extern NSString * const KDApplicationNeedUpdateCompleteNotification;     //轻应用轮询update完成
extern NSString * const KDCompanyOpenedApplicationNeedUpdateCompleteNotification;     //企业已开通应用轮询update完成



#endif
