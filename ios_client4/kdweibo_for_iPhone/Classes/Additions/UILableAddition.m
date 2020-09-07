//
//  UILableAddition.m
//  kdweibo
//
//  Created by Guohuan Xu on 4/11/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "UILableAddition.h"

@implementation  UILabel(Category)
//set text to avoid show null in lab
-(void)setTextAvoidShowNull:(NSString *)text
{
    if (text == nil ||(id)text == [NSNull null]) {
        [self setText:@""];
    }
    [self setText:text];
}
@end
