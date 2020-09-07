//
//  XTContentViewController.h
//  XT
//
//  Created by Gil on 13-7-19.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSearchBar.h"

/**
 *	@brief	内容分组显示视图,只提供一些基本的组件,实际的逻辑由子类实现
 *          子类:XTContactContentViewController , XTChooseContentViewController
 */

typedef enum{
    KDContactViewStateNormal = 0,  //正常状态
    KDContactViewStateSearch       //搜索状态
} KDContactViewState;


typedef enum {
    KDContactViewShowTypeNone = 0,     //没有设置
    KDContactViewShowTypeAll ,         //显示所有联系人  （人少的情况 <100）
    KDContactViewShowTypeRecently      //显示最近联系人  （人多的情况）
}KDContactViewShowType;     //通讯类显示方法


@interface XTContentViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,KDSearchBarDelegate>{
@public
    KDContactViewState state_;
    KDContactViewShowType showType;  //控制联系人界面的显示
    
    NSInteger needsToLayoutTableView_;
    
    struct {
        unsigned int initialized:1;
        
        unsigned int searching:1;
        unsigned int forceCancelled:1;
        
        unsigned int favoritedContactsMask;
        unsigned int searchContactsMask;
        
    }personViewControllerFlags_;
    
}

//UI
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) KDSearchBar *kdSearchBar;
@property (nonatomic, strong) NSArray *leftBarItems;


//Data
@property (nonatomic, strong) NSMutableArray *contents;
@property(nonatomic, strong) NSMutableArray *displayContacts;

@property (nonatomic) BOOL isFromConversation;
@property (nonatomic) BOOL isFromTask;
@property (nonatomic, assign) BOOL isFilterTeamAcc;

//Method
- (void)initContents;
- (void)reloadContents;

- (void)processSearchResultsBeforeReload;

- (id)initWithInitContents;

@end
