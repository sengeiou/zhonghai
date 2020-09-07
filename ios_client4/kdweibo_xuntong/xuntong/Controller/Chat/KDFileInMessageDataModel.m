//
//  KDFileInMessageDataModel.m
//  kdweibo
//
//  Created by janon on 15/3/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDFileInMessageDataModel.h"

@implementation KDFileInMessageDataModel
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict isKindOfClass:[NSNull class]] && dict == nil) {
            return nil;
        }
        else {
            id networkId = [dict objectForKey:@"networkId"];
            id personId = [dict objectForKey:@"personId"];
            id userId = [dict objectForKey:@"userId"];
            id fileId = [dict objectForKey:@"fileId"];
            id messageId = [dict objectForKey:@"messageId"];
            id userName = [dict objectForKey:@"userName"];
            id fileName = [dict objectForKey:@"fileName"];
            id time = [dict objectForKey:@"time"];
            id length = [dict objectForKey:@"length"];
            id contentType = [dict objectForKey:@"contentType"];
            id fileExt = [dict objectForKey:@"fileExt"];
            id encrypted = [dict objectForKey:@"encrypted"];

            if ([self testNullAndNil:networkId]) {
                self.networkId = networkId;
            }
            
            if ([self testNullAndNil:personId]) {
                self.personId = personId;
            }

            if ([self testNullAndNil:userId]) {
                self.userId = userId;
            }

            if ([self testNullAndNil:fileId]) {
                self.fileId = fileId;
            }

            if ([self testNullAndNil:messageId]) {
                self.messageId = messageId;
            }

            if ([self testNullAndNil:userName]) {
                self.userName = userName;
            }

            if ([self testNullAndNil:encrypted]) {
                self.encrypted = [encrypted integerValue];
            }

            if ([self testNullAndNil:fileName]) {
                self.fileName = fileName;
            }

            if ([self testNullAndNil:time]) {
                self.time = [NSDate dateWithTimeIntervalSince1970:[time doubleValue] / 1000];
            }

            if ([self testNullAndNil:length]) {
                self.length = length;
            }

            if ([self testNullAndNil:contentType]) {
                self.contentType = contentType;
            }

            if ([self testNullAndNil:fileExt]) {
                self.fileExt = fileExt;
            }
        }
    }
    return self;
}

- (BOOL)testNullAndNil:(id)arg {
    return (![arg isKindOfClass:[NSNull class]] && (arg != nil));
}

@end
