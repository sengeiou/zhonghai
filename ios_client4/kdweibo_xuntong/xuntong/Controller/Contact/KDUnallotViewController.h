//
//  KDUnallotViewController.h
//  kdweibo
//
//  Created by Gil on 15/2/11.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XTSelectPersonsView;
@interface KDUnallotViewController : UIViewController
@property (nonatomic, assign) BOOL blockCurrentUser;
@property (nonatomic, strong) XTSelectPersonsView *selectedPersonsView;
@property (nonatomic, strong) NSArray *orgPersons;
@end
