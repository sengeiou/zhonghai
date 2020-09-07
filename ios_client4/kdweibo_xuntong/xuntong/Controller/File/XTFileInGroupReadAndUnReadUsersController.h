//
//  XTFileInGroupReadAndUnReadUsersController.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/9.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTFileInGroupReadAndUnReadUsersController : UIViewController
@property (nonatomic, strong) NSMutableArray *personArray;
@property (nonatomic, strong) NSString *threadId;
@property (nonatomic, strong) NSString *fileId;
@property (nonatomic, strong) NSString *messageId;
@end
