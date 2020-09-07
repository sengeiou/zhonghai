//
//  KDChooseConfigModel.m
//  kdweibo
//
//  Created by kyle on 16/9/12.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDChooseConfigModel.h"

@implementation KDChooseConfigModel

-(id)init {
    self = [super init];
    if (self) {
        _canShowSectionIndexTitle = NO;
        _isMultChooseGroup = NO;
        _isMultChoose = YES;
        _canShowSelf = NO;
        _topGroupIsExtenalGroup = NO;
        _minSelect = 1;
        _maxSelect = INT_MAX;
        _isNeedWechatInvite = NO;
        _isVoiceMeeting = NO;
        _animated = YES;
//        _choosePersonType = KDChoosePersonType_Other;
    }
    return self;
}

@end
