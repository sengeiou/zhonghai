//
//  ResourceManager.h
//  TwitterFon
//
//  Created by apple on 11-6-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//资源管理器
@interface ResourceManager : NSObject {
    
}

//+ (UIImage*)defaultBackGroudImage;//View缺省的底图
+ (UIColor*)defaultBackGroudColor;//缺省的TableView的背景色
//+ (UIImage*)photoFrameImage;//图片的外框Image
+ (UIColor*)defaultRowBackGroudColor;//缺省的TableCell的行的颜色

+ (UIImage*)repostImage;//转载框图片
+ (UIImage*)repostImagePressed;//转载框图片

+(UIColor *) commentBackgroudColor;//评论区域的背景色
+ (UIImage*)imageback;
+(NSString*)InfoString;
//+(UIImage*) topicSelectBackgroudImage;
//+(UIImage*) sinaImage;
//+(UIImage*)profileFrame;
+ (UIImage*)imagebacks;
//+ (UIImage*)imageAttachment;
//+ (UIImage*)photoFrameImages;
+ (UIView *)noDataPromptView;

@end
