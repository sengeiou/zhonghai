//
//  KDMenuItem.m
//  kdweibo
//
//  Created by Jiandong Lai on 12-7-24.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import "KDCommon.h"
#import "KDMenuItem.h"

#import "KDMenuView.h"

@interface KDMenuItem ()

@property(nonatomic, retain) UIView *customView;

@end

@implementation KDMenuItem

@dynamic menuView;

@synthesize customView=customView_;

- (id)initWithCustomView:(UIView *)customView {
    self = [super init];
    if (self) {
        customView_ = customView;// retain];
    }
    
    return self;
}

- (void)setMenuView:(KDMenuView *)menuView {
    if(menuView_ != menuView){
        menuView_ = menuView;
    
        if(menuView_ != nil && customView_ != nil && customView_.superview != menuView){
            [menuView_ addSubview:customView_];
        }
    }
}

- (KDMenuView *)menuView {
    return menuView_;
}


- (void)dealloc {
    menuView_ = nil;
    //KD_RELEASE_SAFELY(customView_);
    
    //[super dealloc];
}

@end
