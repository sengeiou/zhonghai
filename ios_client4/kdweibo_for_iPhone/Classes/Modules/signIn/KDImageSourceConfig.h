//
//  KDImageSourceConfig.h
//  kdweibo
//
//  Created by shifking on 15/10/30.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KDImageSource;
@interface KDImageSourceConfig : NSObject

+ (KDImageSource *)getImageSourceByPicId:(NSString *)picId;

@end
