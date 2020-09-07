//
//  KDAppDataModel.m
//  kdweibo
//
//  Created by AlanWong on 14-9-24.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//



#import "KDAppDataModel.h"

@implementation KDAppDataModel
- (id)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        if ([dict isKindOfClass:[NSNull class]] && dict == nil)
        {
            return nil;
        }
        else
        {
            id KD_appType = [dict objectForKey:@"appType"];
            
            id KD_appName = [dict objectForKey:@"appName"];

            id KD_appID = [dict objectForKey:@"appId"];

            id KD_appClientID = [dict objectForKey:@"appClientId"];

            id KD_appDesc = [dict objectForKey:@"appDesc"];

            id KD_appLogo = [dict objectForKey:@"appLogo"];

            id KD_downloadURL = [dict objectForKey:@"downloadURL"];

            id KD_appClientSchema = [dict objectForKey:@"appClientSchema"];

            id KD_appClientVersion = [dict objectForKey:@"appClientVersion"];

            id KD_detailURL = [dict objectForKey:@"detailURL"];

            id KD_versionUpdateTime = [dict objectForKey:@"versionUpdateTime"];

            id KD_webURL = [dict objectForKey:@"webUrl"];

            id KD_pid= [dict objectForKey:@"pid"];

            id appClasses = [dict objectForKey:@"appClasses"];
            if(appClasses == [NSNull null])
                appClasses = @[];
            else if([appClasses isKindOfClass:[NSString class]])
                appClasses = @[appClasses];
            self.appClasses = appClasses;
            
            id deleteAble = [dict objectForKey:@"deleted"];
            if ([self testNullAndNil:deleteAble]) {
                if ([deleteAble boolValue] == YES) {
                    self.deleteAble = [NSString stringWithFormat:@"%@", @"Yes"];
                    
                }else {
                    self.deleteAble = [NSString stringWithFormat:@"%@", @"No"];
                }
            }
            
            id FIOSLaunchParams = [dict objectForKey:@"iosLaunchParams"];
            if ([self testNullAndNil:FIOSLaunchParams]) {
                self.FIOSLaunchParams = FIOSLaunchParams;
            }
            
            if (![KD_appType isKindOfClass:[NSNull class]] && KD_appType != nil)
            {
                self.appType = (KDAppType)[KD_appType integerValue];
            }
           
            if (![KD_appName isKindOfClass:[NSNull class]] && KD_appName != nil)
            {
                self.appName = KD_appName;
            }
            if (![KD_appID isKindOfClass:[NSNull class]] && KD_appID != nil)
            {
                self.appID = [NSString stringWithFormat:@"%ld",(long)[KD_appID integerValue]];;
            }
            if (![KD_appClientID isKindOfClass:[NSNull class]] && KD_appClientID != nil)
            {
                self.appClientID = [NSString stringWithFormat:@"%lld",[KD_appClientID longLongValue]];
            }
            if (![KD_appDesc isKindOfClass:[NSNull class]] && KD_appDesc != nil)
            {
                self.appDesc = KD_appDesc;
            }
            if (![KD_appLogo isKindOfClass:[NSNull class]] && KD_appLogo != nil)
            {
                self.appLogo = KD_appLogo;
            }
            if (![KD_downloadURL isKindOfClass:[NSNull class]] && KD_downloadURL != nil)
            {
                self.downloadURL = KD_downloadURL;
            }
            if (![KD_appClientSchema isKindOfClass:[NSNull class]] && KD_appClientSchema != nil)
            {
                self.appClientSchema = KD_appClientSchema;
            }
            if (![KD_appClientVersion isKindOfClass:[NSNull class]] && KD_appClientVersion != nil)
            {
                self.appClientVersion = KD_appClientVersion;
            }
            if (![KD_detailURL isKindOfClass:[NSNull class]] && KD_detailURL != nil)
            {
                self.detailURL = KD_detailURL;
            }
            if (![KD_versionUpdateTime isKindOfClass:[NSNull class]] && KD_versionUpdateTime != nil)
            {
                self.versionUpdateTime = KD_versionUpdateTime;
            }
            if (![KD_webURL isKindOfClass:[NSNull class]] && KD_webURL != nil)
            {
                self.webURL = KD_webURL;
            }
            if (![KD_pid isKindOfClass:[NSNull class]] && KD_pid != nil)
            {
                self.pid = KD_pid;
            }
        }

        
    }
    return self;
}

-(BOOL)testNullAndNil:(id)arg {
    return (![arg isKindOfClass:[NSNull class]] && (arg != nil));
}

