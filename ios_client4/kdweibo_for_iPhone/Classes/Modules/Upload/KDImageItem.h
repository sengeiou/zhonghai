//
//  KDImageItem.h
//  kdweibo
//
//  Created by Tan yingqi on 13-5-16.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol KDImageItemDelegate<NSObject>
@optional
- (void)thumbImageDidLoad:(UIImage *)image;
- (void)orignImageDidLoad:(UIImage *)image;
@end

@interface KDImageItem : NSObject
@property(nonatomic,copy)NSString *url;
@property(nonatomic,retain)UIImage *image;
@property(nonatomic,assign)id<KDImageItemDelegate> delegate;
-(void)startLoad;
- (void)loadOrignImage;
@end