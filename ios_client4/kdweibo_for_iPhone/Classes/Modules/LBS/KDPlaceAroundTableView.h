//
//  KDPlaceAroundTableView.h
//  kdweibo
//
//  Created by wenjie_lee on 16/2/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapView.h>
//#import <AMapSearchKit/AMapSearchKit.h>

@protocol KDPlaceAroundTableViewDeleagate <NSObject>

- (void)didTableViewSelectedChanged:(AMapPOI *)selectedPoi;

- (void)didLoadMorePOIButtonTapped;

- (void)didPositionCellTapped:(AMapPOI *)selectedPoi;

@end




@interface KDPlaceAroundTableView : UIView<UITableViewDataSource, UITableViewDelegate, AMapSearchDelegate>

@property (nonatomic, weak) id<KDPlaceAroundTableViewDeleagate> delegate;

@property (nonatomic, strong) NSString *currentRedWaterPosition;

- (instancetype)initWithFrame:(CGRect)frame;

- (AMapPOI *)selectedTableViewCellPoi;

@end
