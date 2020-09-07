//
//  ResourceManager.m
//  TwitterFon
//
//  Created by apple on 11-6-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "KDCommon.h"
#import "ResourceManager.h"

#import "KDCache.h"
#import "KDUtility.h"

@implementation ResourceManager

+(NSString*)InfoString {
    return @"";
}

+ (UIColor*) defaultBackGroudColor {
    return UIColorFromRGB(0xF0F0F0);
}

+ (UIColor*) defaultRowBackGroudColor {
    return UIColorFromRGB(0xF0F0F0);
}

+ (UIColor *) commentBackgroudColor {
    return UIColorFromRGB(0xDADDE0);
}

/*
+ (UIImage*) photoFrameImage {
    return [[KDCache sharedCache] bundleImageWithName:@"photoframe.png" leftCapAnchor:0.5 topCapAnchor:0.5 cache:YES];
}
*/

/*
+ (UIImage*) photoFrameImages {
    return [[KDCache sharedCache] bundleImageWithName:@"photoframes.png" leftCapAnchor:0.5 topCapAnchor:0.5 cache:YES];
}
*/
+ (UIImage*) repostImage {
    return [[KDCache sharedCache] bundleImageWithName:@"repost_frame.png" leftCapAnchor:0.5 topCapAnchor:0.5 cache:YES];
}

+ (UIImage*) repostImagePressed {
    return [[KDCache sharedCache] bundleImageWithName:@"repost_framePressed.png" leftCapAnchor:0.5 topCapAnchor:0.5 cache:YES];
}

//+ (UIImage*) sinaImage {
//    return [[KDCache sharedCache] bundleImageWithName:@"sina.png" leftCapAnchor:0.1 topCapAnchor:0.1 cache:YES];
//}

+ (UIImage*) imageback {
    return [UIImage imageNamed:@"phote_icon.png"];
}

+ (UIImage*) imagebacks {
    return [UIImage imageNamed:@"phote_icon_s.png"];
}

+ (UIView *)noDataPromptView {
   
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 300)];
    [backgroundView setUserInteractionEnabled:YES];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_placeholder_v2.png"]];// autorelease];
    [bgImageView sizeToFit];
     bgImageView.center = CGPointMake(backgroundView.bounds.size.width * 0.5f, backgroundView.bounds.size.height * 0.4);
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    [backgroundView addSubview:bgImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(bgImageView.frame) + 15.0f, backgroundView.bounds.size.width, 15.0f)] ;//autorelease];
    
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15.0f];
    label.textColor = MESSAGE_NAME_COLOR;
    label.text = ASLocalizedString(@"No_Data_Refresh");
    
    [backgroundView addSubview:label];
    return backgroundView;// autorelease];
}

@end