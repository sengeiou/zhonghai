//
//  KDNavigationMenuItem.m
//  kdweibo
//
//  Created by Tan yingqi on 13-11-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDNavigationMenuItem.h"

@implementation KDNavigationMenuItem
@synthesize imageName = imageName_;
@synthesize selectedImageName = selectedImageName_;
@synthesize title = title_;
@synthesize iconImageName = iconImageName_;
+(KDNavigationMenuItem *)menuItemWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName title:(NSString *)title iconImageName:(NSString *)iconImageName {
    KDNavigationMenuItem *item = [[KDNavigationMenuItem alloc] init];// autorelease];
    item.imageName = imageName;
    item.selectedImageName = selectedImageName;
    item.title = title;
    item.iconImageName = iconImageName;
    return item;
}
- (void)dealloc {
    //KD_RELEASE_SAFELY(imageName_);
    //KD_RELEASE_SAFELY(selectedImageName_);
    //KD_RELEASE_SAFELY(title_);
    //KD_RELEASE_SAFELY(iconImageName_);
//    [super dealloc ];
}
@end
