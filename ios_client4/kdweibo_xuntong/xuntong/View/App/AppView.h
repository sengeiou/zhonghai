//
//  AppView.h
//  MobileFamily
//
//  Created by kingdee eas on 13-5-16.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@protocol AppViewDelegate <NSObject>
@optional
- (void)photoclick:(PersonSimpleDataModel *)publicDM;
@end

@interface AppView : UIView {
    
    UIImageView *appImageView;
    UIImageView *appImageBg;
    UILabel *appNameLabel;
}
@property (nonatomic,retain)UILabel *appNameLabel;
@property (nonatomic,retain)PersonSimpleDataModel *viewDM;
@property (nonatomic,assign)id <AppViewDelegate> delegate;

- (id)initWithpersonDataModel:(PersonSimpleDataModel *)dataModel frame:(CGRect)initFrame;
@end
