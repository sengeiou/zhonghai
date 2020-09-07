//
//  KDStatusCoreTextDelegate.h
//  kdweibo
//
//  Created by shen kuikui on 12-12-13.
//  Copyright (c) 2012年 www.kingdee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDThumbnailView2.h"
@class KDStatusContentDetailView;
@protocol KDStatusCoreTextDelegate <NSObject, KDThumbnailViewDelegate2>

@optional
- (void)clickedUserWithUserName:(NSString *)userName;
- (void)clickedTopicWithTopicName:(NSString *)topicName;
- (void)clickedURL:(NSString *)urlString;
- (void)contentViewDidChangeFrame:(CGRect)frame content:(KDStatusContentDetailView *)view;

@end