-(id)initWithDictionaryFromWeb:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict isKindOfClass:[NSNull class]] && dict == nil)
        {
            return nil;
        }
        else
        {
            id appClientId = [dict objectForKey:@"appClientId"];
            id appId = [dict objectForKey:@"appId"];
            id appName = [dict objectForKey:@"appName"];
            id appLogo = [dict objectForKey:@"appLogo"];
            id appDesc = [dict objectForKey:@"appDesc"];
            id downloadURL = [dict objectForKey:@"downloadURL"];
            id detailURL = [dict objectForKey:@"detailURL"];
            id appType = [dict objectForKey:@"appType"];
            id appClientSchema = [dict objectForKey:@"appClientSchema"];
            id appClientVersion = [dict objectForKey:@"appClientVersion"];
            id webUrl = [dict objectForKey:@"webUrl"];
            id packageName = [dict objectForKey:@"packageName"];
            id pid = [dict objectForKey:@"pid"];
            id versionUpdateTime = [dict objectForKey:@"versionUpdateTime"];
            id appActionMode = [dict objectForKey:@"appActionMode"];
            id deleteAble = [dict objectForKey:@"deleted"];
            id FIOSLaunchParams = [dict objectForKey:@"iosLaunchParams"];
            
            if ([self testNullAndNil:appClientId]) {
                //这里系统返回的是long，我们先转换成int
                self.appClientID = [NSString stringWithFormat:@"%@", appClientId];
            }
            
            if ([self testNullAndNil:appId]) {
                self.appID = [NSString stringWithFormat:@"%@", appId];
                self.appClientID = [NSString stringWithFormat:@"%@00", appId];
                //防止服务器传过来的appId为空，这个地方人工补上appClientId，不能少这句话
            }
            
            if ([self testNullAndNil:appName]) {
                self.appName = appName;
            }
            
            if ([self testNullAndNil:appLogo]) {
                self.appLogo = appLogo;
            }
            
            if ([self testNullAndNil:appDesc]) {
                self.appDesc = appDesc;
            }
            
            if ([self testNullAndNil:downloadURL]) {
                self.downloadURL = downloadURL;
            }
            
            if ([self testNullAndNil:detailURL]) {
                self.detailURL = detailURL;
            }
            
            if ([self testNullAndNil:appType]) {
                
                switch ([appType intValue]) {
                    case 1:{
                        self.appType = KDAppTypeNativeKingdee;
                    }
                        break;
                    case 2:{
                        self.appType = KDAppTypeWeb;
                    }
                        break;
                    case 3:{
                        self.appType = KDAppTypeNativeThirdPart;
                    }
                        break;
                    case 4:{
                        self.appType = KDAppTypeLight;
                    }
                        break;
                    case 5:{
                        self.appType = KDAppTypePublic;
                    }
                        break;
                    case 6:{
                        self.appType = KDAppTypeSpecial;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
            if ([self testNullAndNil:appClientSchema]) {
                self.appClientSchema = appClientSchema;
            }
            
            if ([self testNullAndNil:appClientVersion]) {
                self.appClientVersion = appClientVersion;
            }
            
            if ([self testNullAndNil:webUrl]) {
                self.webURL = webUrl;
            }
            
            if ([self testNullAndNil:packageName]) {
                self.packageName = packageName;
            }
            
            if ([self testNullAndNil:pid]) {
                self.pid = pid;
                self.appType = KDAppTypePublic;
            }
            
            if ([self testNullAndNil:versionUpdateTime]) {
                self.versionUpdateTime = versionUpdateTime;
            }
            
            if ([self testNullAndNil:appActionMode]) {
                
                switch ([appActionMode intValue]) {
                    case 1:{
                        self.appActionMode = KDAppActionTypeCompany;
                    }
                        break;
                    case 2:{
                        self.appActionMode = KDAppActionTypeManyCompany;
                    }
                        break;
                    case 3:{
                        self.appActionMode = KDAppActionTypeOrganization;
                    }
                        break;
                    case 4:{
                        self.appActionMode = KDAppActionTypePerson;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            
            if ([self testNullAndNil:deleteAble]) {
                if ([deleteAble boolValue] == YES) {
                    self.deleteAble = [NSString stringWithFormat:@"%@", @"Yes"];
                    
                }else {
                    self.deleteAble = [NSString stringWithFormat:@"%@", @"No"];
                }
            }
            
            if ([self testNullAndNil:FIOSLaunchParams]) {
                self.FIOSLaunchParams = FIOSLaunchParams;
            }
            
        }
    }
    return self;
}

-(void)setFIOSLaunchParams:(NSString *)FIOSLaunchParams
{
    _FIOSLaunchParams = [FIOSLaunchParams copy];
    
    if(_FIOSLaunchParams)
        if([_FIOSLaunchParams hasPrefix:@"cloudhub://"])
            _iosSchdeme = [[_FIOSLaunchParams substringFromIndex:@"cloudhub://".length] copy];
}

@end
