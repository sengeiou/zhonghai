//
//  RecommendAppListDataModel.h
//  EMPNativeContainer
//
//  Created by Gil on 13-3-15.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import "BOSBaseDataModel.h"

typedef NS_ENUM(NSUInteger, RecommendDataModelTypeEnum)
{
    RecommendAppDataModelType,
    MFAppDataModelType
};

@interface RecommendAppDataModel : BOSBaseDataModel
@property (nonatomic,copy) NSString *appClientId;
@property (nonatomic,copy) NSString *appName;
@property (nonatomic,copy) NSString *appLogo;
@property (nonatomic,copy) NSString *appDesc;
@property (nonatomic,copy) NSString *downloadURL;
@property (nonatomic,assign) BOOL newer;
@property (nonatomic,copy) NSString *detailURL;
@property (nonatomic,assign) int appType;
@property (nonatomic,copy) NSString *appClientSchema;
@end

@interface RecommendAppListDataModel : BOSBaseDataModel
@property (nonatomic,assign) int total;
@property (nonatomic,assign) BOOL end;
@property (nonatomic, assign) RecommendDataModelTypeEnum modelType;
@property (nonatomic,retain) NSArray *list;
- (id)initWithDictionary:(NSDictionary *)dict type:(RecommendDataModelTypeEnum)type;
@end
