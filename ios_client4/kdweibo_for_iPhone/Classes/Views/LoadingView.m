//
//  LoadingView.m
//  TwitterFon
//
//  Created by apple on 11-6-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView



-(id)initLoading
{

    self=[super initWithTitle:@"" message: ASLocalizedString(@"LoadingView_msg")delegate: self cancelButtonTitle: nil otherButtonTitles: nil];
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(20, 30, 20.0f, 20.0f);
    [activityView startAnimating];
    [self addSubview:activityView];
    
    
        

    return  self;
}


-(void) hide
{
    [self dismissWithClickedButtonIndex:0 animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    //[super dealloc];
}

@end
