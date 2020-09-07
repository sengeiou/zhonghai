//
//  KDPersonAppListView.h
//  kdweibo
//
//  Created by fang.jiaxin on 15/8/20.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDPersonalAppView.h"

@interface KDPersonAppListView : UIScrollView<KDPersonalAppViewDelegate>

@property (nonatomic,weak)id <KDPersonalAppViewDelegate> appDelegate;
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic,strong)NSMutableArray *viewArray;
@property (nonatomic,strong)NSMutableArray *rectArray;
@property (nonatomic,strong)KDPersonalAppView *tempAppView;
@property (nonatomic,assign)CGRect lastFrame;
@property (nonatomic,assign)BOOL isEditing;

-(CGPoint)getNextIconLocation;
-(CGSize)getIconSize;
-(int)getCountOneCell;

-(NSMutableArray *)getSortDataArray;
-(NSMutableArray *)getSortAppIdsArray;
@end
