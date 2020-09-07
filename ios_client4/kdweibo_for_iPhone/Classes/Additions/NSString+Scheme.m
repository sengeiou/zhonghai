//
//  NSString+Schema.m
//  kdweibo
//
//  Created by shen kuikui on 14-6-6.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "NSString+Scheme.h"
#import "BOSConfig.h"
#import "NSData+Base64.h"
#import "NSString+URLEncode.h"


static NSString *KDSchemeCloudHub = @"cloudhub://";
static NSString *KDSchemeHttp = @"http://";
static NSString *KDSchemeHttps = @"https://";

NSString * const KDSchemaPathInbox   = @"inbox";
NSString * const KDSchemaPathProfile = @"profile";
NSString * const KDSchemaPathShare   = @"share";
NSString * const KDSchemaPathStart   = @"start";

@implementation NSString (Scheme)

#pragma mark - scheme
- (id)internalSchemeInfoWithType:(out KDSchemeHostType *)type {
    return [self schemeInfoWithType:type isExternal:NO];
}
- (id)externalSchemeInfoWithType:(out KDSchemeHostType *)type {
    return [self schemeInfoWithType:type isExternal:YES];
}
- (id)schemeInfoWithType:(out KDSchemeHostType *)type isExternal:(BOOL)isExternal {
    KDSchemeHostType t = KDSchemeHostType_NONE;
    id result = nil;
    
    if (self.length > 0) {
        if (![self validate]) {
            t = KDSchemeHostType_NOTURI;
            result = self;
        }
        else {
            if ([self hasPrefix:KDSchemeHttp]) {
                t = KDSchemeHostType_HTTP;
                result = self;
            }
            else if ([self hasPrefix:KDSchemeHttps]) {
                t = KDSchemeHostType_HTTPS;
                result = self;
            }
            else if ([self hasPrefix:KDSchemeCloudHub]) {
                result = [self cloudHubSchemeWithType:&t isExternal:isExternal];
            }
            else {
                t = KDSchemeHostType_Unknow;
                result = self;
            }
        }
    }
    
    if (type != NULL) {
        *type = t;
    }
    return result;
}
- (id)cloudHubSchemeWithType:(out KDSchemeHostType *)type isExternal:(BOOL)isExternal {
    KDSchemeHostType t = KDSchemeHostType_Unknow;
    id result = nil;
    
    int schemeLength = (int)KDSchemeCloudHub.length;
    
    if (self.length > schemeLength) {
        NSString *hostAndQuery = [self substringFromIndex:schemeLength];
        NSArray *items = [hostAndQuery componentsSeparatedByString:@"?"];
        
        NSString *host = nil;
        NSString *query = nil;
        
        if (items.count > 0) {
            host = items[0];
        }
        
        if (items.count > 1) {
            query = items[1];
        }
        
        //去掉空格，变成全小写
        host = [host stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        host = [host lowercaseString];
        
        if (isExternal) {
            //外部跳转协议
            if (host.length == 0) {
                t = KDSchemeHostType_Start;
            }
            else if ([host isEqualToString:@"chat"]) {
                t = KDSchemeHostType_Chat;
            }
            else if ([host isEqualToString:@"share"]) {
                t = KDSchemeHostType_Share;
            }
            else if ([host isEqualToString:@"start"]) {
                t = KDSchemeHostType_Start;
            }
            else if ([host isEqualToString:@"profile"]) {
                t = KDSchemeHostType_Profile;
            }
//            else if ([host isEqualToString:@"auth"]) {
//                t = KDSchemeHostType_Oauth;
//            }
//            else if ([host isEqualToString:@"invite"]) {
//                t = KDSchemeHostType_Invite;
//            }
        }
        else {
            //内部跳转协议
            if (host.length == 0) {
                t = KDSchemeHostType_Unknow;
            }
            else if ([host isEqualToString:@"status"]) {
                t = KDSchemeHostType_Status;
            }
            else if ([host isEqualToString:@"local"]) {
                t = KDSchemeHostType_Local;
            }
            else if ([host isEqualToString:@"todo"]) {
                t = KDSchemeHostType_Todo;
            }
            else if ([host isEqualToString:@"todonew"]) {
                t = KDSchemeHostType_Todonew;
            }
            else if ([host isEqualToString:@"todolist"]) {
                t = KDSchemeHostType_Todolist;
            }
            else if ([host isEqualToString:@"chat"]) {
                t = KDSchemeHostType_Chat;
            }
            else if ([host isEqualToString:@"personalsetting"]) {
                t = KDSchemeHostType_PersonalSetting;
            }
            else if ([host isEqualToString:@"signin"]) {
                t = KDSchemeHostType_Signin;
            }
            else if ([host isEqualToString:@"invite"]) {
                t = KDSchemeHostType_Invite;
            }
            else if ([host isEqualToString:@"voicemeeting"]) {
                t = KDSchemeHostType_VoiceMeeting;
            }
            else if ([host isEqualToString:@"createvoicemeeting"]) {
                t = KDSchemeHostType_CreateVoiceMeeting;
            }
            else if ([host isEqualToString:@"profile"] || [host isEqualToString:@"personinfo"]) {
                t = KDSchemeHostType_Profile;
            }
            else if ([host isEqualToString:@"filepreview"]) {
                t = KDSchemeHostType_FilePrevew;
            }
            else if ([host isEqualToString:@"enterpriseauth"]) {
                t = KDSchemeHostType_EnterpriseAuth;
            }
            else if ([host isEqualToString:@"orglist"]) {
                t = KDSchemeHostType_OrgList;
            }
            else if ([host isEqualToString:@"appdetail"]) {
                t = KDSchemeHostType_Appdetail;
            }
            else if ([host isEqualToString:@"appcategory"]) {
                t = KDSchemeHostType_Appcategory;
            }
            else if ([host isEqualToString:@"lightapp"]) {
                t = KDSchemeHostType_LightApp;
            }
        }
        
        if (query.length > 0) {
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            
            NSArray *paramItems = [query componentsSeparatedByString:@"&"];
            
            for (NSString *paramItem in paramItems) {
                NSArray *keyAndValues = [paramItem componentsSeparatedByString:@"="];
                
                NSString *key = nil;
                NSString *value = nil;
                
                if (keyAndValues.count > 0) {
                    key = keyAndValues[0];
                }
                
                if (keyAndValues.count > 1) {
                    if (isExternal) {
                        //外部协议需要先解码
                        value = [keyAndValues[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    else {
                        value = keyAndValues[1];
                    }
                }
                
                if (key) {
                    if (value == nil) {
                        value = @"";
                    }
                    [info setObject:value forKey:key];
                }
            }
            
            result = info;
        }
        
        //(坑爹的旧协议，定的和Android不一样，为了兼容它，才有这段代码) Gil
        if ((t == KDSchemeHostType_Todo || t == KDSchemeHostType_Todolist) && result != nil) {
            NSString *method = result[@"to"];
            
            if ([method isEqualToString:@"detail"]) {
                t = KDSchemeHostType_Todo;
            }
            else if ([method isEqualToString:@"list"]) {
                t = KDSchemeHostType_Todolist;
            }
            else if ([method isEqualToString:@"create"]) {
                t = KDSchemeHostType_Todonew;
            }
        }
    }
    
    if (t == KDSchemeHostType_Unknow) {
        result = self;
    }
    
    if (type != NULL) {
        *type = t;
    }
    return result;
}

- (id)schemeInfoWithType:(out KDSchemeHostType *)type shouldDecoded:(BOOL)shouldDecoded
{
    KDSchemeHostType t = KDSchemeHostType_NONE;
    id result = nil;
    
    if (self.length > 0) {
        if (![self validate]) {
            t = KDSchemeHostType_NOTURI;
            result = self;
        }
        else {
            if ([self hasPrefix:KDSchemeHttp]) {
                t = KDSchemeHostType_HTTP;
                result = self;
            }
            else if ([self hasPrefix:KDSchemeHttps]) {
                t = KDSchemeHostType_HTTPS;
                result = self;
            }
            else if ([self hasPrefix:KDSchemeCloudHub]) {
                result = [self cloudHubSchemeWithType:&t shouldDecoded:shouldDecoded];
            }
            else {
                t = KDSchemeHostType_Unknow;
                result = self;
            }
        }
    }
    
    if(type != NULL) {
        *type = t;
    }
    return result;
}
- (id)cloudHubSchemeWithType:(out KDSchemeHostType *)type shouldDecoded:(BOOL)shouldDecoded
{
    KDSchemeHostType t = KDSchemeHostType_Unknow;
    id result = nil;
    
    int schemeLength = (int)KDSchemeCloudHub.length;
    if(self.length > schemeLength) {
        NSString *hostAndQuery = [self substringFromIndex:schemeLength];
        NSArray *items = [hostAndQuery componentsSeparatedByString:@"?"];
        
        NSString *host = nil;
        NSString *query = nil;
        if(items.count > 0) {
            host = items[0];
        }
        if(items.count > 1) {
            query = items[1];
        }
        
        //去掉空格，变成全小写
        host = [host stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        host = [host lowercaseString];
        if (host.length > 0) {
            if([host isEqualToString:@"topic"]) {
                t = KDSchemeHostType_Topic;
            }else if([host isEqualToString:@"status"]) {
                t = KDSchemeHostType_Status;
            }
            else if([host isEqualToString:@"local"]){
                t = KDSchemeHostType_Local;
            }
            else if([host isEqualToString:@"todo"]){
                t = KDSchemeHostType_Todo;
            }
            else if([host isEqualToString:@"todonew"]){
                t = KDSchemeHostType_Todonew;
            }
            else if([host isEqualToString:@"todolist"]){
                t = KDSchemeHostType_Todolist;
            }
            else if([host isEqualToString:@"chat"]){
                t = KDSchemeHostType_Chat;
            }
            else if([host isEqualToString:@"personalsetting"]){
                t = KDSchemeHostType_PersonalSetting;
            }
            else if([host isEqualToString:@"start"]){
                t = KDSchemeHostType_Start;
            }
            else if([host isEqualToString:@"share"]){
                t = KDSchemeHostType_Share;
            }
            else if([host isEqualToString:@""]){
                t = KDThirdPartSchemaType_Open;
            }else if([host isEqualToString:@"signin"])
            {
                t = KDSchemeHostType_Signin;
            }else if([host isEqualToString:@"wifisigninsetting"])
            {
                t = KDSchemeHostType_wifiSignInSetting;
            }else if([host isEqualToString:@"relativedsigninpoint"])
            {
                t = KDSchemeHostType_wifiLink;
            }
            else if([host isEqualToString:@"invite"])
            {
                t = KDSchemeHostType_Invite;
            }
        }
        else{
            t = KDThirdPartSchemaType_Open;
        }
        
        if(query.length > 0) {
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            
            NSArray *paramItems = [query componentsSeparatedByString:@"&"];
            for(NSString *paramItem in paramItems) {
                NSArray *keyAndValues = [paramItem componentsSeparatedByString:@"="];
                
                NSString *key = nil;
                NSString *value = nil;
                
                if(keyAndValues.count > 0) {
                    key = keyAndValues[0];
                }
                
                if(keyAndValues.count > 1) {
                    if (shouldDecoded) {
                        value = [keyAndValues[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    else {
                        value = keyAndValues[1];
                    }
                }
                
                if(key) {
                    if(value == nil) value = @"";
                    [info setObject:value forKey:key];
                }
            }
            
            result = info;
        }
        
        //(坑爹的旧协议，定的和Android不一样，为了兼容它，才有这段代码) Gil
        if ((t == KDSchemeHostType_Todo || t == KDSchemeHostType_Todolist) && result != nil) {
            NSString *method = result[@"to"];
            if ([method isEqualToString:@"detail"]) {
                t = KDSchemeHostType_Todo;
            }
            else if ([method isEqualToString:@"list"]) {
                t = KDSchemeHostType_Todolist;
            }
            else if ([method isEqualToString:@"create"]) {
                t = KDSchemeHostType_Todonew;
            }
        }
    }
    
    if (t == KDSchemeHostType_Unknow) {
        result = self;
    }
    
    if(type != NULL) {
        *type = t;
    }
    return result;
}

- (id)cloudHubSchemeWithType:(out KDSchemeHostType *)type
{
    KDSchemeHostType t = KDSchemeHostType_Unknow;
    id result = nil;
    
    int schemeLength = (int)KDSchemeCloudHub.length;
    if(self.length > schemeLength) {
        NSString *hostAndQuery = [self substringFromIndex:schemeLength];
        NSArray *items = [hostAndQuery componentsSeparatedByString:@"?"];
        
        NSString *host = nil;
        NSString *query = nil;
        if(items.count > 0) {
            host = items[0];
        }
        if(items.count > 1) {
            query = items[1];
        }
        
        //去掉空格，变成全小写
        host = [host stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        host = [host lowercaseString];
        if (host.length > 0) {
            if([host isEqualToString:@"topic"]) {
                t = KDSchemeHostType_Topic;
            }else if([host isEqualToString:@"status"]) {
                t = KDSchemeHostType_Status;
            }
            else if([host isEqualToString:@"local"]){
                t = KDSchemeHostType_Local;
            }
            else if([host isEqualToString:@"todo"]){
                t = KDSchemeHostType_Todo;
            }
            else if([host isEqualToString:@"todonew"]){
                t = KDSchemeHostType_Todonew;
            }
            else if([host isEqualToString:@"todolist"]){
                t = KDSchemeHostType_Todolist;
            }
            else if([host isEqualToString:@"chat"]){
                t = KDSchemeHostType_Chat;
            }
            else if([host isEqualToString:@"personalsetting"]){
                t = KDSchemeHostType_PersonalSetting;
            }
        }
        
        if(query.length > 0) {
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            
            NSArray *paramItems = [query componentsSeparatedByString:@"&"];
            for(NSString *paramItem in paramItems) {
                NSArray *keyAndValues = [paramItem componentsSeparatedByString:@"="];
                
                NSString *key = nil;
                NSString *value = nil;
                
                if(keyAndValues.count > 0) {
                    key = keyAndValues[0];
                }
                
                if(keyAndValues.count > 1) {
                    value = keyAndValues[1];
                }
                
                if(key) {
                    if(value == nil) value = @"";
                    [info setObject:value forKey:key];
                }
            }
            
            result = info;
        }
        
        //(坑爹的旧协议，定的和Android不一样，为了兼容它，才有这段代码) Gil
        if ((t == KDSchemeHostType_Todo || t == KDSchemeHostType_Todolist) && result != nil) {
            NSString *method = result[@"to"];
            if ([method isEqualToString:@"detail"]) {
                t = KDSchemeHostType_Todo;
            }
            else if ([method isEqualToString:@"list"]) {
                t = KDSchemeHostType_Todolist;
            }
            else if ([method isEqualToString:@"create"]) {
                t = KDSchemeHostType_Todonew;
            }
        }
    }
    
    if (t == KDSchemeHostType_Unknow) {
        result = self;
    }
    
    if(type != NULL) {
        *type = t;
    }
    return result;
}

- (BOOL)validate
{
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    
    NSRange urlStringRange = NSMakeRange(0, [self length]);
    NSMatchingOptions matchingOptions = 0;
    
    if (1 != [linkDetector numberOfMatchesInString:self options:matchingOptions range:urlStringRange]) {
        return NO;
    }
    
    NSTextCheckingResult *checkingResult = [linkDetector firstMatchInString:self options:matchingOptions range:urlStringRange];
    
    return checkingResult.resultType == NSTextCheckingTypeLink;
}

#pragma mark - params

- (NSString *)addParams:(NSString *)params
{
    NSString *url = @"";
    if (self.length == 0) {
        return url;
    }
    
    if ([self rangeOfString:@"?"].location != NSNotFound) {
        url = [self stringByAppendingFormat:@"&%@",params];
    }
    else {
        url = [self stringByAppendingFormat:@"?%@",params];
    }
    return url;
}



- (NSString *)appendParamsForShare {
    NSMutableString *newString = [NSMutableString stringWithString:self];
    
    //添加appId
    [newString appendFormat:@"&appKey=%@&", [KD_APP_KEY_IPHONE encodeForURL]];
    //添加token
    NSString *token = [BOSConfig sharedConfig].shareToken;
    NSString *tokenSecret = [BOSConfig sharedConfig].shareTokenSecret;
    if ([token length] > 0 && [tokenSecret length] > 0) {
        NSString *tokenString = [[NSString stringWithFormat:@"%@|%@", token, tokenSecret] encodeForURL];
        [newString appendFormat:@"token=%@&", tokenString];
    }
    
    //添加networkId
    NSString *networkId = [BOSConfig sharedConfig].user.wbNetworkId;
    if ([networkId length] > 0) {
        [newString appendFormat:@"networkId=%@&", [networkId encodeForURL]];
    }
    //添加appName
    NSString *appName = [[KD_APPNAME stringByAppendingString:ASLocalizedString(@"Scheme_appName")] encodeForURL];
    [newString appendFormat:@"appName=%@", appName];
    return newString.description;
}
@end
