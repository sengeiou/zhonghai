//
//  KDAgoraVoiceBanner.m
//  kdweibo
//
//  Created by lichao_liu on 10/27/15.
//  Copyright © 2015 www.kingdee.com. All rights reserved.
//

#import "KDAgoraVoiceBanner.h"
@interface KDAgoraVoiceBanner()

@property (nonatomic, strong) UIImageView *recordImageView;
@property (nonatomic, strong) UILabel *recordTitleLabel;
@end

@implementation KDAgoraVoiceBanner

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        //        self.backgroundColor = [UIColor colorWithRGB:0xf5f5f5];
        self.backgroundColor = [UIColor kdBackgroundColor7];
        //33为banner高度
        self.layer.cornerRadius = 36 / 2;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor kdBackgroundColor7].CGColor;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = FC2;
        self.titleLabel.font = FS6;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        self.recordImageView = [[UIImageView alloc] init];
        self.recordImageView.image = [UIImage imageNamed:@"phone_tip_record"];
        [self addSubview:self.recordImageView];
        
        self.recordTitleLabel = [[UILabel alloc] init];
        self.recordTitleLabel.text = ASLocalizedString(@"KDAgoraVoiceBanner_Record");
        self.recordTitleLabel.backgroundColor = [UIColor clearColor];
        self.recordTitleLabel.textColor = FC1;
        self.recordTitleLabel.font = FS4;
        [self addSubview:self.recordTitleLabel];
    }
    return self;
}

- (void)makeMasory
{
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).with.offset(12);
        make.right.equalTo(self.right).with.offset(-12);
        make.height.mas_equalTo(self.height);
        make.centerY.equalTo(self.centerY);
    }];
    
    [self.recordTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.centerY.equalTo(self.centerY);
        make.right.equalTo(self.right).offset(120);
    }];
    
    [self.recordImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(13);
        make.height.mas_equalTo(13);
        make.centerY.equalTo(self.centerY);
        make.right.equalTo(self.recordTitleLabel.left).offset(-5);
    }];
}

-(void)whenStartRecordBtnClicked:(id)sender
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.recordTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.right).offset(-12);
        }];
        [self.recordTitleLabel layoutIfNeeded];
        self.recordImageView.alpha = 0.2;
    } completion:^(BOOL finished) {
        
        [UIView animateKeyframesWithDuration:2.4 delay:0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.6 animations:^{
                self.recordImageView.alpha = 1;
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.6 animations:^{
                self.recordImageView.alpha = 0.2;
            }];
        } completion:^(BOOL finished) {
            
        }];
        
    }];
}


- (void)whenFinishRecordBtnClicked:(id)sender
{
    self.recordImageView.alpha = 1;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.recordTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.right).offset(120);
        }];
        [self.recordTitleLabel layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}
@end
