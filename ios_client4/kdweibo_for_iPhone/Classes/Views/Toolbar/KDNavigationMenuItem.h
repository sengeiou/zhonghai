//
//  KDNavigationMenuItem.h
//  kdweibo
//
//  Created by Tan yingqi on 13-11-21.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDNavigationMenuItem : NSObject

@property(nonatomic,copy)NSString *imageName;
@property(nonatomic,copy)NSString *selectedImageName;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *iconImageName;
+ (KDNavigationMenuItem *)menuItemWithImageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName title:(NSString *)title iconImageName:(NSString *)iconImageName;
@end
