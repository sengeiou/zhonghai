//
//  KDImageSourceConfig.m
//  kdweibo
//
//  Created by shifking on 15/10/30.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDImageSourceConfig.h"
#import "KDImageSource.h"
#import "KDConfigurationContext.h"
@implementation KDImageSourceConfig
+ (KDImageSource *)getImageSourceByPicId:(NSString *)picId {
    KDImageSource *imageSource = [[KDImageSource alloc] init];
    
    KDConfigurationContext *content = [KDConfigurationContext getCurrentConfigurationContext];
    NSString *baseURL = [[content getDefaultPlistInstance] getServerBaseURL];
    
    NSURL *url = [NSURL URLWithString:baseURL];
    
    baseURL = [NSString stringWithFormat:@"http://%@",[url host]];
    
    baseURL = [baseURL stringByAppendingString:@"/microblog/filesvr/"];
    
    imageSource.thumbnail = [baseURL stringByAppendingFormat:@"%@?thumbnail",picId];
    imageSource.middle = [baseURL stringByAppendingFormat:@"%@?big",picId];
    imageSource.original = [baseURL stringByAppendingFormat:@"%@?original",picId];
    return imageSource ;
}
@end
