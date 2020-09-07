//
//  KDSignInOverTimeModel.h
//  kdweibo
//
//  Created by 张培增 on 2017/1/22.
//  Copyright © 2017年 www.kingdee.com. All rights reserved.
//

//#import "KDJSONModel.h"

@interface KDSignInOverTimeModel : NSObject

@property (nonatomic, strong) NSString *thumbnailUrl;   //弹窗背景图URL
@property (nonatomic, strong) NSString *bigPictureUrl;  //用于分享的大图URL


// 弹窗信息
@property (nonatomic, strong) NSString *alertClockInTime;
@property (nonatomic, strong) NSArray *alertCeilTextArray;
@property (nonatomic, strong) NSString *alertContent;
@property (nonatomic, strong) NSString *alertAuthor;

// 分享图片信息
@property (nonatomic, strong) NSString *shareClockInTime;
@property (nonatomic, strong) NSArray *shareCeilTextArray;
@property (nonatomic, strong) NSString *shareContent;
@property (nonatomic, strong) NSString *shareAuthor;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
