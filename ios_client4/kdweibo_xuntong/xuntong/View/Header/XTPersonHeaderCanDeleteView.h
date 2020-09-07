//
//  XTPersonHeaderCanDeleteView.h
//  XT
//
//  Created by Gil on 13-7-9.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTPersonHeaderView.h"

typedef enum _PersonHeaderDeleteType
{
    PersonHeaderDeleteTypeNormal,
    PersonHeaderDeleteTypeDeleted
}PersonHeaderDeleteType;

@protocol XTPersonHeaderCanDeleteViewDelegate;
@interface XTPersonHeaderCanDeleteView : XTPersonHeaderView

@property (nonatomic, assign) PersonHeaderDeleteType type;
@property (nonatomic, strong) UIImageView *deleteView;
@property (nonatomic, weak) id<XTPersonHeaderCanDeleteViewDelegate> deleteDelegate;
@property (nonatomic, assign) BOOL isManager;

@end

@protocol XTPersonHeaderCanDeleteViewDelegate <NSObject>
- (void)personHeaderDeleteButtonClicked:(XTPersonHeaderCanDeleteView *)headerView person:(PersonSimpleDataModel *)person;
@end
