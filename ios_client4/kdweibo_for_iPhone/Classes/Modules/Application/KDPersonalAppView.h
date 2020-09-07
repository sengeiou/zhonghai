//
//  KDPersonalAppView.h
//  kdweibo
//
//  Created by AlanWong on 14-9-26.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDAppDataModel.h"
@class KDPersonalAppView;
@protocol KDPersonalAppViewDelegate <NSObject>
@optional
- (void)goToAppWithDataModel:(KDAppDataModel *)appDM;
- (void)longPressAppView;
- (void)appViewMoving:(KDPersonalAppView *)appView andState:(UIGestureRecognizerState)state;
- (void)appViewMoveComplete:(NSArray *)dataArray;
@end
@interface KDPersonalAppView : UIView

@property (nonatomic,strong)UILabel *appNameLabel;
@property (nonatomic,strong)UIImageView *appImageView;
@property (nonatomic,strong)UIImageView *appImageBg;
@property (nonatomic,strong)KDAppDataModel *appDM;
@property (nonatomic,weak)id <KDPersonalAppViewDelegate> delegate;

@property (nonatomic,assign) BOOL isFeatureFuc;
@property (nonatomic,assign) BOOL isEditing;

- (id)initWithAppDataModel:(KDAppDataModel *)appDM
                     frame:(CGRect)initFrame
                   delFlag:(BOOL)delFlag;
@end
