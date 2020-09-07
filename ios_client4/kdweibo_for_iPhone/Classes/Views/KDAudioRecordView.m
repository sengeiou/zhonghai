//
//  KDAudioRecordView.m
//  kdweibo
//
//  Created by shen kuikui on 13-5-10.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAudioRecordView.h"
#import <QuartzCore/QuartzCore.h>

#define KD_AUDIO_DURATION_LABEL_FONT_SIZE 15.0f
#define KD_AUDIO_MESSAGE_LABEL_FONT_SIZE  16.0f

#define KD_AUDIO_TOP_MARGIN       20.0f
#define KD_AUDIO_LEFT_MARGIN      20.0f
#define KD_AUDIO_BOTTOM_MARGIN    15.0f

@implementation KDAudioRecordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    //[super dealloc];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef myCtx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(myCtx);
    
    CGSize viewSize = self.bounds.size;
    
    //current duration text
    CGContextSetFillColorWithColor(myCtx, [UIColor whiteColor].CGColor);
    NSString *str = [NSString stringWithFormat:@"%@%d″", duration_ > 9 ? @"" : @"0", (int)duration_];
    [str drawAtPoint:CGPointMake(KD_AUDIO_LEFT_MARGIN, KD_AUDIO_TOP_MARGIN) withFont:[UIFont systemFontOfSize:KD_AUDIO_DURATION_LABEL_FONT_SIZE]];
    //indicator bg image
    UIImage *indicatorBgImage = [UIImage imageNamed:@"audio_record_indicator_bg_v3"];
    indicatorBgImage = [indicatorBgImage stretchableImageWithLeftCapWidth:indicatorBgImage.size.width * 0.5f topCapHeight:indicatorBgImage.size.height * 0.5f];
    [indicatorBgImage drawInRect:CGRectMake(KD_AUDIO_LEFT_MARGIN, 42.0f, 142.0f, 6.0f)];
    //indicator fg image
    UIImage *indicatorFgImage = [UIImage imageNamed:@"audio_record_indicator_fg_v3"];
    indicatorFgImage = [indicatorFgImage stretchableImageWithLeftCapWidth:indicatorFgImage.size.width * 0.5f topCapHeight:indicatorFgImage.size.height * 0.5f];
    [indicatorFgImage drawInRect:CGRectMake(KD_AUDIO_LEFT_MARGIN, 42.0f, duration_ * 142.0f / 60.0f, 6.0f)];
    //max duration image
    UIImage *maxImage = [UIImage imageNamed:@"audio_record_60s_v3"];
    [maxImage drawAtPoint:CGPointMake(KD_AUDIO_LEFT_MARGIN + 150.0f, KD_AUDIO_TOP_MARGIN + 3.f)];
    //main image (recording/cancel/warning)
    NSString *mainImageName = nil;
    if(viewFlags_.warningViewShow == 1) {
        mainImageName = @"audio_record_warning_icon_v3";
    }else if(viewFlags_.cancelViewShow == 1) {
        mainImageName = @"dm_record_cancel_v3";
    }else {
        mainImageName = @"audio_record_microphone_v3";
    }
    
    UIImage *mainImage = [UIImage imageNamed:mainImageName];
    [mainImage drawAtPoint:CGPointMake((viewSize.width - mainImage.size.width) * 0.5f, 72.0f)];
    
    if(viewFlags_.recordViewShow == 1) {
        UIImage *volumnImage = [UIImage imageNamed:@"audio_record_volume_v3"];
        
        CGFloat volumnHeight = ((currentVolume_ + 160.0f) / 160.0f) * volumnImage.size.height;
        
        CGContextSaveGState(myCtx);
        CGContextClipToRect(myCtx, CGRectMake(0.0f, 72.0f + mainImage.size.height - volumnHeight, viewSize.width, volumnHeight));
        
        [volumnImage drawInRect:CGRectMake((viewSize.width - volumnImage.size.width) * 0.5f, 72.0f + mainImage.size.height - volumnImage.size.height, volumnImage.size.width, volumnImage.size.height)];
        
        CGContextRestoreGState(myCtx);
    }
    
    //prompt message
    NSString *msg = nil;
    if(viewFlags_.cancelViewShow == 1) {
        msg = NSLocalizedString(@"AUDIO_CANCEL_MESSAGE", @"");
    }else if(viewFlags_.warningViewShow == 1) {
        msg = NSLocalizedString(@"AUDIO_RECORD_WARNING", @"");
    }else {
        msg = NSLocalizedString(@"AUDIO_RECORD_MESSAGE", nil);
    }
    
    UIColor *msgColor = viewFlags_.cancelViewShow == 1 ? [UIColor redColor] : RGBCOLOR(174.f, 174.f, 174.f);
    CGContextSetFillColorWithColor(myCtx, msgColor.CGColor);
    
    UIFont *msgFont = [UIFont systemFontOfSize:KD_AUDIO_MESSAGE_LABEL_FONT_SIZE];
    CGSize msgSize = [msg sizeWithFont:msgFont];
    [msg drawInRect:CGRectMake((viewSize.width - msgSize.width) * 0.5f, viewSize.height - msgSize.height - KD_AUDIO_BOTTOM_MARGIN, msgSize.width, msgSize.height) withFont:msgFont];
    
    CGContextRestoreGState(myCtx);
}

#pragma mark - public methods
+ (KDAudioRecordView *)audioRecordView {
    KDAudioRecordView *recordView = [[KDAudioRecordView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 220, 231)];
    
    recordView.backgroundColor = [UIColor blackColor];
    recordView.layer.cornerRadius = 5.0f;
    recordView.layer.masksToBounds = YES;
    recordView.alpha = 0.75f;
    
    return recordView;// autorelease];
}

// -160为完全安静，0为最大分贝
- (void)setVolume:(CGFloat)volume andInterval:(CGFloat)interval{
    if(currentVolume_ != volume) {
        currentVolume_ = volume;
        
        [self setNeedsDisplay];
    }
}

- (void)showOrHiddeCancelMessage:(BOOL)isShow {
    viewFlags_.warningViewShow = 0;
    viewFlags_.cancelViewShow = isShow ? 1 : 0;
    viewFlags_.recordViewShow = isShow ? 0 : 1;
    
    [self setNeedsDisplay];
}

- (void)setDuration:(CGFloat)duration {
    duration_ = duration;
    
    [self setNeedsDisplay];
}

- (void)startRecord {
    duration_ = 0.0f;
    currentVolume_ = -150.0f;
    
    viewFlags_.cancelViewShow = 0;
    viewFlags_.recordViewShow = 1;
    viewFlags_.warningViewShow = 0;
    
    [self setNeedsDisplay];
}

- (void)endRecord {
    if(duration_ < 2.0f) {
        viewFlags_.warningViewShow = 1;
        viewFlags_.cancelViewShow = 0;
        viewFlags_.recordViewShow = 0;
        
        [self setNeedsDisplay];
    }
}

@end
