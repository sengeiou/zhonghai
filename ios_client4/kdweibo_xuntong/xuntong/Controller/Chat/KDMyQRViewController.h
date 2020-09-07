//
//  KDMyQRViewController.h
//  kdweibo
//
//  Created by KongBo on 15/10/21.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDMyQRViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (strong, nonatomic) PersonSimpleDataModel *person;
@property (nonatomic, strong) GroupDataModel *group;

@property (nonatomic, assign) BOOL isNetworkQR;

@end
