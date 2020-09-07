//
//  BubbleTableViewSearchCell.m
//  kdweibo
//
//  Created by wenbin_su on 15/7/16.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "BubbleTableViewSearchCell.h"

@implementation BubbleTableViewSearchCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//-(void)fileButtonClick:(id)sender
-(void)fileButtonClick:(id)sender
{
    [self postSearchFile];
}


-(void)openImageView
{
//    self.dataInternal.record;
    [self postSearchFile];
}

- (void)clickTextMessage {
    [self postSearchFile];
}

-(void)postSearchFile
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"chatSearchFileClick" object:self.dataInternal.record];
}

@end
