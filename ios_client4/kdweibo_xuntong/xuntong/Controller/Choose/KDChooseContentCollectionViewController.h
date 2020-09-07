//
//  KDChooseContentCollectionViewController.h
//  kdweibo
//
//  Created by shen kuikui on 14-5-13.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTSelectPersonsView.h"

typedef NS_ENUM(NSInteger, KDChooseContentType)
{
    KDChooseContentNormal,
    KDChooseContentDelete,
    KDChooseContentTransferManager,
    KDChooseContentAtSomeOne
};


@interface KDChooseContentCollectionViewController : UIViewController

@property (nonatomic, assign) KDChooseContentType type;
@property (nonatomic, retain) NSArray *collectionDatas;
@property (nonatomic, retain) XTSelectPersonsView *selectedPersonsView;
@property (nonatomic, assign) BOOL blockCurrentUser;

@property (nonatomic, assign) BOOL needUmeng;
// 默认为YES
@property (nonatomic, assign) BOOL bShowSelectAll;

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) NSInteger pType;


//语音会议为了添加那个提示
@property (nonatomic, assign) BOOL inviteFromAgora;

@property (nonatomic, strong) NSArray  *selectedAgoraPersons; //已经选择了的参会人员

@end
