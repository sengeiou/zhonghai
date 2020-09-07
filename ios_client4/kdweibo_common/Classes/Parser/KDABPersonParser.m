//
//  KDABPersonParser.m
//  kdweibo_common
//
//  Created by laijiandong on 12-12-6.
//  Copyright (c) 2012年 kingdee. All rights reserved.
//

#import "KDABPersonParser.h"

@implementation KDABPersonParser

- (NSArray *)parse:(NSArray *)body type:(KDABPersonType)type {
    NSUInteger count = 0;
    if (body == nil || (count = [body count]) == 0) return nil;
    
    KDABPerson *p = nil;
    NSMutableArray *persons = [NSMutableArray arrayWithCapacity:count];
    
    for (NSDictionary *item in body) {
        p = [[KDABPerson alloc] initWithType:type];
        
        p.pId = [item stringForKey:@"id"];
        p.userId = [item stringForKey:@"userId"];
        p.networkId = [item stringForKey:@"networkId"];
        
        p.jobTitle = [item stringForKey:@"jobTitle"];
        p.department = [item stringForKey:@"department"];
        
        p.favorited = [item boolForKey:@"collect"];
        
        NSString *url = [item stringForKey:@"headUrl"];
        if (url != nil && [url length] > 0) {
            p.profileImageURL = [url stringByAppendingString:@"&spec=180"];
        }
        
        p.name = [item stringForKey:@"name"];
        
        p.mobiles = [item objectNotNSNullForKey:@"mobiles"];
        p.phones = [item objectNotNSNullForKey:@"phones"];
        p.emails = [item objectNotNSNullForKey:@"emails"];
        
        [persons addObject:p];
//        [p release];
    }
    
    return persons;
}

@end
