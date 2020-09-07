//
//  NSString+Match.h
//  kdweibo
//  信息匹配 手机号码
//  Created by KongBo on 15/9/18.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Match)

/**手机号码验证*/
- (BOOL) isMobileNumber;

/**邮箱验证*/
- (BOOL) isValidateEmail;

- (BOOL)isContainLetter;

- (BOOL)isContainChinese;

@end
