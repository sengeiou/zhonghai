//
//  KDCustomSearchDisplayController.m
//  kdweibo
//
//  Created by Darren on 15/4/1.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDCustomSearchDisplayController.h"

@implementation KDCustomSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive: visible animated: animated];
    
//    //move the dimming part down
//    for (UIView *subview in self.searchContentsController.view.subviews) {
//        //NSLog(@"%@", NSStringFromClass([subview class]));
//        if ([subview isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")])
//        {
//            CGRect frame = subview.frame;
//            frame.origin.y += 100000;
//            subview.frame = frame;
//        
//        
//        }
//    }
    
//    for(UIView * v in self.searchContentsController.view.subviews)
//    {
//        if([v isMemberOfClass:[UIControl class]])
//        {
//            v.backgroundColor = [UIColor clearColor];
//        }
//    }
    
}
@end
