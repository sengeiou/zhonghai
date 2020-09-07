//
//  KDSignInPointWorkTimeCell.m
//  kdweibo
//
//  Created by lichao_liu on 1/19/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInPointWorkTimeCell.h"
#import "KDSignInPoint.h"

@interface KDSignInPointWorkTimeCell()

@property (nonatomic, strong) UILabel *amLabel;
@property (nonatomic, strong) UILabel *pmLabel;
@property (nonatomic, strong) UILabel *lineLabel1;
@property (nonatomic, strong) UILabel *lineLabel2;
@property (nonatomic, strong) UIView *seperatorLineView1;
@property (nonatomic, strong) UIView *seperatorLineView2;
@property (nonatomic, strong) UIView *grayView;

@property (nonatomic, assign) KDSignInPointWorkTimeType workTimeType;

@end

@implementation KDSignInPointWorkTimeCell

- (void)initDataWithFromBeginTime:(NSString *)fromBeginTime
                      toBeginTime:(NSString *)toBeginTime
                      fromEndTime:(NSString *)fromEndTime
                        toendTime:(NSString *)toEndTime
{
    [self.fromBeginTimeBtn setTitle:fromBeginTime forState:UIControlStateNormal];
    [self.toBeginTimeBtn setTitle:toBeginTime forState:UIControlStateNormal];
    [self.fromEndTimeBtn setTitle:fromEndTime forState:UIControlStateNormal];
    [self.toEndTimeBtn setTitle:toEndTime forState:UIControlStateNormal];
    
    NSString *distanceStr = [self getDistanceOfSignInPoint];
    self.countTimeLabel.text = distanceStr;
}

- (NSString *)getDistanceOfSignInPoint
{
    NSString *fromBeginTimeStr = [self.fromBeginTimeBtn titleForState:UIControlStateNormal];
    NSString *toBeginTimeStr = [self.toBeginTimeBtn titleForState:UIControlStateNormal];
    NSString *fromEndTimeStr = [self.fromEndTimeBtn titleForState:UIControlStateNormal];
    NSString *toEndTimeStr = [self.toEndTimeBtn titleForState:UIControlStateNormal];
    
    CGFloat amDisatance = [self distanceBetwenTwoTime:fromBeginTimeStr endTimeStr:toBeginTimeStr];
    CGFloat pmDistance = [self distanceBetwenTwoTime:fromEndTimeStr endTimeStr:toEndTimeStr];
    CGFloat middayRestDidtance = [self distanceBetwenTwoTime:toBeginTimeStr endTimeStr:fromEndTimeStr];
    return [NSString stringWithFormat:ASLocalizedString(@"标准工时%.2f小时  午休时长%.2f小时"), amDisatance+pmDistance, middayRestDidtance];
}

- (CGFloat)getAccurateTimeDistanceBetwwenAmDistance:(CGFloat)amDistance pmDistance:(CGFloat)pmDistance
{
    return 0;
}

