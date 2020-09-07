//
//  KDMockDownloadListener.h
//  kdweibo
//
//  Created by Tan yingqi on 8/1/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDDownloadListener.h"

@interface KDMockDownloadListener : NSObject{
}

- (id)initWithDownloadListener:(id<KDDownloadListener>)listener;

@property(nonatomic, assign) id<KDDownloadListener> listener;
@end

