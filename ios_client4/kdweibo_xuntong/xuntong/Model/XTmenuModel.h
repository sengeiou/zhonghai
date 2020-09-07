//
//  XTmenuModel.h
//  XT
//
//  Created by mark on 14-1-6.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//
#import "BOSBaseDataModel.h"
#import <UIKit/UIKit.h>

@interface XTmenuModel : BOSBaseDataModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSArray *sub;
@property (nonatomic, copy) NSString *ios;
@property (nonatomic, copy) NSString *appId;
@end
