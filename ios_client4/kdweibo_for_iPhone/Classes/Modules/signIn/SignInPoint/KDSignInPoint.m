//
//  KDSignInPoint.m
//  kdweibo
//
//  Created by lichao_liu on 1/19/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInPoint.h"

@implementation KDSignInPoint

- (id)copyWithZone:(NSZone *)zone
{
    KDSignInPoint *copy = [[[self class] allocWithZone:zone] init];
    copy.signInPointId = [self.signInPointId copyWithZone:zone];
    copy.positionName = [self.positionName copyWithZone:zone];
    copy.lat = self.lat;
    copy.lng = self.lng;
    copy.startWorkBegin = [self.startWorkBegin copyWithZone:zone];
    copy.endWorkBegin = [self.endWorkBegin copyWithZone:zone];
    copy.startWorkEnd = [self.startWorkEnd copyWithZone:zone];
    copy.endWorkEnd = [self.endWorkEnd copyWithZone:zone];
    copy.detailAddress = [self.detailAddress copyWithZone:zone];
    copy.wifiDataArray = [self.wifiDataArray copyWithZone:zone];
    copy.alias = [self.alias copyWithZone:zone];
    copy.offset = self.offset;
    copy.clockInSectionTimes = self.clockInSectionTimes;
    return copy;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        if(!dict)
        {
            return nil;
        }
        id signInPointId = dict[@"id"];
        if(signInPointId && ![signInPointId isKindOfClass:[NSNull class]])
        {
            self.signInPointId = signInPointId;
        }
        
        id endWorkEnd = dict[@"endWorkEnd"];
        if(endWorkEnd && ![endWorkEnd isKindOfClass:[NSNull class]])
        {
            self.endWorkEnd = endWorkEnd;
        }
        
        id startWorkBegin = dict[@"startWorkBegin"];
        if(startWorkBegin && ![startWorkBegin isKindOfClass:[NSNull class]])
        {
            self.startWorkBegin = startWorkBegin;
        }
        
        id startWorkEnd = dict[@"startWorkEnd"];
        if(startWorkEnd && ![startWorkEnd isKindOfClass:[NSNull class]])
        {
            self.startWorkEnd = startWorkEnd;
        }
        
        id lng = dict[@"lng"];
        if(lng && ![lng isKindOfClass:[NSNull class]])
        {
            self.lng = [lng doubleValue];
        }
        
        id positionName = dict[@"positionName"];
        if(positionName && ![positionName isKindOfClass:[NSNull class]])
        {
            self.positionName = positionName;
        }
        
        id lat = dict[@"lat"];
        if(lat && ![lat isKindOfClass:[NSNull class]])
        {
            self.lat = [lat doubleValue];
        }
        
        id endWorkBegin = dict[@"endWorkBegin"];
        if(endWorkBegin && ![endWorkBegin isKindOfClass:[NSNull class]])
        {
            self.endWorkBegin = endWorkBegin;
        }
        
        id address = dict[@"address"];
        if(address && ![address isKindOfClass:[NSNull class]])
        {
            self.detailAddress = address;
        }
        
        id alias = dict[@"alias"];
        if(alias && ![alias isKindOfClass:[NSNull class]])
        {
            self.alias = alias;
        }
        
        id offset = dict[@"offset"];
        if(offset && ![offset isKindOfClass:[NSNull class]])
        {
            self.offset = [offset integerValue];
        }else{
            self.offset = 200;//默认200
        }
        
        id clockInSectionTimes = dict[@"clockInSectionTimes"];
        if (clockInSectionTimes && ![clockInSectionTimes isKindOfClass:[NSNull class]]) {
            self.clockInSectionTimes = [clockInSectionTimes integerValue];
        }
        else {
            self.clockInSectionTimes = 2;//默认2
        }
        
        id wifiArray = dict[@"wifis"];
        if(wifiArray && ![wifiArray isKindOfClass:[NSNull class]])
        {
            self.wifiDataArray = [NSMutableArray new];
            for (NSDictionary *wifiDict in wifiArray)
            {
                NSString *ssid = wifiDict[@"ssid"];
                if(ssid &&[ssid hasSuffix:ASLocalizedString(@"_重名")])
                {
                    NSMutableDictionary *renameDict = [[NSMutableDictionary alloc] initWithDictionary:wifiDict];
                    ssid = [ssid substringToIndex:ssid.length - 3];
                    if(ssid &&[ssid hasSuffix:ASLocalizedString(@"_重名")])
                    {
                        ssid = [ssid substringToIndex:ssid.length - 3];
                        if(ssid &&[ssid hasSuffix:ASLocalizedString(@"_重名")])
                        {
                            ssid = [ssid substringToIndex:ssid.length - 3];
                        }
                    }
                    [renameDict setObject:ssid forKey:@"ssid"];
                    [renameDict setObject:@"isRename" forKey:@"isrename"];
                    [self.wifiDataArray addObject:renameDict];
                }
                else
                {
                    [self.wifiDataArray addObject:wifiDict];
                }
            }
        }
    }
    return self;
}

- (NSString *)renameWifiSSID:(NSString *)ssid
{
    return nil;
}
@end
