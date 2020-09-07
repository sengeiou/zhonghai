//
//  KDSignInOverTimeModel.m
//  kdweibo
//
//  Created by 张培增 on 2017/1/22.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "KDSignInOverTimeModel.h"

@implementation KDSignInOverTimeModel

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    if (!dictionary) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        self.bigPictureUrl = [dictionary stringForKey:@"bigPictureUrl" defaultValue:@""];
        self.thumbnailUrl = [dictionary stringForKey:@"thumbnailUrl" defaultValue:@""];
        
        NSDictionary *alertInfo = [dictionary objectForKey:@"alertInfo"];
        NSDictionary *alert = [alertInfo objectForKey:@"alert"];
        NSDictionary *share = [alertInfo objectForKey:@"share"];
        
        self.alertCeilTextArray = [alert objectForKey:@"ceilText"] ?: @[];
        self.alertClockInTime = [alert stringForKey:@"clockInTime" defaultValue:@""];
        self.alertContent = [alert stringForKey:@"tipsText" defaultValue:@""];
        self.alertAuthor = [alert stringForKey:@"tipsAuthor" defaultValue:@""];

        self.shareCeilTextArray = [share objectForKey:@"ceilText"] ?: @[];
        self.shareClockInTime = [share stringForKey:@"clockInTime" defaultValue:@""];
        self.shareContent = [share stringForKey:@"tipsText" defaultValue:@""];
        self.shareAuthor = [share stringForKey:@"tipsAuthor" defaultValue:@""];
        
    }
    return self;
}

@end
