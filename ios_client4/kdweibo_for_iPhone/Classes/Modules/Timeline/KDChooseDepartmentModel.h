//
//  KDChooseDepartmentModel.h
//  kdweibo
//
//  Created by DarrenZheng on 14-7-10.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDChooseDepartmentModel : NSObject

@property(nonatomic, copy) NSString *strID;
@property(nonatomic, copy) NSString *strParentID;
@property(nonatomic, copy) NSString *strName;

@property(nonatomic, assign) BOOL checked;
@property(nonatomic, assign) BOOL bIsLeaf;
@property(nonatomic, copy) NSString *strWeights;
@property(nonatomic, assign) NSInteger personCount;
//@property (weak , nonatomic , readonly) KDChooseDepartmentModel *parentModel;  //父亲
@property (strong , nonatomic , readonly) NSArray *childrenDep;   //孩子部门
//@property (strong , nonatomic) NSMutableArray *selectedChildrnt;   //选中的孩子部门
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


/**
 *  遍历寻找子部门
 *
 *  @param departments 所有部门
 *
 *  @return 子部门
 */
- (NSArray *)findChildrenWithAllDepartments:(NSArray *)departments;

/**
 *  选择或取消选择整个部门
 *
 *  @param checked 是否选择
 */
//- (void)setTheWholeDepartmentChecked:(BOOL)checked;
@end
