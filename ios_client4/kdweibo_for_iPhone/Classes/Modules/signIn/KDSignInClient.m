//
//  KDSignInClient.m
//  kdweibo
//
//  Created by AlanWong on 14/11/7.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDSignInClient.h"
#import "KDWeiboServicesContext.h"
#import "BOSConfig.h"
#import "BOSSetting.h"
static NSString * const searchPOIRequestPath = @"maprest/c/map/geocoder";
static NSString * const searchSignInShareUrl = @"lightapp/rest/att/getShareLink";
static NSString * const getAtteShareLinkUrl  = @"lightapp/rest/att/getAtteShareLink";

@implementation KDSignInClient

- (id)initWithTarget:(id)target action:(SEL)action
{
    BOSConnectFlags connectFlags = {BOSConnect4DirectURL,BOSConnectNotEncryption,BOSConnectResponseAllowCompressed,BOSConnectRequestBodyNotCompressed,NO};
    self = [super initWithTarget:target action:action connectionFlags:connectFlags];
    if (self) {
        [super setBaseUrlString:[BOSSetting sharedSetting].url];
    }
    return self;
}

-(void)searchPOIWithLatitude:(double)latitude longitude:(double)longitude{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    NSString * location = [NSString stringWithFormat:@"%lf,%lf",latitude,longitude];
    [params setObject:location forKey:@"location"];
    [params setObject:[BOSConfig sharedConfig].user.token forKey:@"key"];
    [super get:searchPOIRequestPath params:params];
}

- (void)getShortSignInShareUrl:(KDSignInRecord *)record
{
    self.urlType = BOSConnectUrlTypeSNSAPI;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:(record.extraRemark && record.extraRemark.length>0)?record.extraRemark: [NSString stringWithFormat:ASLocalizedString(@"%@签到"),KD_APPNAME] forKey:@"title"];
    [params setObject:[self hhmmSignInTimeWithTime:record.singinTime] forKey:@"time"];
    [params setObject:[NSString stringWithFormat:@"%lf",record.longitude] forKey:@"longitude"];
    [params setObject:[NSString stringWithFormat:@"%lf",record.latitude] forKey:@"latitude"];
    [params setObject:(record.featurenamedetail && ![record.featurenamedetail isKindOfClass:[NSNull class]] && record.featurenamedetail.length >0)?record.featurenamedetail : record.featurename forKey:@"address"];
      NSString *name = [BOSConfig sharedConfig].user.name ? [BOSConfig sharedConfig].user.name : @"";
    [params setObject:name forKey:@"username"];
    [super get:searchSignInShareUrl params:params];
}

- (NSString *)hhmmSignInTimeWithTime:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
//    formatter.dateFormat = @"c";
    formatter.dateFormat = @"HH:mm";
    return [formatter stringFromDate:date];
}

- (void)searchAtteShareLinkWithRecord:(KDSignInRecord *)record
{
    self.urlType = BOSConnectUrlTypeSNSAPI;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:(record.extraRemark && record.extraRemark.length>0)?record.extraRemark:[NSString stringWithFormat:@"%@签到",KD_APPNAME] forKey:@"title"];
    [params setObject:[self hhmmSignInTimeWithTime:record.singinTime] forKey:@"time"];
    [params setObject:[NSString stringWithFormat:@"%lf",record.longitude] forKey:@"longitude"];
    [params setObject:[NSString stringWithFormat:@"%lf",record.latitude] forKey:@"latitude"];
    [params setObject:(record.featurenamedetail && ![record.featurenamedetail isKindOfClass:[NSNull class]] && record.featurenamedetail.length >0)?record.featurenamedetail : record.featurename forKey:@"address"];
    NSString *name = [BOSConfig sharedConfig].user.name ? [BOSConfig sharedConfig].user.name : @"";
    if(record.photoIds && record.photoIds.length>0)
    {
        [params setObject:record.photoIds forKey:@"photoIds"];
    }
    [params setObject:name forKey:@"username"];
    [super get:getAtteShareLinkUrl params:params];
}
@end
