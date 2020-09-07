//
//  KDAgoraCallView.m
//  kdweibo
//
//  Created by lichao_liu on 8/5/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

//  推送弹出的小窗

#import "KDAgoraCallView.h"

@interface KDAgoraCallView()

@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger timeout;
@end

@implementation KDAgoraCallView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        bgView.backgroundColor = FC1;
        bgView.alpha = 0.3;
        bgView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenIgnoreBtnClicked:)];
        [bgView addGestureRecognizer:tapGesture];
        
        [self addSubview:bgView];
        
        CGFloat kwidth = ScreenFullWidth - 20;
        CGFloat kheight = 232;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 64+0.5*(CGRectGetWidth(frame)- kheight), kwidth, kheight)];
        contentView.layer.masksToBounds = YES;
        contentView.layer.cornerRadius = 12;
        contentView.backgroundColor = FC6;
        [self addSubview:contentView];
        
        self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(kwidth- 65), 25, 65, 65)];
        [contentView addSubview:self.userImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.userImageView.frame)+17, kwidth- 20, 45)];
        self.titleLabel.textColor = FC1;
        self.titleLabel.font = FS1;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabel.frame)+3,kwidth - 20, 25)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = FS4;
        self.timeLabel.textColor = FC2;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:self.timeLabel];
        
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, kheight-44, kwidth, 0.5)];
        seperatorView.backgroundColor = [UIColor kdDividingLineColor];
        [contentView addSubview:seperatorView];
        
        UIButton *ignoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ignoreBtn setTitleColor:FC1 forState:UIControlStateNormal];
        [ignoreBtn setTitleColor:FC2 forState:UIControlStateHighlighted];
        ignoreBtn.titleLabel.font = FS2;
        [ignoreBtn setTitle:ASLocalizedString(@"KDAgoraCallView_Tip_1")forState:UIControlStateNormal];
        ignoreBtn.frame = CGRectMake(0, kheight-44, kwidth/2.0, 44);
        [ignoreBtn setImage:[UIImage imageWithColor:FC6] forState:UIControlStateNormal];
        [ignoreBtn setImage:[UIImage imageWithColor:FC2] forState:UIControlStateHighlighted];
        [ignoreBtn addTarget:self action:@selector(whenIgnoreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:ignoreBtn];
        
        UIButton *answerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [answerBtn setTitleColor:FC5 forState:UIControlStateNormal];
        [answerBtn setTitleColor:FC2 forState:UIControlStateHighlighted];
        answerBtn.titleLabel.font = FS2;
        [answerBtn setTitle:ASLocalizedString(@"KDAgoraCallView_Tip_2")forState:UIControlStateNormal];
        answerBtn.frame = CGRectMake(kwidth/2.0, kheight-44, kwidth/2.0, 44);
        [answerBtn addTarget:self action:@selector(whenAnswerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [answerBtn setImage:[UIImage imageWithColor:FC6] forState:UIControlStateNormal];
        [answerBtn setImage:[UIImage imageWithColor:FC2] forState:UIControlStateHighlighted];
        [contentView addSubview:answerBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kwidth*0.5, kheight - 32, 0.5, 20)];
        lineView.backgroundColor = [UIColor kdDividingLineColor];
        [contentView addSubview:lineView];
        self.timeout = 1;
        self.titleLabel.text = [NSString stringWithFormat:@"00:%02ld",(long)self.timeout];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeRoundFunction) userInfo:nil repeats:YES];
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL,systemAudioCallback, NULL);
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    return self;
}

void systemAudioCallback()
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)whenIgnoreBtnClicked:(id)sender
{
    //清空
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"AgoraGroup"];
    
    [self.timer invalidate];
    self.timer = nil;
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    [self removeFromSuperview];
}

- (void)whenAnswerBtnClicked:(id)sender
{
    //清空
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"AgoraGroup"];
    
    if(self.agoraCallViewBlock)
    {
        [self.timer invalidate];
        self.timer = nil;
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
        self.agoraCallViewBlock(agoraCallViewOperationType_answer);
    }
}

- (void)setGroupDataModel:(GroupDataModel *)groupDataModel
{
    _groupDataModel = groupDataModel;
    
    self.timeLabel.text = [NSString stringWithFormat:@"00:%02ld",(long)self.timeout];
    PersonSimpleDataModel *person = [KDCacheHelper personForKey:groupDataModel.mCallCreator];
    if(groupDataModel.participantIds && groupDataModel.participantIds.count>1)
    {
        if(person)
        {
            self.titleLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDAgoraCallView_Tip_3"),person.personName,groupDataModel.groupName];
        }else{
             self.titleLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDAgoraCallView_Tip_4"),groupDataModel.groupName];
        }
    }else {
        if(person)
        {
            self.titleLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDAgoraCallView_Tip_5"),person.personName];
        }else{
           self.titleLabel.text = ASLocalizedString(@"KDAgoraCallView_Tip_6");
        }
    }
    NSURL *imageURL = nil;
    //产品经理说要改成组头像
//    if ([person hasHeaderPicture]) {
        NSString *url = groupDataModel.headerUrl;
        if ([url rangeOfString:@"?"].location != NSNotFound) {
            url = [url stringByAppendingFormat:@"&spec=180"];
        }
        else {
            url = [url stringByAppendingFormat:@"?spec=180"];
        }
        imageURL = [NSURL URLWithString:url];
//    }
    [self.userImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"app_default_icon"]];
}

- (void)timeRoundFunction
{
    self.timeout ++;
    self.timeLabel.text = [NSString stringWithFormat:@"00:%02ld",(long)self.timeout];
    if(self.timeout == 30)
    {
        [self.timer invalidate];
        self.timer = nil;

        [self removeFromSuperview];
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    }
}

- (void)dealloc
{
    if(self.timer)
    {
    [self.timer invalidate];
    self.timer = nil;
    }
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
}
- (void)removeView
{
    //清空
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"AgoraGroup"];
    
    if(self.timer)
     {
         [self.timer invalidate];
         self.timer = nil;
     }
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    [self removeFromSuperview];

}

@end
