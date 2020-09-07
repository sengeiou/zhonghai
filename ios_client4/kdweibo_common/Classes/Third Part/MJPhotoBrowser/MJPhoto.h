//
//  MJPhoto.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <Foundation/Foundation.h>

@interface MJPhoto : NSObject
@property (nonatomic, strong) NSURL *originUrl;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIImage *image; // 完整的图片

@property (nonatomic, strong) UIImageView *srcImageView; // 来源view
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, strong, readonly) UIImage *capture;

@property (nonatomic, assign) BOOL firstShow;

@property (nonatomic, assign) BOOL isGif;

// 是否已经保存到相册
@property (nonatomic, assign) BOOL save;
@property (nonatomic, assign) int index; // 索引

#pragma mark modified by Darren in 2014.6.12
@property (nonatomic, strong) NSURL *thumbnailPictureUrl; // 缩略图url
@property (nonatomic, strong) NSURL *midPictureUrl; // 原图的缩略图url
@property (nonatomic, strong) NSString *isOriginalPic; // 是否为原图
@property (nonatomic, assign) NSInteger direction;
@property (nonatomic, strong) NSString *photoLength;

@property (nonatomic, assign) BOOL bFullScrean; // 以全屏形式显示该图
@property (nonatomic, assign) int isQRImage; //0是还没判断，－1不是二维码，1是二维码
@property (nonatomic, weak) id tempData;//用于存储一些临时数据


-(BOOL)isQRCodeImage;
- (NSString *)scanQRWithImage:(UIImage *)srcImage;
@end