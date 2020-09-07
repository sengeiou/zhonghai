//
//  XTPersonsCollectionViewCell.h
//  kdweibo
//
//  Created by lichao_liu on 15/3/10.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonSimpleDataModel.h"
#import "XTPersonHeaderCanDeleteView.h"

@interface XTPersonsCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) PersonSimpleDataModel *personSimpleModel;
@property (nonatomic, weak) id<XTPersonHeaderViewDelegate> deleteDelegate;

@end
