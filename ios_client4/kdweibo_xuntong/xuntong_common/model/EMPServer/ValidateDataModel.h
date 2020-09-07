//
//  ValidateDataModel.h
//  EMPNativeContainer
//
//  Created by Gil on 12-11-16.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "BOSBaseDataModel.h"

@interface ValidateDataModel : BOSBaseDataModel {
    NSString *_validateToken_;
}

//验证令牌
@property (nonatomic,copy) NSString *validateToken;

@end
