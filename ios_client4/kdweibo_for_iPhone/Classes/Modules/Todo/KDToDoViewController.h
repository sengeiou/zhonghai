//
//  KDToDoViewController.h
//  kdweibo
//
//  Created by janon on 15/4/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDTitleNavView.h"

typedef NS_ENUM(NSInteger, KDToDoViewControllerType)
{
    KDToDoViewControllerType_Normal = 0,
    KDToDoViewControllerType_Special = 1,
    KDToDoViewControllerType_Search = 2
};

@class GroupDataModel;
@class KDToDoMessageDataModel;

@interface KDToDoViewController : UIViewController<UIAlertViewDelegate>
@property (nonatomic, assign) KDToDoViewControllerType type;

@property (nonatomic, assign) KDToDoViewControllerType state;;
@property (nonatomic, strong) NSMutableArray *todoArray;
@property (nonatomic, strong) KDTitleNavView *titleNavView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *searchKeyWord;

@property (nonatomic, strong) KDSearchBar *searchBar;

-(instancetype)initWithGroup:(GroupDataModel *)group;
-(void)sortNewDataWithModel:(KDToDoMessageDataModel *)model;
-(void)sortAllData;

- (void)loadOnePageAtViewDidLoad;

-(void)sortSearchDataWithText:(NSString *)text;


- (void)fetchTodoDataFromNet:(NSString *)msgId;
- (void)getOnePageFromDBWithMsgId:(NSString *)msgId
                     countPerPage:(int)countPerPage
                         todoType:(NSString *)type
                        direction:(MessagePagingDirection)direction
                       completion:(void(^)(NSArray *todoData))completionBlock;
@end
