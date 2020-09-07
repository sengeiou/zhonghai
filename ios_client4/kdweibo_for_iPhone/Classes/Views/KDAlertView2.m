//
//  KDAlertView.m
//  kdweibo
//
//  Created by 王 松 on 13-12-18.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDAlertView2.h"

#import <QuartzCore/QuartzCore.h>

#import "KDAnimationFactory.h"

@interface KDAlertView2 () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UIView *bgView;

@property (nonatomic, retain) UIView *mainView;

@property (nonatomic, retain) UIWindow *alertWindow;

@property (nonatomic, retain) UIWindow *oldKeyWindow;

@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UILabel *msgLabel;

@property (nonatomic, retain) NSArray *buttons;

@property (nonatomic, retain) UIButton *cancelButton;

@property (nonatomic, retain) UITableView *buttonTableView;

@property (nonatomic, retain) UILabel *lineLabel;

@end

@implementation KDAlertView2

- (id)init
{
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate buttons:(NSArray *)buttons
{
   
    if(self = [super init])
    {
        _titleLabel.text = title;
        _msgLabel.text = message;
        _delegate = delegate;
        _buttons = buttons;// retain];
        if (_buttons.count <= 2) {
            _buttonTableView.scrollEnabled = NO;
        }
    }

    return self;
}

- (void)setupViews
{
    _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    _bgView.backgroundColor = [UIColor blackColor];
    [self addSubview:_bgView];
    
    _mainView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainView.layer.masksToBounds = YES;
    _mainView.layer.cornerRadius = 5.0f;
    _mainView.backgroundColor = MESSAGE_BG_COLOR;
    [self addSubview:_mainView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:19.0f];
    _titleLabel.minimumScaleFactor = 14.0f;
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_mainView addSubview:_titleLabel];
    
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _msgLabel.backgroundColor = [UIColor clearColor];
    _msgLabel.font = [UIFont systemFontOfSize:16.f];
    _msgLabel.textColor = MESSAGE_TOPIC_COLOR;
    _msgLabel.adjustsFontSizeToFitWidth = YES;
    _msgLabel.textAlignment = NSTextAlignmentCenter;
    _msgLabel.minimumScaleFactor = 12.f;
    _msgLabel.numberOfLines = 0;
    [_mainView addSubview:_msgLabel];
    
    _buttonTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    _buttonTableView.backgroundColor = [UIColor clearColor];
    _buttonTableView.delegate = self;
    _buttonTableView.dataSource = self;
    _buttonTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainView addSubview:_buttonTableView];
    
    _lineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _lineLabel.backgroundColor = RGBCOLOR(203.f, 203.f, 203.f);
    [_mainView addSubview:_lineLabel];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];// retain];
    _cancelButton.layer.borderColor = RGBCOLOR(203, 203, 203).CGColor;
    _cancelButton.layer.borderWidth = 1.0f;
    _cancelButton.layer.cornerRadius = 5.0f;
    _cancelButton.layer.masksToBounds = YES;
    [_cancelButton setTitle:ASLocalizedString(@"Global_Cancel")forState:UIControlStateNormal];
    [_cancelButton setTitleColor:RGBCOLOR(109, 109, 109) forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [_mainView addSubview:_cancelButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _bgView.frame = self.bounds;
    
    CGFloat inset = 25.f;
    
    _mainView.frame = CGRectMake(inset, (CGRectGetHeight(self.frame) - (CGRectGetWidth(self.frame) - inset * 2.f)) / 2.f - 20.f, CGRectGetWidth(self.frame) - inset * 2.f, 280.f);
    
    if (_titleLabel.text.length > 0) {
        _titleLabel.frame = CGRectMake(10.f, 20.f, CGRectGetWidth(_mainView.frame) - 20.f, 40.f);
        
        _msgLabel.frame = CGRectMake(15.f, CGRectGetMaxY(_titleLabel.frame) + 20.f, CGRectGetWidth(_mainView.frame) - 30.f, 40.f);
    }else {
        _titleLabel.frame = CGRectZero;
        
        _msgLabel.frame = CGRectMake(15.f, CGRectGetMaxY(_titleLabel.frame) + 20.f, CGRectGetWidth(_mainView.frame) - 30.f, 40.f);
    }
    
    _buttonTableView.frame = CGRectMake(15.f, CGRectGetMaxY(_msgLabel.frame) + 20.f, CGRectGetWidth(_mainView.frame) - 30.f, 110.f);
    
    self.lineLabel.frame = CGRectMake(0.f, CGRectGetHeight(_mainView.frame) - 80.f, CGRectGetWidth(_mainView.frame), 1.f);
    
    _cancelButton.frame = CGRectMake(10.f, CGRectGetHeight(_mainView.frame) - 60.f, CGRectGetWidth(_mainView.frame) - 20.f, 40.f);
}

- (void)showInwindow:(UIWindow *)window
{
    self.oldKeyWindow = window;

    UIWindow *keyWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    keyWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    keyWindow.opaque = NO;
    keyWindow.windowLevel = UIWindowLevelAlert;
    
    CGRect rect = keyWindow.bounds;

    self.frame = rect;
    [keyWindow addSubview:self];
    [keyWindow makeKeyAndVisible];
    self.alertWindow = keyWindow;
//    [keyWindow release];
    
    [self.bgView.layer addAnimation:[KDAnimationFactory windowFadeInAnimationWithDuration:0.25] forKey:@"fadeIn"];
    [self.mainView.layer addAnimation:[KDAnimationFactory alertShowAnimationWithDuration:0.27] forKey:@"show"];
}

- (void)cancelAction:(id)sender
{
    CAAnimation *animation = [KDAnimationFactory alertDismissAnimationWithDuration:0.25];
    animation.delegate = self;
    [self.mainView.layer addAnimation:animation forKey:@"dismiss"];
    [self.bgView.layer addAnimation:[KDAnimationFactory windowFadeOutAnimationWithDuration:0.25] forKey:@"fadeOut"];
    if ([self.delegate respondsToSelector:@selector(alertViewCancel)]) {
        [self.delegate alertViewCancel:self];
    }
}

#pragma mark - CAAnimation Delegate Method
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.mainView.layer removeAnimationForKey:@"dismiss"];
    [self.bgView.layer removeAnimationForKey:@"fadeOut"];
    
    [self.oldKeyWindow makeKeyAndVisible];
    [self.alertWindow removeFromSuperview];
    self.alertWindow = nil;
}

