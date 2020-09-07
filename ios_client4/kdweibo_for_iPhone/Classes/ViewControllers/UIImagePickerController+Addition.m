//
//  UIImagePickerController+Addition.m
//  kdweibo
//
//  Created by bird on 13-12-3.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "UIImagePickerController+Addition.h"

@implementation UIImagePickerController (Addition)

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    }

//    if (isAboveiOS7) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera)
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    
//    if (isAboveiOS7) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera)
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    
//    if (isAboveiOS7) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }
}

@end
