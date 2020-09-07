//
//  KDAudioRecordView.h
//  kdweibo
//
//  Created by shen kuikui on 13-5-10.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDAudioRecordView : UIView
{
    CGFloat     currentVolume_;
    CGFloat     duration_;

    struct {
        unsigned int recordViewShow : 1;
        unsigned int cancelViewShow : 1;
        unsigned int warningViewShow : 1;
    } viewFlags_;
}

+ (KDAudioRecordView *)audioRecordView;

- (void)setDuration:(CGFloat)duration;

- (void)setVolume:(CGFloat)volume andInterval:(CGFloat)interval;

- (void)showOrHiddeCancelMessage:(BOOL)isShow;

- (void)startRecord;
- (void)endRecord;

@end
