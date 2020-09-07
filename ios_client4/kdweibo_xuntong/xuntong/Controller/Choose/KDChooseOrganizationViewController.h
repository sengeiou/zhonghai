//
//  KDChooseOrganizationViewController.h
//  kdweibo
//
//  Created by shen kuikui on 14-5-14.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDNoItemView.h"
@class XTSelectPersonsView;
@class KDChooseOrganizationViewController;

typedef NS_ENUM(NSInteger, KDChooseOrganizationType)
{
    selectOrg = 1,
    selectDepts,
    selectPersons
};

@protocol KDChooseOrganizationViewControllerJSBridgeDelegate <NSObject>
@optional
-(void)selectOrgArray:(NSArray *)groups;
-(void)selectDeptsArray:(NSArray *)groups;
-(void)cancelSelect;
@end

@interface KDChooseOrganizationViewController : UIViewController

- (id)initWithOrgId:(NSString *)orgId isForCurrentUser:(BOOL)yesOrNo;

@property (nonatomic, strong) KDNoItemView *noItemView;
@property (nonatomic, strong) XTSelectPersonsView *selectedPersonsView;
@property (nonatomic, assign) BOOL blockCurrentUser;

@property (nonatomic, strong) NSString *adduserType;

@property (nonatomic, assign) BOOL isMult;
@property (nonatomic, assign) KDChooseOrganizationType JSBridgeType;
@property (nonatomic, strong) NSMutableArray *blackList;
@property (nonatomic, strong) NSMutableArray *whiteList;

@property (nonatomic, strong) NSMutableArray *JSBridgeSelectPersonsBlackList;
@property (nonatomic, assign) NSInteger partnerType;
@property (nonatomic, assign) NSInteger pType;
@property (nonatomic, assign) BOOL isFilterTeamAcc;
@property (nonatomic, weak) id <KDChooseOrganizationViewControllerJSBridgeDelegate> JSBridgeDelegate;

//语音会议
@property (nonatomic, assign) BOOL inviteFromAgora;
@property (nonatomic, strong) NSArray  *selectedAgoraPersons; //已经选择了的参会人员

@end
