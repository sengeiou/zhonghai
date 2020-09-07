//
//  KDPhoneBindingDisplayViewController.m
//  kdweibo
//
//  Created by DarrenZheng on 14-6-26.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDPhoneBindingDisplayViewController.h"
#import "DTColor+HTML.h"
#import "ProfileViewCell.h"
#import "BOSConfig.h"
#import "KDPhoneInputViewController.h"

@interface KDPhoneBindingDisplayViewController ()
<UITableViewDataSource>

@property (nonatomic, strong) UIImageView *imageViewPhoneIcon;
@property (nonatomic, strong) UILabel *labelTip;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UIButton *buttonConfirm;
@property (nonatomic, strong) UITableView *tableViewMain;
@property (nonatomic, assign) float y;
@end

@implementation KDPhoneBindingDisplayViewController


#pragma mark - View Controller Lifecircle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = ASLocalizedString(@"KDCreateTeamViewController_bind_mobile");
    [self.view setBackgroundColor:[UIColor colorWithRGB:0xFFFFFF]];
    [self.view addSubview:self.imageViewPhoneIcon];
    [self.view addSubview:self.phoneLabel];
    [self.view addSubview:self.labelTip];
    [self.view addSubview:self.buttonConfirm];
//    [self.view addSubview:self.tableViewMain];
}

#pragma mark - Actions

- (void)buttonConfirmPressed:(UIButton *)sender
{
    KDPhoneInputViewController *ctr = [[KDPhoneInputViewController alloc] init];
    ctr.delegate = self.delegate;
    ctr.type = KDPhoneInputTypeUpdatePhoneAccount;
    [self.navigationController pushViewController:ctr animated:YES];
//    [ctr release];
}


#pragma mark - Propery Setup

- (UIImageView *)imageViewPhoneIcon
{
    if (!_imageViewPhoneIcon) {
        _imageViewPhoneIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"reg_img_bangding"]];// autorelease];
        _imageViewPhoneIcon.frame = CGRectMake((ScreenFullWidth - _imageViewPhoneIcon.frame.size.width)/2, 93, _imageViewPhoneIcon.frame.size.width, _imageViewPhoneIcon.frame.size.height);
        self.y = CGRectGetMaxY(_imageViewPhoneIcon.frame);
    }
    return _imageViewPhoneIcon;
}

-(UILabel *)phoneLabel
{
    if(!_phoneLabel){
        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenFullWidth - 300)/2, self.y + 20, 300, 40)];
        _phoneLabel.backgroundColor = [UIColor clearColor];
        _phoneLabel.numberOfLines = 1;
        _phoneLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDPhoneBindingDisplayViewController_mobile"),[BOSConfig sharedConfig].user.phone];
        self.y = CGRectGetMaxY(_phoneLabel.frame);
        _phoneLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _phoneLabel;
}

- (UILabel *)labelTip
{
    if (!_labelTip) {
        _labelTip = [[UILabel alloc]initWithFrame:CGRectMake(20, self.y+ 15, ScreenFullWidth - 40, 60)];// autorelease];
        _labelTip.numberOfLines = 2;
        _labelTip.font = FS6;
        _labelTip.backgroundColor = [UIColor clearColor];
        _labelTip.textColor = FC2;
        _labelTip.textAlignment = NSTextAlignmentCenter;
        _labelTip.text = ASLocalizedString(@"KDPhoneBindingDisplayViewController_tips_1");
        self.y = CGRectGetMaxY(_labelTip.frame);
    }
    return _labelTip;
}

- (UIButton *)buttonConfirm
{
    if (!_buttonConfirm) {
//        UIImage *btn_green_normal = [self stretchImageWithImageName:@"user_btn_green_normal.png"];
//        UIImage *btn_green_pressed = [self stretchImageWithImageName:@"user_btn_green_press.png"];
        _buttonConfirm = [UIButton blueBtnWithTitle:ASLocalizedString(@"KDPhoneBindingDisplayViewController_change_mobile")];
        _buttonConfirm.frame = CGRectMake(20, self.y + 20, (ScreenFullWidth - 40), 42);
        [_buttonConfirm addTarget:self action:@selector(buttonConfirmPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonConfirm setTitle:ASLocalizedString(@"KDPhoneBindingDisplayViewController_change_mobile")forState:UIControlStateNormal];
        [_buttonConfirm setCircle];
//        [_buttonConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        _buttonConfirm.backgroundColor = UIColorFromRGB(0x20c000);
//        _buttonConfirm.layer.cornerRadius = 5;

//        [_buttonConfirm setBackgroundImage:btn_green_normal forState:UIControlStateNormal];
//        [_buttonConfirm setBackgroundImage:btn_green_pressed forState:UIControlStateHighlighted];
//        [_buttonConfirm.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    }
    return _buttonConfirm;
}

- (UITableView *)tableViewMain
{
    if (!_tableViewMain) {
        _tableViewMain = [[UITableView alloc] initWithFrame:CGRectMake(0, 190, 280, 55)];// autorelease];
        _tableViewMain.dataSource = self;
        _tableViewMain.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableViewMain.clipsToBounds = NO;
        _tableViewMain.backgroundColor = MESSAGE_BG_COLOR;
        _tableViewMain.userInteractionEnabled = NO;
    }
    return _tableViewMain;
}


#pragma mark - Abstract Methods

- (UIImage *)stretchImageWithImageName:(NSString *)imageName
{
    UIImage *img = [UIImage imageNamed:imageName];
    return [img stretchableImageWithLeftCapWidth:img.size.width * 0.5f topCapHeight:img.size.height * 0.5f];
}


#pragma mark - Table View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileViewCell *cell = (ProfileViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileViewCell"];
    if (!cell) {
        cell = [[ProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProfileViewCell"];// autorelease];
        cell.hideNarrow = YES;
        cell.cellPlace = ProfileViewCellPlace_Top;
        cell.mainLabel.text = [NSString stringWithFormat:ASLocalizedString(@"KDPhoneBindingDisplayViewController_your_mobile"), [BOSConfig sharedConfig].user.phone];
    }
    return cell;
}


@end
