//
//  KDThumbnailWrapperView.h
//  kdweibo
//
//  Created by Tan yingqi on 12-12-28.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDThumbnailView.h"

@interface KDThumbnailWrapperView :UIView

@property(nonatomic,retain)NSArray *thumbnailViews;
@property(nonatomic,retain)id<KDImageDataSource> imageDataSource;
@end
