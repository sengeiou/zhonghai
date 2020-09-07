//
//  RecommendAppDetailViewController.h
//  EMPNativeContainer
//
//  Created by Gil on 13-3-15.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "RecommendAppListDataModel.h"

@class RecommendAppDataModel;
@interface RecommendAppDetailViewController : UIViewController <UIWebViewDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic,retain,readonly) RecommendAppDataModel *app;

- (id)initWithRecommendAppDataModel:(RecommendAppDataModel *)app;

@end
