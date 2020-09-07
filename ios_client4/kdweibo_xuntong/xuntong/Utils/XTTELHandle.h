//
//  XTTELHandle.h
//  XT
//
//  Created by Gil on 13-7-23.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTTELHandle : NSObject

+(XTTELHandle *)sharedTELHandle;

- (void)telWithPhoneNumbel:(NSString *)phoneNumber;

@end
