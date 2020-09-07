//
//  RecommendAppListCell.h
//  EMPNativeContainer
//
//  Created by Gil on 13-3-15.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendAppListDataModel.h"
#import "UIImageView+WebCache.h"

@interface RecommendAppListCell : UITableViewCell {
    UIImageView *_appIcon;
    UILabel *_appName;
    UIImageView *_newImageView;
    UILabel *_appDesc;
    UIButton *_tryButton;
    
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel *_moreLabel;
}

@property (nonatomic,retain) RecommendAppDataModel *appInfo;

@end
