//
//  KDMockDownloadListener.m
//  kdweibo
//
//  Created by Tan yingqi on 8/1/12.
//  Copyright (c) 2012 www.kingdee.com. All rights reserved.
//

#import "KDMockDownloadListener.h"

@implementation KDMockDownloadListener 
@synthesize listener = listener_;

- (id)initWithDownloadListener:(id<KDDownloadListener>)listener {
    self = [super init];
    if (self) {
        listener_ = listener;
    }
    return self;
    
}

@end
