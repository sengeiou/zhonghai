//
//  KDPersonalAppView.m
//  kdweibo
//
//  Created by AlanWong on 14-9-26.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPersonalAppView.h"
#import "KDReachabilityManager.h"
#define APPVIEWWIDTH            107
#define DEFUALTLOGOURL          @"http://mcloud.kingdee.com//3gol/portal/app/logo/0.png"
#define kImageDefaultIcon       @"app_default_icon.png"
#define kKeyAppClientID         @"appClientId"
#define kInternalAppClientID    @"-1"                       //内置应用的id标识

@interface KDPersonalAppView ()
@property (nonatomic, strong) UIImageView *featureAppImgView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGes;
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;
@property (nonatomic, strong) UITapGestureRecognizer *deleteViewTapGes;
@property (nonatomic, assign) CGPoint lastLocation;
@end

@implementation KDPersonalAppView

- (id)initWithAppDataModel:(KDAppDataModel *)dataModel frame:(CGRect)initFrame delFlag:(BOOL)delFlag
{
    self = [super initWithFrame:initFrame];
    if (self) {
        
        self.appDM = dataModel;
        
        //应用logo
        _appImageView = [[UIImageView alloc] init];
        _appImageView.image = [UIImage imageNamed:@"app_default_icon"];
        _appImageView.frame = CGRectMake(5, 7, initFrame.size.width-5, initFrame.size.width-5);
//        _appImageView.layer.cornerRadius = (AppImageViewCornerRadius==-1?(CGRectGetHeight(_appImageView.frame)/2):AppImageViewCornerRadius);
//        _appImageView.layer.masksToBounds = YES;
//        _appImageView.layer.shouldRasterize = YES;
//        _appImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _appImageView.contentMode = UIViewContentModeScaleToFill;
        _appImageView.backgroundColor = [UIColor clearColor];
        [_appImageView roundMask];//蒙层
        [self addSubview:_appImageView];
        
        
        if ([_appDM.appLogo isEqual:[NSNull null]] || [_appDM.appLogo isEqual:@""] || _appDM.appLogo.length == 0) {
            _appImageView.image = [UIImage imageNamed:kImageDefaultIcon];
        }
        else if([_appDM.appClientID isEqualToString:kInternalAppClientID])
        {
            _appImageView.image = [UIImage imageNamed:_appDM.appLogo];
        }
        else
        {
            [_appImageView setImageWithURL:[NSURL URLWithString:_appDM.appLogo] placeholderImage:[UIImage imageNamed:@"app_default_icon"]];
        }
        
        if ([self sizeBeyondOneLine:_appDM.appName fontSize:11])
        {
            _appNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_appImageView.frame),CGRectGetMaxY(_appImageView.frame)+4, _appImageView.frame.size.width, 15 * 2)];
            _appNameLabel.numberOfLines = 2;
        }
        else
        {
            _appNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_appImageView.frame),CGRectGetMaxY(_appImageView.frame)+8,  _appImageView.frame.size.width, 15)];
            _appNameLabel.numberOfLines = 1;
        }
        
        _appNameLabel.backgroundColor = [UIColor clearColor];
        _appNameLabel.textColor = FC1;
        _appNameLabel.text = _appDM.appName;
        _appNameLabel.font = [UIFont systemFontOfSize:11];
        _appNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_appNameLabel];
        
        
        UIImageView *deleteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_badge_tip_delete"]];
        deleteView.frame = CGRectMake(self.frame.size.width-25, 4, 40, 40);
        //deleteView.center = CGPointMake(3, 2);
        deleteView.contentMode = UIViewContentModeTop;
        deleteView.userInteractionEnabled = YES;
        deleteView.tag = 100010;
        deleteView.hidden = YES;
        [self addSubview:deleteView];

        
        self.featureAppImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_img_new_app"]];
        [self.featureAppImgView sizeToFit];
        [self addSubview:_featureAppImgView];
        self.featureAppImgView.center = CGPointMake(CGRectGetWidth(self.bounds)-8, 3);
        
        self.featureAppImgView.hidden = YES;
        
//        if(delFlag)
//            [self shakeView:self];
        
        //点击删除
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appDeleteAction:)];
        [deleteView addGestureRecognizer:tapGesture1];
        self.deleteViewTapGes = tapGesture1;
        
        //拖动手势，暂时屏蔽
//        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(appViewMove:)];
//        [self addGestureRecognizer:panGesture];
//        self.panGes = panGesture;
        
        //点击打开手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoBtnPressed:)];
        [self addGestureRecognizer:tapGesture];
        self.tapGes = tapGesture;
        
        //长按手势
        UILongPressGestureRecognizer *lpGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(photoBtnLongPressed:)];
        [self addGestureRecognizer:lpGesture];
        self.longPressGes = lpGesture;
        
        self.isEditing = delFlag;
    }
    return self;
}

