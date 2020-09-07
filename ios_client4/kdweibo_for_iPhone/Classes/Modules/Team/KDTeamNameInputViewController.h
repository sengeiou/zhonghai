//
//  KDTeamNameInputViewController.h
//  kdweibo
//
//  Created by bird on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCompanyDelegate.h"

@interface KDTeamNameInputViewController : UIViewController

@property (nonatomic, assign) id<XTCompanyDelegate> delegate;

- (id)initWithEId:(NSString *)eid companyName:(NSString *)companyName;
@end
