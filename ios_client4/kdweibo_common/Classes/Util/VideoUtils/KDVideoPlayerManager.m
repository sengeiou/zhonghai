//
//  VideoPlayer.m
//  Video-Pre-research
//
//  Created by 王 松 on 13-6-6.
//  Copyright (c) 2013年 王松. All rights reserved.
//

#import "KDVideoPlayerManager.h"

#import <AVFoundation/AVFoundation.h>

#ifndef NSEC_PER_SEC
#define NSEC_PER_SEC 1000000000ull
#endif

/* Asset keys */
NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey		= @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";

/* AVPlayer keys */
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";

@interface KDVideoPlayerManager ()
{
    id mTimeObserver;
}

@property (nonatomic, retain) AVPlayer *player;

@property (nonatomic, retain) AVPlayerLayer *playerLayer;

@property (nonatomic, retain) AVPlayerItem *playerItem;

@end

static void *VideoPlayerRateObservationContext = &VideoPlayerRateObservationContext;
static void *VideoPlayerStatusObservationContext = &VideoPlayerStatusObservationContext;
static void *VideoPlayerCurrentItemObservationContext = &VideoPlayerCurrentItemObservationContext;

@implementation KDVideoPlayerManager

+ (KDVideoPlayerManager *)sharedInstance
{
    static KDVideoPlayerManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KDVideoPlayerManager alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        isPlaying = NO;
        _delegate = nil;
    }
    return self;
}

- (void)dealloc
{
    [_player removeObserver:self forKeyPath:kRateKey];
	[_player.currentItem removeObserver:self forKeyPath:kStatusKey];
    _player = nil;
    _playerLayer = nil;
    _playerItem = nil;
    _contentURL = nil;
//    [_player release], _player = nil;
//    [_playerLayer release], _playerLayer = nil;
//    [_playerItem release], _playerItem = nil;
//    [_contentURL release], _contentURL = nil;
    //[super dealloc];
}

- (void)startPlayInView:(UIView *)view
{
    AVAsset *movieAsset    = [AVURLAsset URLAssetWithURL:self.contentURL options:nil];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.playerItem addObserver:self
                       forKeyPath:kStatusKey
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:VideoPlayerStatusObservationContext];
	
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    [self.player addObserver:self
                  forKeyPath:kCurrentItemKey
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:VideoPlayerCurrentItemObservationContext];
    
    /* Observe the AVPlayer "rate" property to update the scrubber control. */
    [self.player addObserver:self
                  forKeyPath:kRateKey
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:VideoPlayerRateObservationContext];
    mTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.f, NSEC_PER_SEC)
                                           queue:NULL /* If you pass NULL, the main queue is used. */
                                      usingBlock:^(CMTime time)
      {
          if ([self.delegate respondsToSelector:@selector(currentTimeOfVideo:)]) {
              [self.delegate currentTimeOfVideo:CMTimeGetSeconds([_player currentTime])];
          }
      }];// retain];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    _playerLayer.frame = view.layer.bounds;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    if (_shortVideoType) {
        _playerLayer.videoGravity = AVLayerVideoGravityResize;
    }
   
    _playerLayer.borderWidth = 2.f;
    _playerLayer.borderColor = [UIColor blackColor].CGColor;
    _playerLayer.masksToBounds = YES;

    [view.layer addSublayer:_playerLayer];

    [self.player seekToTime:kCMTimeZero];
    [self.player play];
    isPlaying = YES;
}

- (void)stopPlay
{
    if (isPlaying) {
        isPlaying = NO;
        
        [self removeObservers];
        [self removePlayerTimeObserver];
        [self.player pause];
        
        [self.playerLayer removeFromSuperlayer];
        if ([self.delegate respondsToSelector:@selector(videoPlayFinished:)]) {
            [self.delegate videoPlayFinished:self];
        }
    }
    
    self.delegate = nil;
}

-(void)removePlayerTimeObserver
{
	if (mTimeObserver)
	{
		[self.player removeTimeObserver:mTimeObserver];
//		[mTimeObserver release];
		mTimeObserver = nil;
	}
}

+ (CGFloat)secondsOfVideoOfPath:(NSString *)path
{
    AVAsset *avAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
//    [avAsset release];
    return duration;
}

- (void)resetPlayViewBounds:(CGRect)bounds
{
    _playerLayer.frame = bounds;
}

- (CGSize)videoNaturalSize
{
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:self.contentURL options:nil];
    NSArray *assetTracks = [movieAsset tracksWithMediaType:AVMediaTypeVideo];
    CGSize size = ((AVAssetTrack *)[assetTracks lastObject]).naturalSize;
    return size;
}

- (void)playFinished:(NSNotification*)aNotification
{
    //小视频播放方式
    if (_shortVideoType) {
        //注册的通知  可以自动把 AVPlayerItem 对象传过来，只要接收一下就OK
        
        AVPlayerItem * p = [aNotification object];
        //关键代码
        [p seekToTime:kCMTimeZero];
        
        [self.player play];
        NSLog(@"重播");
    }
    else //微博播放方式
    {
        isPlaying = NO;
        [self removeObservers];
        
        [self.playerLayer removeFromSuperlayer];
        if ([self.delegate respondsToSelector:@selector(videoPlayFinished:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate videoPlayFinished:self];
            });
        }
    }
}

- (void)removeObservers
{
    [_playerItem removeObserver:self forKeyPath:kStatusKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.playerItem];
    [_player removeObserver:self forKeyPath:kCurrentItemKey];
    
    [_player removeObserver:self forKeyPath:kRateKey];
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
	/* AVPlayerItem "status" property value observer. */
	if (context == VideoPlayerStatusObservationContext)
	{

        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {

            }
                break;
                
            case AVPlayerStatusFailed:
            {
                [self playFinished:nil];
            }
                break;
        }
	}
	/* AVPlayer "rate" property value observer. */
	else if (context == VideoPlayerRateObservationContext)
	{

	}
	/* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
	else if (context == VideoPlayerCurrentItemObservationContext)
	{
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
  
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
        }
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}


@end
