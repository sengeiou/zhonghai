//
//  KDMultiVoiceViewCell.h
//  kdweibo
//
//  Created by wenbin_su on 15/7/6.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersonSimpleDataModel;

@interface KDMultiVoiceViewCell : UICollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setCellInformationWithPerson:(PersonSimpleDataModel *)person;
@end
