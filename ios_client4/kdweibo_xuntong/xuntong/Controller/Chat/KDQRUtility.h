//
//  KDQRUtility.h
//  kdweibo
//
//  Created by KongBo on 15/10/21.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDQRUtility : NSObject

+ (CIImage *)createQRForString:(NSString *)qrString;
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

@end
