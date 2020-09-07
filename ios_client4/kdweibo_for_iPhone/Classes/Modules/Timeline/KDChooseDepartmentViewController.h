//
//  KDChooseDepartmentViewController.h
//  kdweibo
//
//  Created by DarrenZheng on 14-7-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDChooseDepartmentModel.h"
typedef enum{
    KDChooseDepartmentVCFromType_Native,
    KDChooseDepartmentVCFromType_JSBridge,
    KDChooseDepartmentVCFromType_SelectAppPermission,
    
    KDChooseDepartmentVCFromType_EditPerson,
}KDChooseDepartmentVCFromType;

#pragma mark - Public Delegate -

/**
 *  公有delegate, 从这里取得结果
 */
@protocol KDChooseDepartmentViewControllerDelegate <NSObject>
@optional

/**
 *  回调
 *
 *  @param model    部门对象
 *  @param longName 部门全称,格式为:ASLocalizedString(@"金蝶国际!移动平台事业部!研发部")
 */
- (void)didChooseDepartmentModels:(NSArray *)models longName:(NSString *)longName;

//这个回调只为了管理员工资料页面
- (void)didChooseDepartmentForEditPer:(NSArray *)models longName:(NSString *)longName;
@end

#pragma mark - Private delegate -


#pragma mark - Interface -

@interface KDChooseDepartmentViewController : UIViewController
/**
 *  代理
 */
@property(nonatomic, weak) id <KDChooseDepartmentViewControllerDelegate> delegate;

@property(nonatomic, strong) KDChooseDepartmentModel *parentModel;
@property(nonatomic, copy) NSString *cacheLongName;
@property (assign , nonatomic) KDChooseDepartmentVCFromType fromType;
@property(nonatomic, copy) NSString *haveChooseDepartment;
@property (assign , nonatomic) BOOL isMulti;   //是否可以多选
@property (assign , nonatomic) BOOL isPartTime;   //是否是兼职

- (void)setSelectedDepartments:(NSArray *)selectedDepartments;

@end
