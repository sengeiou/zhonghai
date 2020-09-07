//
//  XTRecorderView.h
//  XT
//
//  Created by Gil on 13-7-8.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "XTRecorderProgressView.h"

typedef enum _RecorderState{
    RecorderStateRecording,
    RecorderStateRecordCancel
}RecorderState;

@interface XTRecorderView : UIView

@property (nonatomic, assign) RecorderState state;
@property (nonatomic, assign) BOOL counting;//倒数计数

@property (nonatomic, strong) UILabel *countdownLabel;
@property (nonatomic, strong) UIImageView *promptBackgroundImageView;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIImageView *microphoneImageView;
@property (nonatomic, strong) UIImageView *volumeImageView;
@property (nonatomic, strong) UIImageView *trashImageView;
//@property (nonatomic, retain) XTRecorderProgressView *progressView;

//- (void)setProgress:(int)progress;
- (void)setVolume:(float)volume;

@end
