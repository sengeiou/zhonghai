//
//  RecommendTableView.h
//  EMPNativeContainer
//
//  Created by Gil on 13-3-15.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

typedef enum _RecommendType {
    RecommendTypeField = 0,
    RecommendTypeOther = 1
}RecommendType;

@interface RecommendViewController : UIViewController <MBProgressHUDDelegate,
                                    UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,assign) RecommendType type;

- (id)initWithRecommendType:(RecommendType)type;

@end
