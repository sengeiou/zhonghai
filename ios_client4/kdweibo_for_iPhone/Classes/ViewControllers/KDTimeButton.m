//
//  KDAdsManager.h
//  kdweibo
//
//  Created by lichao_liu on 16/1/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDTimeButton.h"
@implementation KDTimeButton
{
    NSTimer *timer;
    NSString *titleStr;
}

- (id)initWithTitle:(NSString *)title andTime:(NSInteger)num {
    self = [super init];
    if (self) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateTitleAction) userInfo:nil repeats:YES];
            titleStr = title;
            self.timerNumber = num;
            //        [self setTitle:[NSString stringWithFormat:@"%@%lds",title,(long)num] forState:UIControlStateNormal];
            [self setTitle:title forState:UIControlStateNormal];
            [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
        });
        
    }
    return self;
}
- (void)updateTitleAction {
    if (self.timerNumber<=1) {
        [timer invalidate];
        timer = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TIMEOUT" object:nil];
        return;
    }
    self.timerNumber--;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setTitle:[NSString stringWithFormat:@"%ld｜%@",(long)self.timerNumber, ASLocalizedString(@"KDTimeButton_Skip")] forState:UIControlStateNormal];
    });
}

- (void)dealloc{
    if(timer){
        [timer invalidate];
        timer = nil;
    }
}
@end
