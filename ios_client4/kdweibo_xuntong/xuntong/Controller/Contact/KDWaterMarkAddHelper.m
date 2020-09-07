//
//  KDWaterMarkAddHelper.m
//  kdweibo
//
//  Created by 张培增 on 16/1/20.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDWaterMarkAddHelper.h"
#import "UIView+WaterMark.h"
#import "NSString+Match.h"
#import "BOSConfig.h"

@implementation KDWaterMarkAddHelper

+ (void)addToBackgroundViewOfTableView:(UITableView *)tableView {
    [self removeWaterMarkFromTableView:tableView];
    UIView *view = [UIView waterMarkView:[self getWaterMark] withFrame:tableView.superview.bounds];
    view.tag = 10000;
    [tableView.superview insertSubview:view belowSubview:tableView];
}

+ (void)removeWaterMarkFromTableView:(UITableView *)tableView {
    UIView *waterMarkView = [tableView.superview viewWithTag:10000];
    if (waterMarkView) {
        [waterMarkView removeFromSuperview];
    }
}

+ (void)coverOnView:(UIView *)view withFrame:(CGRect)frame {
    [self removeWaterMarkFromView:view];
    UIView *waterMarkView = [UIView waterMarkView:[self getWaterMark] withFrame:frame];
    waterMarkView.userInteractionEnabled = NO;
    waterMarkView.backgroundColor = [UIColor clearColor];
    waterMarkView.tag = 10000;
    [view addSubview:waterMarkView];
    [view bringSubviewToFront:waterMarkView];
}

+ (void)removeWaterMarkFromView:(UIView *)view {
    UIView *waterMarkView = [view viewWithTag:10000];
    if (waterMarkView) {
        [waterMarkView removeFromSuperview];
    }
}

+ (NSString *)getWaterMark {
//    NSString *prefixStr = [BOSConfig sharedConfig].user.name;
//    if (prefixStr.length > 4) {
//        prefixStr = [prefixStr substringToIndex:4];
//    }
    
    NSString *suffixStr = @"";
//    if ([BOSConfig sharedConfig].user.phone.length > 0 && [[BOSConfig sharedConfig].user.phone isMobileNumber]) {
//        if (prefixStr.length == 0) {
//            suffixStr = [BOSConfig sharedConfig].user.phone;
//        }
//        else {
//            if ([BOSConfig sharedConfig].user.phone.length >= 4) {
//                suffixStr = [[BOSConfig sharedConfig].user.phone substringFromIndex:[BOSConfig sharedConfig].user.phone.length - 4];
//            }
//            else {
//                suffixStr = [BOSConfig sharedConfig].user.phone;
//            }
//        }
//    }
//    else if ([BOSConfig sharedConfig].user.email.length > 0 && [[BOSConfig sharedConfig].user.email isValidateEmail]) {
//        suffixStr = [BOSConfig sharedConfig].user.email;
//        NSRange range = [suffixStr rangeOfString:@"@"];
//        if (range.length != NSNotFound) {
//            suffixStr = [suffixStr substringToIndex:range.location];
//        }
//    }
//    
   suffixStr = [BOSConfig sharedConfig].loginUser ? [BOSConfig sharedConfig].loginUser : @"";
    
//    NSString *waterMark = [NSString stringWithFormat:@"%@%@", prefixStr, suffixStr];
    NSString *waterMark = suffixStr;
    return waterMark;
}

@end
