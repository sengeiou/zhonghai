//
//  KDStatusExtraMessageParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDStatusExtraMessageParser.h"

#import "KDStatusExtraMessage.h"


@implementation KDStatusExtraMessageParser

- (KDStatusExtraMessage *)parse:(NSDictionary *)body {
    if (body == nil || [body count] == 0) return nil;
    
    KDStatusExtraMessage *m = [[KDStatusExtraMessage alloc] init];//／／ autorelease];
    
    m.extraId = [body stringForKey:@"id"];
    m.applicationURL = [body stringForKey:@"appUrl"];
    m.type = [body stringForKey:@"type"];
    m.referenceId = [body stringForKey:@"refId"];
    m.tenantId = [body stringForKey:@"tenantId"];
    
    id props = [body objectNotNSNullForKey:@"properties"];
    if (props != nil) {
        NSDictionary *dic = props;
        m.exectorId = [dic stringForKey:@"userId"];
        m.exctorName = [dic stringForKey:@"userName"];
        m.visibility = [dic stringForKey:@"visibility"];
        m.content = [dic stringForKey:@"content"];
        m.needFinishDate = [[dic ASCDatetimeWithMillionSecondsForKey:@"needFinishDate"] timeIntervalSince1970];
        [m setProperty:props forKey:kKDStatusExtraMessageProperties];
    }
    
    id tempProps = [body objectNotNSNullForKey:@"tempProps"];
    if (tempProps != nil) {
        [m setProperty:tempProps forKey:kKDStatusExtraMessageTemporaryProperties];
    }
    
    return m;
}

@end
