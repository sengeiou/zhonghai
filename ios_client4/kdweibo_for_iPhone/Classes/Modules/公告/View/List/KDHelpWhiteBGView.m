//
//  KDHelpWhiteBGView.m
//  kdweibo
//
//  Created by tangzeng on 16/12/27.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "KDHelpWhiteBGView.h"

@implementation KDHelpWhiteBGViewModel
+ (KDHelpWhiteBGViewModel *)modelWithTips:(NSString *)tips {
    KDHelpWhiteBGViewModel *model = [[KDHelpWhiteBGViewModel alloc] init];
    model.tips = tips;
    return model;
}
@end

////////////////////////////////////////////////////////////////
@interface KDHelpViewCell : KDTableViewCell
@property (nonatomic, strong) UIImageView *dotImageView;
@property (nonatomic, strong) UILabel *tipsLabel;
@end

@implementation KDHelpViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.dotImageView];
        [self.contentView addSubview:self.tipsLabel];
        
        [self.dotImageView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.left);
            make.centerY.equalTo(self.contentView.top).with.offset(28);
            make.size.mas_equalTo(CGSizeMake(4, 4));
        }];
        
        [self.tipsLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.dotImageView.left).with.offset(8);
            make.bottom.equalTo(self.bottom);
            make.width.mas_equalTo(214);
            make.top.equalTo(self.top).with.offset(19);
        }];
    }
    return self;
}

-(UIImageView *)dotImageView {
    if (!_dotImageView) {
        _dotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
        _dotImageView.image = [UIImage kd_imageWithColor:FC3];
        _dotImageView.layer.cornerRadius = 2.f;
        _dotImageView.layer.masksToBounds = YES;
    }
    return _dotImageView;
}

-(UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.font = FS5;
        _tipsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipsLabel.textColor = [UIColor colorWithRGB:0x5D6972];
    }
    return _tipsLabel;
}

@end

////////////////////////////////////////////////////////////////
@interface KDTableViewHeadViewForHelpView()
@property (nonatomic, strong) UILabel *headLabel;
@property (nonatomic, strong) UIView *line;
@end

@implementation KDTableViewHeadViewForHelpView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.headLabel];
        [self addSubview:self.line];
        [self.headLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
        }];
        [self.line makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).with.offset(-0.5);
            make.width.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

-(void)setLabelText:(NSString *)labelText {
    _labelText = labelText;
    self.headLabel.text = labelText;
}

-(UILabel *)headLabel {
    if (!_headLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
        label.font = FS5;
        label.textColor = FC2;
        label.textAlignment = NSTextAlignmentLeft;
        _headLabel = label;
    }
    return _headLabel;
}

-(UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 0.5)];
        _line.backgroundColor = [UIColor kdDividingLineColor];
    }
    return _line;
}

@end


////////////////////////////////////////////////////////////////
@interface KDHelpWhiteBGView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIImageView *whiteBgView;
@property (nonatomic, strong) UITableView *contentTableView;

@property (nonatomic, assign) CGPoint bgViewCenterPoint;
@end

@implementation KDHelpWhiteBGView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.imageViewMask];
        [self addSubview:self.popDownBgView];
        [self.popDownBgView addSubview:self.imageViewTriangle];
        [self.popDownBgView addSubview:self.whiteBgView];
        [self.whiteBgView addSubview:self.contentTableView];

        [self.imageViewMask makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
        }];
        
        [self.popDownBgView makeConstraints:^(MASConstraintMaker *make)
         {
             make.top.equalTo(self.top).with.offset(64 - 4);
             make.height.mas_equalTo(346);
             make.centerX.equalTo(self.centerX);
             make.width.mas_equalTo(286);
         }];
        
        // 箭头
        [self.imageViewTriangle makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.mas_equalTo(14);
             make.centerX.equalTo(self.popDownBgView.centerX).with.offset(49);
             make.top.equalTo(self.popDownBgView.top);
             make.height.mas_equalTo(7);
         }];
        
        
        [self.whiteBgView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.popDownBgView.left);
            make.right.equalTo(self.popDownBgView.right);
            make.top.equalTo(self.popDownBgView.top).with.offset(7);
            make.bottom.equalTo(self.popDownBgView.bottom);
        }];
        
        [self.contentTableView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.popDownBgView).with.offset(-26);
            make.left.equalTo(self.popDownBgView).with.offset(30);
            make.top.equalTo(self.whiteBgView).with.offset(30);
            make.bottom.equalTo(self.whiteBgView).with.offset(-46);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTapped:)];
        [self.whiteBgView addGestureRecognizer:tap];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgViewCenterPoint = self.popDownBgView.center;
}

#pragma mark - Action

//收起helpView
- (void)shrinkView {
    if (isAboveiOS8)
    {
        self.popDownBgView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.popDownBgView.center = CGPointMake(ScreenFullWidth/2, -30);
    }
    else
    {
        CABasicAnimation* basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        basicAnimation.duration = 0;
        basicAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)];
        [self.popDownBgView.layer addAnimation:basicAnimation forKey:nil];
        
        self.popDownBgView.center = CGPointMake(ScreenFullWidth/2, -30);
    }
}

