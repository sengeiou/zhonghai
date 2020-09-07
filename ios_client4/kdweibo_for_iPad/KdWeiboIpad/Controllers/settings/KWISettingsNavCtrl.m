//
//  KWISettingsNavCtrl.m
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/1/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import "KWISettingsNavCtrl.h"

#import <QuartzCore/QuartzCore.h>

#import "SCNavigationBar.h"

#import "UIDevice+KWIExt.h"

#import "KWISettingsPgVCtrl.h"

@interface KWISettingsNavCtrl ()

@end

@implementation KWISettingsNavCtrl

+ (KWISettingsNavCtrl *)navCtrlWithRoot:(UIViewController *)rootVCtrl
{
    // init without rootVC as rootVC will be lost after archive and unarchive
    // push after unarchive instead
    KWISettingsNavCtrl *inst = [[self alloc] init];
    [inst navigationBar]; // ensure loading 
    
    // Archive the navigation controller.
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:inst forKey:@"root"];
    [archiver finishEncoding];
    [archiver release];
    [inst release];
    
    // Unarchive the navigation controller and ensure that our UINavigationBar subclass is used.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [unarchiver setClass:[SCNavigationBar class] forClassName:@"UINavigationBar"];
    KWISettingsNavCtrl *newInst = [unarchiver decodeObjectForKey:@"root"];
    [unarchiver finishDecoding];
    [unarchiver release];
    
    // Modify the navigation bar to have a background image.
    SCNavigationBar *navBar = (SCNavigationBar *)[newInst navigationBar];    
    [navBar setBackgroundImage:[UIImage imageNamed:@"settingsNavBarBg.png"] forBarMetrics:UIBarMetricsDefault];   
    
    // these properties are configured after unarchive
    // or will not work in ios4
    newInst.modalPresentationStyle = UIModalPresentationFormSheet;
    newInst.view.backgroundColor = [UIColor clearColor];
    
    // push rootvc to fake
    [newInst pushViewController:rootVCtrl animated:NO];
    
    return newInst;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage *bgimg = [UIImage imageNamed:@"settingsBg.png"];
    UIImageView *bgV = [[[UIImageView alloc] initWithImage:bgimg] autorelease];
    bgV.contentStretch = CGRectMake(0, 0, 1, 0.5);
    bgV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    bgV.frame = self.view.bounds; 
    
    [self.view insertSubview:bgV atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.superview.layer.cornerRadius = 10;
    self.view.superview.clipsToBounds = YES;
}

@end
