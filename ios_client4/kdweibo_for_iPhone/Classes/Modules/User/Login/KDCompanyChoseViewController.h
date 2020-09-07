//
//  KDCompanyChoseViewController.h
//  kdweibo
//
//  Created by bird on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCompanyDelegate.h"



@class XTOpenCompanyListDataModel;
@interface KDCompanyChoseViewController : UIViewController

@property (nonatomic, retain) XTOpenCompanyListDataModel *dataModel;
@property (nonatomic, weak) id<XTCompanyDelegate> delegate;
@end
