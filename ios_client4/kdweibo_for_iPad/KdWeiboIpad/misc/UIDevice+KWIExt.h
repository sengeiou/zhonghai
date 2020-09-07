//
//  UIDevice+KWIExt.h
//  KdWeiboIpad
//
//  Created by Snow Hellsing on 7/12/12.
//  Copyright (c) 2012 MyColorWay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (KWIExt)

+ (CGFloat)curSysVer;
+ (BOOL)isPortrait;

+ (NSString *) platform;
+ (NSString *) platformString;

@end
