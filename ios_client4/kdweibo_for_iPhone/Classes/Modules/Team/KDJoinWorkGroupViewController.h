//
//  KDJoinWorkGroupViewController.h
//  kdweibo
//
//  Created by bird on 14-9-23.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KDJoinWorkGroupViewControllerDelegate <NSObject>

- (void)joinWorkGroupViewDidCreateCompany;
- (void)joinWorkGroupViewDidJoinCompany:(NSString *)eid;
@end

@interface KDJoinWorkGroupViewController : UIViewController
@property (nonatomic, retain) NSArray *datas;
@property (nonatomic, assign) id delegate;
@end