- (CGFloat)distanceBetwenTwoTime:(NSString *)beginTimeStr endTimeStr:(NSString *)endTimeStr
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSDate *date1=[dateFormatter dateFromString:beginTimeStr];
    NSDate *date2=[dateFormatter dateFromString:endTimeStr];
    
    NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
    typedef double NSTimeInterval;
    
    CGFloat hours = time/3600;
    return hours;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = FC6;
        self.amLabel = [self getLabel];
        self.amLabel.textAlignment = NSTextAlignmentLeft;
        self.amLabel.text = ASLocalizedString(@"上午工作时间");
        [self.contentView addSubview:self.amLabel];
        
        self.pmLabel = [self getLabel];
        self.pmLabel.text = ASLocalizedString(@"下午工作时间");
        self.pmLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.pmLabel];
        
        self.fromBeginTimeBtn = [self getButton];
        self.fromBeginTimeBtn.tag = 1000 + KDSignInPointWorkTimeType_fromBeginTime;
        [self.fromBeginTimeBtn addTarget:self action:@selector(whenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.fromBeginTimeBtn];
        
        self.toBeginTimeBtn = [self getButton];
        self.toBeginTimeBtn.tag = 1000 + KDSignInPointWorkTimeType_toBeginTime;
        [self.toBeginTimeBtn addTarget:self action:@selector(whenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.toBeginTimeBtn];
        
        self.fromEndTimeBtn = [self getButton];
        self.fromEndTimeBtn.tag = 1000 + KDSignInPointWorkTimeType_fromEndTime;
        [self.fromEndTimeBtn addTarget:self action:@selector(whenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.fromEndTimeBtn];
        
        self.toEndTimeBtn = [self getButton];
        self.toEndTimeBtn.tag = 1000 + KDSignInPointWorkTimeType_toEndTime;
        [self.toEndTimeBtn addTarget:self action:@selector(whenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.toEndTimeBtn];
        
        self.lineLabel1 = [self getLabel];
        self.lineLabel2 = [self getLabel];
        self.lineLabel1.text = @"-";
        self.lineLabel2.text = @"-";
        [self.contentView addSubview:self.lineLabel1];
        [self.contentView addSubview:self.lineLabel2];
        
        
        self.seperatorLineView1= [[UIView alloc] initWithFrame:CGRectZero];
        self.seperatorLineView1.backgroundColor = [UIColor kdDividingLineColor];
        [self.contentView addSubview:self.seperatorLineView1];
        
        self.seperatorLineView2= [[UIView alloc] initWithFrame:CGRectZero];
        self.seperatorLineView2.backgroundColor = [UIColor kdDividingLineColor];
        [self.contentView addSubview:self.seperatorLineView2];
        
        self.grayView = [[UIView alloc] initWithFrame:CGRectZero];
        self.grayView.backgroundColor = [UIColor kdBackgroundColor1];
        [self.contentView addSubview:self.grayView];
        
        self.countTimeLabel = [self getLabel];
        self.countTimeLabel.font = FS4;
        self.countTimeLabel.textColor = FC2;
        self.countTimeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.countTimeLabel];
    }
    return self;
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat selfWidth = self.frame.size.width;
    CGFloat buttonWidth = 50;
    self.amLabel.frame = CGRectMake([NSNumber kdDistance1], 10, 100, 30);
    self.pmLabel.frame = CGRectMake([NSNumber kdDistance1], 60, 100, 30);
    
    self.fromBeginTimeBtn.frame = CGRectMake(selfWidth- [NSNumber kdDistance1] - 2 *buttonWidth - 15, 10, 50, 30);
    self.toBeginTimeBtn.frame = CGRectMake(selfWidth - [NSNumber kdDistance1]- buttonWidth, 10, 50, self.fromBeginTimeBtn.frame.size.height);
    
    self.fromEndTimeBtn.frame = CGRectMake(self.fromBeginTimeBtn.frame.origin.x, 60, 50, self.fromBeginTimeBtn.frame.size.height);
    self.toEndTimeBtn.frame = CGRectMake(self.toBeginTimeBtn.frame.origin.x, 60, 50, self.fromBeginTimeBtn.frame.size.height);
    
    self.lineLabel1.frame = CGRectMake(self.toBeginTimeBtn.frame.origin.x - 15, 10, 15, self.fromBeginTimeBtn.frame.size.height);
    self.lineLabel2.frame = CGRectMake(self.toEndTimeBtn.frame.origin.x - 15, 60, 15, self.fromBeginTimeBtn.frame.size.height);
    
    self.seperatorLineView1.frame = CGRectMake([NSNumber kdDistance1], 50, self.frame.size.width- [NSNumber kdDistance1], 0.5);
    self.seperatorLineView2.frame = CGRectMake([NSNumber kdDistance1], 100, self.frame.size.width - [NSNumber kdDistance1], 0.5);
    
    self.grayView.frame = CGRectMake(0, 100, self.frame.size.width, 40);
    
    self.countTimeLabel.frame = CGRectMake(12, 105, self.frame.size.width - 24, 30);
}


- (UILabel *)getLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = FC1;
    label.font = FS3;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UIButton *)getButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:FC5 forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = FS4;
    [button setTitleColor:FC2 forState:UIControlStateHighlighted];
    return button;
}

- (void)whenButtonClicked:(UIButton *)sender
{
    if(self.block)
    {
        self.block(sender.tag - 1000);
    }
}
@end
