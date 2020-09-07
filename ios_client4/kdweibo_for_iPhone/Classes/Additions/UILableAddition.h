//
//  UILableAddition.h
//  kdweibo
//
//  Created by Guohuan Xu on 4/11/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UILabel(Category)
//set text to avoid show null in lab
-(void)setTextAvoidShowNull:(NSString *)text;

@end
