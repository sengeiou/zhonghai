//
//  KDChooseConfigModel.h
//  kdweibo
//
//  Created by kyle on 16/9/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOSBaseDataModel.h"
#import "KDContactGroupDataModel.h"
//#import "KDMeetingModel.h"


@interface KDChooseConfigModel : BOSBaseDataModel

@property (nonatomic, strong) NSString *titleString;              /**< 设置title 默认 ： 选择联系人 */
@property (nonatomic, assign) BOOL canShowSectionIndexTitle;    /**< 是否展示 索引 */

@property (nonatomic, assign) BOOL isMultChooseGroup; /**< 是否多选群组 默认 NO 多选*/

//voice meeting
@property (nonatomic, strong) id meetingModel;
@property (nonatomic, assign) BOOL isVoiceMeeting;


@property (nonatomic, assign) BOOL animated;

@property (nonatomic, assign) BOOL isMultChoose;    /**< 是否多选 默认 YES 多选*/
@property (nonatomic, assign) BOOL canShowSelf;     /**< 是否展示自己 默认 NO 不展示自己*/
@property (nonatomic, assign) BOOL topGroupIsExtenalGroup;  /**< 已有群组是否包含外部群组 */

@property (nonatomic, strong) NSArray *selectedPersons; /**< 已经选择了的人 里面传openid*/
@property (nonatomic, strong) NSArray *blackList;       /**< 需要忽略的人 里面传openid*/
@property (nonatomic, strong) NSArray *range;           /**< 选人的选择范围，里面传openid * 有，则数据源独立于 A B 方案 */
@property (nonatomic, strong) NSMutableArray *dataSources; /*KDChoosePersonTopItemType*/

@property (nonatomic, assign) int minSelect;     /**< minSelect = 0 即表示可以空选 默认 是1*/
@property (nonatomic, assign) int maxSelect;

@property (nonatomic, assign) BOOL isNeedWechatInvite; /**< 是否需要显示微信邀请  值传递 用于外部好友页面*/

/// 设置了范围也显示顶部的选项
@property (nonatomic, assign) BOOL showTopSectionWhenHasRange;

@property (nonatomic, strong) NSArray <UIView *>*fullScreenTips; /**< 全屏的Tip引导view default nil */
@property (nonatomic, strong) KDContactGroupDataModel *groupData;
//@property (nonatomic, assign) KDChoosePersonType choosePersonType;

@property (nonatomic, assign) BOOL isCreateOrAddPerson;

@property (nonatomic, assign) BOOL isCreateGroup;

//crm选组桥
@property (nonatomic, assign) BOOL isOnlyChooseGroup; /**< 仅选群组 默认 NO */
@property (nonatomic, strong) NSString *searchKeyWords;

-(id)init;

@end
