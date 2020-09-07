//
//  KDSignInShareSheetView.m
//  kdweibo
//
//  Created by lichao_liu on 9/2/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInShareSheetView.h"
@interface KDSignInShareSheetView()
@property (nonatomic,strong) UIView *contentShareView;
@property (nonatomic, assign)CGFloat sheetHeight;
@end

@implementation KDSignInShareSheetView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.sheetHeight = 220;
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        contentView.backgroundColor = [UIColor kdPopupBackgroundColor];
        
        [self addSubview:contentView];
        
        contentView.userInteractionEnabled = YES;
        
        self.contentShareView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height+self.sheetHeight, frame.size.width, self.sheetHeight)];
        self.contentShareView.backgroundColor = [UIColor kdBackgroundColor2];
        [self addSubview:self.contentShareView];
        
 
        UILabel * _labelSheetTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, 200, 20)];
        _labelSheetTitle.backgroundColor = [UIColor clearColor];
        _labelSheetTitle.text = ASLocalizedString(@"分享我的位置");
        _labelSheetTitle.font = FS4;
        _labelSheetTitle.textColor = FC1;
        [self.contentShareView addSubview:_labelSheetTitle];
        
        UIView * _viewLineTop = [UIView new];
        _viewLineTop.backgroundColor = [UIColor kdDividingLineColor];
        _viewLineTop.frame = CGRectMake(20, 50, ScreenFullWidth-20*2, 1);
        [self.contentShareView addSubview:_viewLineTop];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenSelfViewTapped:)];
        [self addGestureRecognizer:tap];
        
        
        [self createBtnWithTitle:ASLocalizedString(@"同事") imageName:@"me_icon_msg" tag:KDSignInShareViewType_friend frame:CGRectZero index:0];
        
        [self createBtnWithTitle:ASLocalizedString(@"动态") imageName:@"me_icon_buluo" tag:KDSignInShareViewType_buluo frame:CGRectZero index:1];
        
        [self createBtnWithTitle:ASLocalizedString(@"朋友圈") imageName:@"me_icon_friend" tag:KDSignInShareViewType_chat frame:CGRectZero index:2];
        
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.sheetHeight-44-8, frame.size.width, 8)];
        lineView.backgroundColor = [UIColor kdBackgroundColor1];
        [self.contentShareView addSubview:lineView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitleColor:FC1 forState:UIControlStateNormal];
        [cancelBtn setTitle:ASLocalizedString(@"取消") forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = FS2;
        [cancelBtn setTitleColor:FC1 forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(0,self.sheetHeight-44, frame.size.width, 44);
       	[cancelBtn setTitleColor:FC1 forState:UIControlStateNormal];
        [cancelBtn setTitleColor:FC5 forState:UIControlStateHighlighted];
        [cancelBtn setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[UIImage kd_imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
        [cancelBtn addTarget:self action:@selector(whenSelfViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentShareView addSubview:cancelBtn];
        
         [self showShareView];
    }
    return self;
}

- (void)createBtnWithTitle:(NSString *)title imageName:(NSString *)imageName tag:(NSInteger)tag frame:(CGRect)frame index:(NSInteger)i
{
        float fXMargin = (ScreenFullWidth - 55*4)/5.0;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *strImageName = imageName;
        [button addTarget:self action:@selector(whenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 5;
        button.tag = i == 0 ? KDSignInShareViewType_friend : (i == 1 ? KDSignInShareViewType_buluo : KDSignInShareViewType_chat);
        button.layer.masksToBounds = YES;
        button.frame = CGRectMake((i % 4) * 55 + (i % 4 + 1) * fXMargin, 70 + (i / 4) * 95, 55, 55);
        [button setImage:[UIImage imageNamed:strImageName] forState:UIControlStateNormal];
        [self.contentShareView addSubview:button];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((i % 4) * 55 + (i % 4 + 1) * fXMargin, 132 + (i / 4) * 95, 55, 16)];
        label.backgroundColor = [UIColor clearColor];
        label.font = FS6;
        label.textColor = FC1;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = title;
        [self.contentShareView addSubview:label];
}

- (void)whenBtnClicked:(UIButton *)sender
{
    if(self.shareBlock)
    {
        self.shareBlock(sender.tag,self.record);
    }
    [self hideShareView];
}

- (void)whenSelfViewTapped:(id)sender
{
    [self hideShareView];
}

- (void)showShareView
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentShareView.frame = CGRectMake(0, self.frame.size.height - self.sheetHeight, self.frame.size.width, self.sheetHeight);
    } completion:^(BOOL finished) {
       
    }];
}

- (void)hideShareView
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentShareView.frame = CGRectMake(0, self.frame.size.height + self.sheetHeight, self.frame.size.width, self.sheetHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
