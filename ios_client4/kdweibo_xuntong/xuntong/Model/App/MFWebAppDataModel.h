//
//  MFWebAppDataModel.h
//  MobilePortal
//
//  Created by kingdee eas on 13-8-16.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseAppDataModel.h"
@interface MFWebAppDataModel : BaseAppDataModel
{
    NSString *webURL;              ////应用地址
}

@property (nonatomic,copy) NSString *webURL;
- (id)initWithDictionary:(NSDictionary *)dict;
@end
