//
//  XTRecorderView.m
//  XT
//
//  Created by Gil on 13-7-8.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTRecorderView.h"

@interface XTRecorderView ()
@property (nonatomic, assign) CGRect volumeImageViewStartFrame;
@property (nonatomic, assign) double lowPassResults;
@end

@implementation XTRecorderView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor kdPopupColor];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.promptBackgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        self.promptBackgroundImageView.center = CGPointMake(frame.size.width / 2, self.promptBackgroundImageView.frame.size.height / 2 + 5.0);
        //        self.promptBackgroundImageView.backgroundColor = [UIColor kdPopupColor];
        [self addSubview:self.promptBackgroundImageView];
        
        self.promptLabel = [UILabel new];
        self.promptLabel.textColor = FC6;
        self.promptLabel.textAlignment = NSTextAlignmentCenter;
        self.promptLabel.font = FS3;
        self.promptLabel.backgroundColor = [UIColor clearColor];
        [self.promptBackgroundImageView addSubview:self.promptLabel];
        [self addSubview:self.promptLabel];
        
        [self.promptLabel makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.equalTo(self.top).with.offset(12);
             make.centerX.equalTo(self.centerX);
         }];
        
        //        self.microphoneImageView = [[UIImageView alloc] initWithImage:[XTImageUtil chatVoiceMicrophoneImage]];
        //        self.microphoneImageView.center = CGPointMake(frame.size.width / 2, 60.0);
        //        [self addSubview:self.microphoneImageView];
        
        self.volumeImageView = [[UIImageView alloc] initWithImage:[self volumePicByValue:1]];
        [self addSubview:self.volumeImageView];
        
        [self.volumeImageView makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.mas_equalTo(60);
             make.height.mas_equalTo(60);
             make.top.equalTo(self.promptLabel.bottom).with.offset(17);
             make.centerX.equalTo(self.centerX);
         }];
        
        //        self.progressView = [[[XTRecorderProgressView alloc] initWithFrame:CGRectMake(10.0, frame.size.height - 7.0, frame.size.width - 20.0, 5.0)] autorelease];
        //        [self addSubview:self.progressView];
        
        self.trashImageView = [[UIImageView alloc] initWithImage:[XTImageUtil chatVoiceTrashImage]];
        [self addSubview:self.trashImageView];
        
        [self.trashImageView makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.mas_equalTo(60);
             make.height.mas_equalTo(60);
             make.top.equalTo(self.promptLabel.bottom).with.offset(17);
             make.centerX.equalTo(self.centerX);
         }];
        
        self.countdownLabel = [UILabel new];
        self.countdownLabel.textColor = FC6;
        self.countdownLabel.textAlignment = NSTextAlignmentCenter;
        self.countdownLabel.font = [UIFont boldSystemFontOfSize:54];
        self.countdownLabel.backgroundColor = [UIColor clearColor];
        [self.promptBackgroundImageView addSubview:self.countdownLabel];
        [self addSubview:self.countdownLabel];
        
        [self.countdownLabel makeConstraints:^(MASConstraintMaker *make){
//            make.bottom.equalTo(self.bottom).with.offset(-12);
            make.centerX.equalTo(self.volumeImageView.centerX);
            make.centerY.equalTo(self.volumeImageView.centerY);
        }];
        
        self.state = RecorderStateRecording;
    }
    return self;
}

- (void)setState:(RecorderState)state
{
    _state = state;
    [self setNeedsLayout];
}

- (void)setCounting:(BOOL)counting
{
    _counting = counting;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (self.state == RecorderStateRecording) {
        //        self.promptBackgroundImageView.image = nil;
        self.promptLabel.text = ASLocalizedString(@"XTRecorderView_Up");
        self.promptLabel.font = FS3;
        self.promptLabel.textColor = FC6;
        self.microphoneImageView.hidden = NO;
        self.volumeImageView.hidden = self.counting;
        //        self.progressView.hidden = NO;
        self.trashImageView.hidden = YES;
        self.countdownLabel.hidden = NO;
    } else {
        //        self.promptBackgroundImageView.image = [XTImageUtil chatVoiceDeleteBackgroundImage];
        self.promptLabel.text = ASLocalizedString(@"XTRecorderView_Release");
        self.promptLabel.font = FS3;
        self.promptLabel.textColor = FC4;
        self.microphoneImageView.hidden = YES;
        self.volumeImageView.hidden = YES;
        //        self.progressView.hidden = YES;
        self.trashImageView.hidden = NO;
        self.countdownLabel.hidden = YES;
    }
    [super layoutSubviews];
}

//- (void)setProgress:(int)progress
//{
//    if (self.progressView.hidden) {
//        return;
//    }
//    [self.progressView setProgress:progress];
//}

- (void)setVolume:(float)volume
{
    if (self.volumeImageView.hidden) {
        return;
    }
    
    if (volume > 1.0) {
        volume = 1.0;
    }
    
    int x = (volume/(1/6.0)) + 1;
    self.volumeImageView.image = [self volumePicByValue:x];
    
    //    float height = 24 * volume;
    //    self.volumeImageView.frame = CGRectMake(self.volumeImageViewStartFrame.origin.x, self.volumeImageViewStartFrame.origin.y - height, self.volumeImageViewStartFrame.size.width, self.volumeImageViewStartFrame.size.height + height);
}

- (UIImage *)volumePicByValue:(int)value
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"message_tip_volume_%d", value]];
}

@end
