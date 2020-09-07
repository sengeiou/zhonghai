//
//  UILabel+Additions.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-6-8.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "UILabel+Additions.h"

@implementation UILabel (KD_Utility)

+ (id) infoLabelForTableFooterView:(CGRect)rect {
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:rect];// autorelease];
    
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textColor = [UIColor grayColor];
    infoLabel.font = [UIFont systemFontOfSize:15.0];
    infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    
    infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return infoLabel;
}

@end
