//
//  KDMapViewController.h
//  kdweibo
//
//  Created by Tan YingQi on 13-3-10.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "RecordDataModel.h"

@protocol KDMapViewData <NSObject>

- (CGFloat)latitude;
- (CGFloat)longitude;
- (NSString *)address;

@end
@interface KDMapViewController : UIViewController
@property(nonatomic,retain)id<KDMapViewData> obj;
@property(nonatomic,retain)MAMapView *mapView;
@property(nonatomic,retain) MessageTypeLocationDataModel *data;
@end
