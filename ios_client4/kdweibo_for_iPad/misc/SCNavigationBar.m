//
//  SCNavigationBar.m
//  ExampleNavBarBackground
//
//  Created by Sebastian Celis on 3/1/2012.
//  Copyright 2012-2012 Sebastian Celis. All rights reserved.
//

#import "SCNavigationBar.h"

#import <QuartzCore/QuartzCore.h>

@interface SCNavigationBar ()
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) NSMutableDictionary *backgroundImages;
- (void)updateBackgroundImage;
@end


@implementation SCNavigationBar

@synthesize backgroundImages = _backgroundImages;
@synthesize backgroundImageView = _backgroundImageView;

#pragma mark - View Lifecycle

- (void)dealloc
{
    [_backgroundImages release];
    [_backgroundImageView release];
    [super dealloc];
}

#pragma mark - Background Image

- (NSMutableDictionary *)backgroundImages
{
    if (_backgroundImages == nil)
    {
        _backgroundImages = [[NSMutableDictionary alloc] init];
    }
    
    return _backgroundImages;
}

- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil)
    {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self insertSubview:_backgroundImageView atIndex:0];
    }
    
    return _backgroundImageView;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics
{
    if ([UINavigationBar instancesRespondToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [super setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    }
    else
    {
        [[self backgroundImages] setObject:backgroundImage forKey:[NSNumber numberWithInt:barMetrics]];
        [self updateBackgroundImage];
    }
}

- (void)updateBackgroundImage
{
    UIBarMetrics metrics = ([self bounds].size.height > 40.0) ? UIBarMetricsDefault : UIBarMetricsLandscapePhone;
    UIImage *image = [[self backgroundImages] objectForKey:[NSNumber numberWithInt:metrics]];
    if (image == nil && metrics != UIBarMetricsDefault)
    {
        image = [[self backgroundImages] objectForKey:[NSNumber numberWithInt:UIBarMetricsDefault]];
    }
    
    if (image != nil)
    {
        // origin 
        // ------
        // [[self backgroundImageView] setImage:image];
        // snow mod
        // ---------
        UIImageView *bgv = [self backgroundImageView];        
        CGRect frame = bgv.frame;
        frame.size = image.size;
        bgv.frame = frame;
        bgv.image = image;
        // end snow mod
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_backgroundImageView != nil)
    {
        [self updateBackgroundImage];
        [self sendSubviewToBack:_backgroundImageView];
    }
    
    UINavigationItem *topItem = self.topItem;
    
    CGRect titleFrame = topItem.titleView.frame;
    titleFrame.origin.y += 3;
    topItem.titleView.frame = titleFrame;
    
    UIBarButtonItem *lbtn = topItem.leftBarButtonItem;
    if (lbtn) {
        UIView *btnV = [lbtn valueForKey:@"view"];
        CGRect frame = btnV.frame;
        frame.origin.x += 2;
        frame.origin.y += 4;
        btnV.frame = frame;
    }
    
    UIBarButtonItem *rbtn = topItem.rightBarButtonItem;
    if (rbtn) {
        UIView *btnV = [rbtn valueForKey:@"view"];
        CGRect frame = btnV.frame;
        frame.origin.x -= 2;
        frame.origin.y += 4;
        btnV.frame = frame;
    }
}



@end
