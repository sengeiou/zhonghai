//
//  RecommendAppListDataModel.m
//  EMPNativeContainer
//
//  Created by Gil on 13-3-15.
//  Copyright (c) 2013年 Kingdee.com. All rights reserved.
//

#import "RecommendAppListDataModel.h"
#import "MFAppDataModel.h"
#import "MFWebAppDataModel.h"
#import "BaseAppDataModel.h"

@implementation RecommendAppDataModel

- (id)init {
    self = [super init];
    if (self) {
        _appClientId = @"";
        _appName = [[NSString alloc] init];
        _appLogo = [[NSString alloc] init];
        _appDesc = [[NSString alloc] init];
        _downloadURL = [[NSString alloc] init];
        _newer = false;
        _detailURL = [[NSString alloc] init];
        _appType = 1;
        _appClientSchema = [[NSString alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id appClientId = [dict objectForKey:@"appClientId"];
        id appName = [dict objectForKey:@"appName"];
        id appLogo = [dict objectForKey:@"appLogo"];
        id appDesc = [dict objectForKey:@"appDesc"];
        id downloadURL = [dict objectForKey:@"downloadURL"];
        id newer = [dict objectForKey:@"newer"];
        id detailURL = [dict objectForKey:@"detailURL"];
        
        id appType = [dict objectForKey:@"appType"];
        id appClientSchema = [dict objectForKey:@"appClientSchema"];
        
        if (![appClientId isKindOfClass:[NSNull class]] && appClientId) {
            self.appClientId = appClientId;
        }
        if (![appName isKindOfClass:[NSNull class]] && appName) {
            self.appName = appName;
        }
        if (![appLogo isKindOfClass:[NSNull class]] && appLogo) {
            self.appLogo = appLogo;
        }
        if (![appDesc isKindOfClass:[NSNull class]] && appDesc) {
            self.appDesc = appDesc;
        }
        if (![downloadURL isKindOfClass:[NSNull class]] && downloadURL) {
            self.downloadURL = downloadURL;
        }
        if (![newer isKindOfClass:[NSNull class]] && newer) {
            self.newer = [newer boolValue];
        }
        if (![detailURL isKindOfClass:[NSNull class]] && detailURL) {
            self.detailURL = detailURL;
        }
        if (![appType isKindOfClass:[NSNull class]] && appType != nil) {
            self.appType = [appType intValue];
        }
        if (![appClientSchema isKindOfClass:[NSNull class]] && appClientSchema != nil) {
            self.appClientSchema = appClientSchema;
        }
    }
    return self;
}

- (void)dealloc {
    //BOSRELEASE_appName);
    //BOSRELEASE_appLogo);
    //BOSRELEASE_appDesc);
    //BOSRELEASE_downloadURL);
    //BOSRELEASE_detailURL);
    //[super dealloc];
}

@end

@implementation RecommendAppListDataModel

- (id)init {
    self = [super init];
    if (self) {
        _list = [[NSArray alloc] init];
        _modelType = MFAppDataModelType;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    return [self initWithDictionary:dict type:MFAppDataModelType];
}

- (id)initWithDictionary:(NSDictionary *)dict type:(RecommendDataModelTypeEnum)type
{
    self = [self init];
    _modelType = type;
    if ([dict isKindOfClass:[NSNull class]] || dict == nil) {
        return self;
    }
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if (self) {
        id total = [dict objectForKey:@"total"];
        id end = [dict objectForKey:@"end"];
        id list = [dict objectForKey:@"list"];
        
        if (![total isKindOfClass:[NSNull class]] && total) {
            self.total = [total intValue];
        }
        if (![end isKindOfClass:[NSNull class]] && end) {
            self.end = [end boolValue];
        }
        if (![list isKindOfClass:[NSNull class]] && list && [list isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[(NSArray *)list count]];
            for (id each in list) {
                if (_modelType == RecommendAppDataModelType) {
                    RecommendAppDataModel *app = [[RecommendAppDataModel alloc] initWithDictionary:each];
                    [array addObject:app];
                    //BOSRELEASEapp);
                }else {
                    BaseAppDataModel *am = [self createAppDataModel:each];
                    if(am != nil)
                        [array addObject:am];
                }
            }
            self.list = array;
        }
        
    }
    return self;
}

- (BaseAppDataModel*)createAppDataModel:(NSDictionary*)dict
{
    BaseAppDataModel * appDM = nil;
    int appType = [[dict objectForKey:@"appType"] intValue];
    //TODO: 注意，这里兼容一下新旧接口，具体要看服务端 的修改
    if(appType == 0)
    {
        appDM = [[MFAppDataModel alloc]init]; //autorelease];
        appDM.appType = 1;
        appDM.appClientID = [dict objectForKey:@"appClientId"];
        appDM.appID = [dict objectForKey:@"appId"];
        appDM.appDescribe = [dict objectForKey:@"appDesc"];
        appDM.appLogo = [dict objectForKey:@"appLogo"];
        appDM.appName = [dict objectForKey:@"appName"];
        ((MFAppDataModel*)appDM).appDldURL = [dict objectForKey:@"downloadURL"];
        ((MFAppDataModel*)appDM).appClientSchema = @"";
        ((MFAppDataModel*)appDM).appStatus = 0;
        ((MFAppDataModel*)appDM).appVersion = @"";
    }
    else
    {
        if (appType == 1 || appType == 3) {
            appDM = [[MFAppDataModel alloc]initWithDictionary:dict] ;//autorelease];
        } else if (appType == 2) {          //Web应用
            appDM = [[MFWebAppDataModel alloc]initWithDictionary:dict];//autorelease];
        } else if (appType == 4) {          //轻应用
            appDM = [[MFAppDataModel alloc]initWithDictionary:dict];// autorelease];
            ((MFAppDataModel *)appDM).isLightApp = YES;
        }
    }
    return appDM;
}

- (void)dealloc {
    //BOSRELEASE_list);
    //[super dealloc];
}

@end
