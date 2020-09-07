//
//  KDWIFIListController.h
//  kdweibo
//
//  Created by lichao_liu on 1/27/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^KDWIFIListControllerBlock)(NSMutableArray *wifiArray);
@interface KDWIFIListController : UIViewController
@property (nonatomic, strong) NSMutableArray *wifiArray;
@property (nonatomic, copy) KDWIFIListControllerBlock block;
@end