#pragma mark
#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.buttons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KDAlertCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];// autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:indexPath.row + 100];
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    button.tag = indexPath.row + 100;
    button.frame = CGRectMake(0.f, (CGRectGetHeight(cell.frame) - 40.f) * 0.5, CGRectGetWidth(_buttonTableView.frame), 40.0f);
    [button setTitle:[self.buttons objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    UIImage *btnBKImage = [UIImage imageNamed:@"signon_btn_bg_v2.png"];
    [button setBackgroundImage:btnBKImage forState:UIControlStateNormal];
    button.layer.cornerRadius = 5.0f;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [cell.contentView addSubview:button];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetHeight(self.buttonTableView.frame) * 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

- (void)buttonClicked:(UIButton *)sender
{
    CAAnimation *animation = [KDAnimationFactory alertDismissAnimationWithDuration:0.25];
    animation.delegate = self;
    [self.mainView.layer addAnimation:animation forKey:@"dismiss"];
    [self.bgView.layer addAnimation:[KDAnimationFactory windowFadeOutAnimationWithDuration:0.25] forKey:@"fadeOut"];
    
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:sender.tag - 100];
    }
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_alertWindow);
    //KD_RELEASE_SAFELY(_bgView);
    //KD_RELEASE_SAFELY(_mainView);
    //KD_RELEASE_SAFELY(_titleLabel);
    //KD_RELEASE_SAFELY(_msgLabel);
    //KD_RELEASE_SAFELY(_buttons);
    //KD_RELEASE_SAFELY(_cancelButton);
    //KD_RELEASE_SAFELY(_buttonTableView);
    //KD_RELEASE_SAFELY(_lineLabel);
    //[super dealloc];
}

@end
