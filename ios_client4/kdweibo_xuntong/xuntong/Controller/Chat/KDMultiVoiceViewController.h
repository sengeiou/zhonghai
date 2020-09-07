//
//  KDMultiVoiceViewController.h
//  kdweibo
//
//  Created by wenbin_su on 15/7/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroupDataModel;

@interface KDMultiVoiceViewController : UIViewController
//@property (nonatomic, strong) NSMutableArray *personIdArray;
//@property (nonatomic, assign) NSInteger personCount;
//@property (nonatomic, strong) UIViewController *desController;
//-(instancetype)initWithGroupName:(NSString *)groupName;
@property (nonatomic, strong) GroupDataModel *groupDataModel;
@property (nonatomic, assign) BOOL isCreatMyCall;//没有会议  直接创建
@property (nonatomic, assign) BOOL isJoinToChannel;//已存在会议直接加入
@property (nonatomic, strong) UIViewController *desController;
@end
