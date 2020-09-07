//
//  KDSubscribeCell.h
//  kdweibo
//
//  Created by wenbin_su on 15/9/14.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonSimpleDataModel.h"
@interface KDSubscribeCell : UICollectionViewCell
@property (nonatomic, strong) XTPersonHeaderImageView *appImageView;
@property (nonatomic, strong)PersonSimpleDataModel *data;
@property (nonatomic, strong) UILabel *appNameLabel;

@property (nonatomic, assign) BOOL isCreatorPerson;

- (void)setIsPersonStateChanged:(BOOL)isChanged;
@end