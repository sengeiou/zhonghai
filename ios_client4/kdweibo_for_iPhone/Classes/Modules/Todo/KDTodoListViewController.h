//
//  KDTodoListViewController.h
//  kdweibo
//
//  Created by bird on 13-7-4.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDRefreshTableView.h"
#import "KDTitleNavView.h"

enum TodoType{
    
    kTodoTypeUndo =1,
    kTodoTypeDone,
    kTodoTypeIgnore,
    kTodoTypeCreate
};

typedef enum TodoType TodoType;

@interface KDTodoListViewController : UIViewController<KDRefreshTableViewDataSource, KDRefreshTableViewDelegate,KDTitleNavViewDelegate>
{
    KDRefreshTableView  *_tableView;
    NSMutableArray      *_listArray;
    
    struct
    {
        unsigned int pageIndex;
        unsigned int pageSize;
        
        BOOL        isSearch;
        
        double  latestTime;
        double  farestTime;
        
    }_flag;
}

@property(nonatomic,strong)KDTitleNavView *titleNavView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIButton *btn;
- (id)initWithTodoType:(TodoType)type;
@end
