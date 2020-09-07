//
//  KDABRecord.m
//  kdweibo
//
//  Created by shen kuikui on 13-10-24.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDABRecord.h"

@implementation KDABRecord
@synthesize name = _name;
@synthesize phoneNumber = _phoneNumber;

- (void)dealloc
{
//    [_name release];
//    [_phoneNumber release];
//    
    //[super dealloc];
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[self class]]) {
        KDABRecord *record = (KDABRecord *)object;
        
        if([record.name isEqualToString:self.name]) {
            return YES;
        }
    }
    
    return NO;
}
@end
