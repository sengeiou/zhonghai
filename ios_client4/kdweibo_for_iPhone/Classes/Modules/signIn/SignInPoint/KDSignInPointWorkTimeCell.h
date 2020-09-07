//
//  KDSignInPointWorkTimeCell.h
//  kdweibo
//
//  Created by lichao_liu on 1/19/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KDSignInPoint;

typedef NS_ENUM(NSInteger, KDSignInPointWorkTimeType) {
    KDSignInPointWorkTimeType_fromBeginTime,
    KDSignInPointWorkTimeType_toBeginTime,
    KDSignInPointWorkTimeType_fromEndTime,
    KDSignInPointWorkTimeType_toEndTime
};
typedef void(^btnClickedBlock)(KDSignInPointWorkTimeType);

@interface KDSignInPointWorkTimeCell : UITableViewCell
@property (nonatomic, copy) btnClickedBlock block;;
@property (nonatomic, strong) UIButton *fromBeginTimeBtn;
@property (nonatomic, strong) UIButton *toBeginTimeBtn;
@property (nonatomic, strong) UIButton *fromEndTimeBtn;
@property (nonatomic, strong) UIButton *toEndTimeBtn;
@property (nonatomic, strong) UILabel *countTimeLabel;

- (void)initDataWithFromBeginTime:(NSString *)fromBeginTime
                      toBeginTime:(NSString *)toBeginTime
                      fromEndTime:(NSString *)fromEndTime
                        toendTime:(NSString *)toEndTime;


@end