//弹出helpView
- (void)restoreView {
    if (isAboveiOS8)
    {
        self.popDownBgView.transform = CGAffineTransformIdentity;
        self.popDownBgView.center = self.bgViewCenterPoint;
    }
    else
    {
        CABasicAnimation* basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        //    ba.autoreverses = YES;
        basicAnimation.duration = 0;
        basicAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        [self.popDownBgView.layer addAnimation:basicAnimation forKey:nil];
        
        self.popDownBgView.center = self.bgViewCenterPoint;
    }
}

- (void)addModel:(KDHelpWhiteBGViewModel *)model {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.backgroundPressed)
    {
        self.backgroundPressed();
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([touches anyObject].view != self.contentTableView) {
        if (self.backgroundPressed) {
            self.backgroundPressed();
        }
    }
}

- (void)tableTapped:(UITapGestureRecognizer *)tap {
    
}

- (CGFloat)getCellHeight:(NSString *)content
{
    CGSize size = [content boundingRectWithSize:CGSizeMake(214, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : FS5} context:nil].size;
    return size.height;
}

#pragma mark - UITableViewDataSoure / UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mArrayModels.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    KDTableViewHeadViewForHelpView *headView = [[KDTableViewHeadViewForHelpView alloc] init];
    headView.labelText = self.title;
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self getCellHeight:self.title] + 15;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDHelpWhiteBGViewModel *model = [self.mArrayModels safeObjectAtIndex:indexPath.row];
    NSString *content = model.tips;
    return [self getCellHeight:content] + 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *HelpViewIdentifier = @"KDHelpViewIdentifier";
    KDHelpViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HelpViewIdentifier];
    if (!cell) {
        cell = [[KDHelpViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HelpViewIdentifier];
    }
    KDHelpWhiteBGViewModel *model = [self.mArrayModels safeObjectAtIndex:indexPath.row];
    cell.tipsLabel.text = model.tips;
    return cell;
}


#pragma mark - getter / setter

- (NSMutableArray *)mArrayModels {
    if (!_mArrayModels) {
        KDHelpWhiteBGViewModel *modelOne = [KDHelpWhiteBGViewModel modelWithTips:ASLocalizedString(@"当前部门及子部门成员默认加入群组")];
        KDHelpWhiteBGViewModel *modelTwo = [KDHelpWhiteBGViewModel modelWithTips:ASLocalizedString(@"新入职成员自动加入群组， 离职人员自动移出群组")];
        KDHelpWhiteBGViewModel *modelThree = [KDHelpWhiteBGViewModel modelWithTips:ASLocalizedString(@"群管理员可以配置群组应用")];
        KDHelpWhiteBGViewModel *modelFour = [KDHelpWhiteBGViewModel modelWithTips:ASLocalizedString(@"群组的群聊信息以及文件等可永久保存")];
        KDHelpWhiteBGViewModel *modelFive = [KDHelpWhiteBGViewModel modelWithTips:ASLocalizedString(@"可支持群成员2000人")];
        _mArrayModels = [NSMutableArray arrayWithObjects:modelOne, modelTwo, modelThree,modelFour, modelFive, nil];
    }
    return _mArrayModels;
}

- (UIImageView *)imageViewMask {
    if (!_imageViewMask)
    {
        _imageViewMask = [UIImageView new];
        _imageViewMask.backgroundColor = [UIColor kdBackgroundColor5];
    }
    return _imageViewMask;
}

- (UIView *)popDownBgView {
    if (!_popDownBgView) {
        _popDownBgView = [[UIView alloc] init];
        _popDownBgView.backgroundColor = [UIColor clearColor];
        _popDownBgView.layer.cornerRadius = 6.f;
    }
    return _popDownBgView;
}

- (UIImageView *)imageViewTriangle {
    if (!_imageViewTriangle)
    {
        _imageViewTriangle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_tip_bubblearrow"]];
    }
    return _imageViewTriangle;
}

- (UITableView *)contentTableView {
    if (!_contentTableView) {
        _contentTableView = [[UITableView alloc] init];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        _contentTableView.bounces = NO;
        _contentTableView.scrollEnabled = NO;
        _contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _contentTableView.backgroundColor = [UIColor clearColor];
    }
    return _contentTableView;
}

- (UIImageView *)whiteBgView {
    if (!_whiteBgView) {
        UIImage *image = [UIImage imageNamed:@"contact_tip_bubble"];
        
        // 设置左边端盖宽度
        NSInteger leftCapWidth = image.size.width * 0.5;
        // 设置上边端盖高度
        NSInteger topCapHeight = image.size.height * 0.5;
        
        UIImage *newImage = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
        _whiteBgView = [[UIImageView alloc] initWithImage:newImage];
        _whiteBgView.backgroundColor = [UIColor whiteColor];
        _whiteBgView.layer.cornerRadius = 6.f;
    }
    return _whiteBgView;
}

@end
