//
//  XTPersonDetailViewController.h
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonDataModel.h"
#import "XTPersonDetailHeaderView.h"

@interface XTPersonDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,XTPersonDetailHeaderViewDelegate>

@property (nonatomic,assign) BOOL ispublic;
@property (nonatomic,assign) BOOL isFromWeibo;    //是否从微博相关页面进入;
- (id)initWithPersonId:(NSString *)personId;
- (id)initWithSimplePerson:(PersonSimpleDataModel *)person with:(BOOL)ispublic;
- (id)initWithUserId:(NSString *)userId;
- (id)initWithScreenName:(NSString*)screenName;
@end
