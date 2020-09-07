//
//  KDAppDetailViewController.h
//  kdweibo
//
//  Created by AlanWong on 14-9-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    KDAppSourceTypeCentre = 0,     //应用中心
    KDAppSourceTypeRecommend ,     //推荐应用
    KDAppSourceTypeSearch          //搜索应用
}KDAppSourceType;//从哪个模块进入到应用详情

@class KDAppDataModel;
@interface KDAppDetailViewController : UIViewController
- (id)initWithAppDataModel:(KDAppDataModel * )appDataModel;
@property (nonatomic, assign) BOOL hasFavorite;
@property (nonatomic,assign)KDAppSourceType sourceType;

@end
