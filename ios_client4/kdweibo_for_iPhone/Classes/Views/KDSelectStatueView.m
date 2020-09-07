//
//  KDSelectStatueView.m
//  kdweibo
//
//  Created by Guohuan Xu on 5/10/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDSelectStatueView.h"

@implementation KDSelectStatueView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setViewSelectStatueWith:(SelectViewStatue)selectViewStatue
{
    NSString *imageName = nil;
    
    switch (selectViewStatue) {
        case SelectViewStatueUnSelected:
            imageName = @"notSelect.png";
            break;
        case SelectViewStatueHasSelected:
            imageName = @"nowSelect.png";
            break;
        default:
            break;
    }
    if (imageName) 
    {
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [self setImage:image];
        }
    }
}

+(KDSelectStatueView *)makeDefaultSelectStatueView
{
    KDSelectStatueView * selectStatueView = [[KDSelectStatueView alloc] initWithFrame:CGRectMake(0, 0, SELECT_STATUE_VIEW_WIDHT, SELECT_STATUE_VIEW_WIDHT)];// autorelease];
    [selectStatueView setBackgroundColor:[UIColor clearColor]];
    return selectStatueView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
