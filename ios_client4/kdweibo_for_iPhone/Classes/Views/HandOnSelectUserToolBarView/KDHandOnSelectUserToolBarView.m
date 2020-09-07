//
//  HandOnSelectUserToolBarView.m
//  kdweibo
//
//  Created by Guohuan Xu on 5/10/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDHandOnSelectUserToolBarView.h"
#define HAND_OND_SELECT_USER_TOOL_BAR_HEIGHT (95.0/2)

@interface KDHandOnSelectUserToolBarView()

@property(assign,nonatomic)BOOL isLoaded;

@end

@implementation KDHandOnSelectUserToolBarView
@synthesize isLoaded = isLoaded;

-(void)drawRect:(CGRect)rect
{
    if (!self.isLoaded) {
        self.isLoaded = YES;
        [self setWidth:self.superview.width];
        [self setHeight:HAND_OND_SELECT_USER_TOOL_BAR_HEIGHT];
        
        UIImage *bgImage = [UIImage stretchableImageWithImageName:@"KDHandOnSelectUserToolBarViewBg.png" leftCapWidth:2 topCapHeight:0];
        
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
        [imageView setSize:self.size];
        [self addSubview:imageView];
    }
}


+(KDHandOnSelectUserToolBarView *)makeDefaulHandOnSelectUserToolBarView
{
    KDHandOnSelectUserToolBarView * handOnSelectUserToolBarView = [[[KDHandOnSelectUserToolBarView alloc] initWithFrame:CGRectZero] autorelease];
    return handOnSelectUserToolBarView;
}

@end
