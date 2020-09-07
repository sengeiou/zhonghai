//
//  VideoPlayer.h
//  Video-Pre-research
//
//  Created by 王 松 on 13-6-6.
//  Copyright (c) 2013年 王松. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KDVideoPlayerManagerDelegate;

@interface KDVideoPlayerManager : NSObject
{
    BOOL isPlaying;
}

@property (nonatomic, copy) NSURL *contentURL;

@property (nonatomic, assign) id<KDVideoPlayerManagerDelegate> delegate;

//是否为小视频 如果是则按不同尺寸，循环方式播放
@property (nonatomic, assign) BOOL shortVideoType;

- (void)startPlayInView:(UIView *)view;

- (void)stopPlay;

+ (CGFloat)secondsOfVideoOfPath:(NSString *)path;

+ (KDVideoPlayerManager *)sharedInstance;

- (CGSize)videoNaturalSize;

- (void)resetPlayViewBounds:(CGRect)bounds;


@end

@protocol KDVideoPlayerManagerDelegate <NSObject>

- (void)videoPlayFinished:(KDVideoPlayerManager *)player;

@optional
- (void)currentTimeOfVideo:(CGFloat)seconds;

@end
