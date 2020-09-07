//
//  CustomerPublicKeyDataModel.h
//  EMPNativeContainer
//
//  Created by Gil on 12-11-16.
//  Copyright (c) 2012年 Kingdee.com. All rights reserved.
//

#import "BOSBaseDataModel.h"

@interface CustomerPublicKeyDataModel : BOSBaseDataModel {
    NSString *_publicKey_;
}

//公钥，BASE64编码
@property (nonatomic,copy) NSString *publicKey;

@end
