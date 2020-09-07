//
//  KWISettingsPgVCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/2/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWISettingsPgVCtrl.h"

@interface KWISettingsPgVCtrl ()

@end

@implementation KWISettingsPgVCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (nil == self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = [self makeBarButtonWithLabel:@"返回" 
                                                                       image:[UIImage imageNamed:@"settingsCloseBtn.png"] 
                                                                      target:self
                                                                      action:@selector(_back)];;
    }
}

- (void)configTitle:(NSString *)title
{
    UILabel *titleV = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 100)] autorelease]; 
    titleV.backgroundColor = [UIColor clearColor];
    titleV.font = [UIFont systemFontOfSize:18];
    titleV.textColor = [UIColor whiteColor];
    titleV.textAlignment = UITextAlignmentCenter;
    titleV.text = title;
    [titleV sizeToFit];
    self.navigationItem.titleView = titleV;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (UIBarButtonItem *)makeBarButtonWithLabel:(NSString *)label 
                               image:(UIImage *)image 
                              target:(id)target 
                              action:(SEL)action
{
    CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = image.size;
    
    UIButton *btn = [[[UIButton alloc] initWithFrame:frame] autorelease];
    
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setTitle:label forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.titleLabel.textColor = [UIColor colorWithRed:238.0/255 green:238.0/255 blue:238.0/255 alpha:1];
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];    
    
    return [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
}

- (void)_back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
