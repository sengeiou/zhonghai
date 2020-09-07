//
//  KDSignInRecord.h
//  kdweibo_common
//
//  Created by 王 松 on 13-8-23.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

typedef enum KDSignInStatus{
    kKDSignInStatusFaild = 0,
    kKDSignInStatusSuccess = 1,
    KDSignInStatusSetNoPoint = 2,
    KDSignInStatusHaveNoLink = 3,
    KDSignInStatusSuccessForOfficeWork = 4
}KDSignInStatus;

typedef NS_ENUM(NSInteger, KDSignInSuccessType) {
    KDSignInSuccessType_internal,
    KDSignInSuccessType_customExternal,
    KDSignInSuccessType_adminExternal,
    KDSignInSuccessType_custom
};

typedef NS_ENUM(NSInteger, KDSignInManualType) {
    KDSignInManualType_neiQin = 1,
    KDSignInManualType_waiQin,
    KDSignInManualType_custom
};
#define KDSignInClockTypeArray @[@"manual",@"auto"]

#import "KDObject.h"
@interface KDSignInRecord : KDObject

/**
 *  主键ID
 */
@property(nonatomic, retain) NSString *singinId;

/**
 *  签到地点
 */
@property(nonatomic, retain) NSString *featurename;

/**
 *  签到返回的内容
 */
@property(nonatomic, retain) NSString *content;

/**
 *  状态：1表示合法，0表示不合法 2 未设置签到点 3 当前wifi与签到点未建立连接 -1  失败
 */
@property(nonatomic, assign) NSInteger status;

/**
 *  签到时间
 */
@property(nonatomic, retain) NSDate *singinTime;

/**
 *  经度
 */
@property(nonatomic, assign) float latitude;

/**
 *  纬度
 */
@property(nonatomic, assign) float longitude;

/**
 *  纬度
 */
@property(nonatomic, retain) NSString *mbShare;

/**
 *  外勤所填内容
 */
@property(nonatomic, retain) NSString *message;

@property(nonatomic, assign) KDSignInSuccessType recordType;

@property (nonatomic, retain) NSString *ssid;
@property (nonatomic, retain) NSString *bssid;
@property (nonatomic, retain) NSString *clockInType; //签到类型(wifi手动manual/wifi自动auto/会话签到session/拍照签到photo)

//@property (nonatomic, retain) NSString *attendSetName;
@property (nonatomic, retain) NSString *attendSetId;
//@property (nonatomic, assign) BOOL needRelativeWiFi;

//@property (nonatomic, assign) BOOL canAutoClockIn;//能否启用自动打卡
@property (nonatomic, assign) NSInteger inCompany;
@property (nonatomic, retain) NSString *managerOId;
@property (nonatomic, retain) NSString *cachesUrl;
@property (nonatomic, retain) NSString *photoIds;
@property (nonatomic, retain) NSString *featurenamedetail;
@property (nonatomic, assign) float org_latitude;
@property (nonatomic, assign) float org_longitude;
@property (nonatomic, assign)KDSignInManualType manualType;
@property (nonatomic, retain) NSString *address;

@property (nonatomic, retain) NSString *extraRemark;
@property (nonatomic, retain) NSString *clockInTypeStr;
@property (nonatomic, strong) NSDictionary *medalDic;
@property (nonatomic, strong) NSDictionary *attendanceTipsDic;
@property (nonatomic, strong) NSDictionary *attendanceActivityDic;

/**
 *  异常反馈
 */
@property (nonatomic, strong) NSString *exceptionType;      //异常类型：早退："EARLYLEAVE",迟到："LATE",外勤反馈："OUT_WORK",缺勤（未签到）："ABSENCE",迟到早退："LATE,EARLYLEAVE"
@property (nonatomic, assign) float    exceptionMinitues;   //迟到／早退分钟数
@property (nonatomic, strong) NSString *workTime;           //规定上班／下班时间
@property (nonatomic, assign) NSInteger hasLeader;           //是否有签到负责人,0为有负责人,1为无负责人,2为异常
@property (nonatomic, strong) NSString *exceptionFeedbackReason;//异常反馈标签文案，以英文逗号","作为分隔符

@end
