//
//  KDSignInCreateAliasController.h
//  kdweibo
//
//  Created by lichao_liu on 15/4/13.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KDSignInCreateAliasBlock)(NSString *alias);
@interface KDSignInCreateAliasController : UIViewController

@property (nonatomic, strong) NSString *alias;
@property (nonatomic, copy) KDSignInCreateAliasBlock createAliasBlock;

@end
