//
//  KDDefaultViewControllerFactory.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-4-23.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDDefaultViewControllerFactory.h"

#import "PostViewController.h"


@implementation KDDefaultViewControllerFactory

- (id) init {
    self = [super init];
    if(self){
    
    }
    
    return self;
}

//修正弹出高度问题 王松 2013-10-16
- (PostViewController *) getPostViewController {
    PostViewController *vc = [[PostViewController alloc] initWithNibName:nil bundle:nil];// autorelease];
    [KDWeiboAppDelegate setExtendedLayout:vc];
    return vc;
}

- (void) dealloc {
    //[super dealloc];
}

@end
