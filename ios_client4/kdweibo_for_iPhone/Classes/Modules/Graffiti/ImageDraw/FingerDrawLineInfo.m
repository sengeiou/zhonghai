//
//  FingerDrawLineInfo.m
//  kdweibo
//
//  Created by kingdee on 2017/8/23.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

#import "FingerDrawLineInfo.h"

@implementation FingerDrawLineInfo
- (instancetype)init {
    if (self=[super init]) {
        self.linePoints = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}
@end