-(void)shakeView:(UIView*)view
{
    // 获取到当前的View
    CALayer *viewLayer = view.layer;
    
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    // 设置开始位置
    [animation setFromValue:[NSNumber numberWithFloat:0.03]];
    
    // 设置结束位置
    [animation setToValue:[NSNumber numberWithFloat:-0.03]];
    
    // 设置自动反转
    [animation setAutoreverses:YES];
    
    // 设置时间
    [animation setDuration:.08];
    
    // 设置次数
    [animation setRepeatCount:INTMAX_MAX];
    
    // 添加上动画
    [viewLayer addAnimation:animation forKey:nil];
}

- (void)setIsFeatureFuc:(BOOL)isFeatureFuc{
    self.featureAppImgView.hidden = !isFeatureFuc;
}
- (BOOL) sizeBeyondOneLine:(NSString*)str fontSize:(int)fontSize
{
    //计算一下文本的行数，如果超出一行，将标签高度变成2行。
    CGSize textSize = CGSizeMake(_appImageView.frame.size.width ,1000.0);
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    if(size.height > 15.0)
        return YES;
    else
        return NO;
}


-(void)photoBtnPressed:(id)sender
{
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(goToAppWithDataModel:)]) {
            [_delegate goToAppWithDataModel:self.appDM];
        }
    }
}

-(void)appDeleteAction:(id)sender
{
    //[self removeFromSuperview];
    NSString * appClientId = _appDM.appClientID;
    if (_appDM.appType == KDAppTypePublic) {
        appClientId = _appDM.pid;
        
    }
//    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:appClientId, kKeyAppClientID, nil];
//    NSNotification *notification = [NSNotification notificationWithName:@"Personal_App_Delete" object:nil userInfo:dic];
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
    

    if ([[KDReachabilityManager sharedManager]isReachable])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"appViewDelete" object:nil userInfo:[NSDictionary dictionaryWithObject:self.appDM forKey:@"appDM"]];
    }
    else
    {
        //删除失败
        [KDPopup showHUDToast:ASLocalizedString(@"KDApplicationViewController_del_fail")];
    }
}

-(void)photoBtnLongPressed:(UILongPressGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:self.superview];
    if (sender.state == UIGestureRecognizerStateBegan) {
        if(_delegate) {
            [_delegate longPressAppView];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(1.1, 1.1);
            self.alpha = 0.5;
        }];
        
        self.lastLocation = location;
    }
    else if(sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = CGPointMake(location.x - self.lastLocation.x,
                                          location.y - self.lastLocation.y);
        CGPoint center = CGPointMake(self.center.x + translation.x,
                                     self.center.y + translation.y);
        
        self.center = center;
        self.lastLocation = location;
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformIdentity;
            self.alpha = 1;
        }];
        
        self.lastLocation = location;
    }
    
    [self.superview bringSubviewToFront:self];
    
    if(_delegate && [_delegate respondsToSelector:@selector(appViewMoving:andState:)])
        [_delegate appViewMoving:self andState:sender.state];
}

-(void)appViewMove:(UIPanGestureRecognizer*)sender
{
    if(!self.isEditing)
        return;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
       
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(1.1, 1.1);
            self.alpha = 0.5;
        }];
        
    }
    else if(sender.state == UIGestureRecognizerStateChanged)
    {
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformIdentity;
            self.alpha = 1;
        }];
    }


    CGPoint offsetPoint = [sender translationInView:self.superview];
    [sender setTranslation:CGPointZero inView:self.superview];
    self.center = CGPointMake(self.center.x + offsetPoint.x, self.center.y + offsetPoint.y);
    
    [self.superview bringSubviewToFront:self];
    
    if(_delegate && [_delegate respondsToSelector:@selector(appViewMoving:andState:)])
        [_delegate appViewMoving:self andState:sender.state];
}

-(void)setIsEditing:(BOOL)isEditing
{
    {
        _isEditing = isEditing;
        UIImageView *deleteView = [self viewWithTag:100010];
        if(deleteView)
            deleteView.hidden = !_isEditing;
        
        //是否删除状态
        if (_isEditing) {
            self.tapGes.enabled = NO;
            self.deleteViewTapGes.enabled = YES;
            self.panGes.enabled = YES;
        } else {
            
            self.tapGes.enabled = YES;
            self.deleteViewTapGes.enabled = NO;
            self.panGes.enabled = NO;
            [UIView animateWithDuration:0.2 animations:^{
                self.transform = CGAffineTransformIdentity;
                self.alpha = 1;
            }];
        }

    }
}
@end
