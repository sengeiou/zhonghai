//
//  KDSignInParser.m
//  kdweibo_common
//
//  Created by Tan yingqi on 13-8-23.
//  Copyright (c) 2013年 kingdee. All rights reserved.
//

#import "KDSignInParser.h"

@implementation KDSignInParser
- (KDSignInRecord *)parse:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDSignInRecord *s = [[KDSignInRecord alloc] init];
    s.singinId = [body stringForKey:@"id"];
    s.content = [body stringForKey:@"content"];
    s.status = [body integerForKey:@"status"];
    s.latitude = [body floatForKey:@"latitude"];
    s.longitude = [body floatForKey:@"longitude"];
    s.singinTime =  [NSDate dateWithTimeIntervalSince1970:[body doubleForKey:@"datetime"] / 1000];
    s.featurename = [body stringForKey:@"featurename"];
    s.mbShare = [body stringForKey:@"mbShare"];
    //    s.attendSetName = [body stringForKey:@"attendSetName"];
    s.attendSetId = [body stringForKey:@"attendSetId"];
    //    s.needRelativeWiFi = [body boolForKey:@"needRelativeWiFi"];
    //    s.canAutoClockIn = [body boolForKey:@"canAutoClockIn"];
    s.photoIds = [body stringForKey:@"photoIds"];
    if(s.photoIds && ![s.photoIds isKindOfClass:[NSNull class]])
    {
        if(s.photoIds.length >0 && [s.photoIds hasSuffix:@","])
        {
            s.photoIds = [s.photoIds substringToIndex:s.photoIds.length - 1];
        }
    }
    
    s.clockInTypeStr = [body stringForKey:@"clockInType"];
    if (s.clockInTypeStr && [s.clockInTypeStr isEqualToString:@"p"]) {
        s.clockInType = @"photo";
    }
    s.extraRemark = [body stringForKey:@"extraRemark"];
    s.medalDic = (([body objectForKey:@"medal"] == [NSNull null])?nil:[body objectForKey:@"medal"]);
    s.attendanceTipsDic = [body objectForKey:@"attendanceTips"];
    s.attendanceActivityDic = [body objectForKey:@"attendanceActivity"];
    s.exceptionType = [body stringForKey:@"exceptionType"];
    s.exceptionMinitues = [body floatForKey:@"exceptionMinitues"];
    s.workTime = [body stringForKey:@"workTime"];
    s.hasLeader = [body integerForKey:@"hasLeader"];
    s.exceptionFeedbackReason = [body stringForKey:@"exceptionFeedbackReason"];
    return s;
}

- (NSArray *)parseSignIns:(NSArray *)array {
    NSArray *returnArray = nil;
    if (array && [array count] >0) {
        NSMutableArray *theArray = [NSMutableArray array];
        KDSignInRecord *record = nil;
        for (NSDictionary *dic in array) {
            record = [self parse:dic];
            if (record) {
                [theArray addObject:record];
            }
        }
        returnArray = [NSArray arrayWithArray:theArray];
    }
    
    return returnArray;
}
@end
