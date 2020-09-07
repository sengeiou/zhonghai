//
//  KDPlusMenuView.m
//  kdweibo
//
//  Created by Darren on 15/5/20.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDPlusMenuView.h"
#import "NSData+Base64.h"


@implementation KDPlusMenuViewModel
+ (KDPlusMenuViewModel *)modelWithTitle:(NSString *)strTitle
                              imageName:(NSString *)strImageName
                              selection:(void (^)())block
{
    KDPlusMenuViewModel *model = [KDPlusMenuViewModel new];
    model.strTitle = strTitle;
    model.strImageName = strImageName;
    model.selection = block;
    return model;
}

+ (KDPlusMenuViewModel *)modelWithTitle:(NSString *)strTitle
                         base64StrImage:(NSString *)base64StrImage
                              selection:(void (^)())block
{
    KDPlusMenuViewModel *model = [KDPlusMenuViewModel new];
    model.strTitle = strTitle;
    model.base64StrImage = base64StrImage;
    model.selection = block;
    return model;
}
@end

//////////////////////////////////////////////////////////////////////////

@interface KDPlusMenuViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *imageViewIcon;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIImageView *imageViewLine;
@end


@interface KDPlusMenuViewCell ()
@end

@implementation KDPlusMenuViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageViewLine];
        [self.contentView addSubview:self.imageViewIcon];
        [self.contentView addSubview:self.labelTitle];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = UIColorFromRGB(0x2c3a4e);
        [self setSelectedBackgroundView:bgColorView];
        
        [self.imageViewLine makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.contentView.left).with.offset(11.5);
             make.right.equalTo(self.contentView.right).with.offset(-11.5);
             make.bottom.equalTo(self.contentView.bottom).with.offset(-0);
             make.height.mas_equalTo(1);
             make.centerX.equalTo(self.contentView.centerX);
         }];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.imageViewIcon.image)
    {
        self.labelTitle.textAlignment = NSTextAlignmentLeft;
        
        [self.imageViewIcon makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.contentView.left).with.offset(17.5);
             make.width.mas_equalTo(20);
             make.height.mas_equalTo(20);
             make.centerY.equalTo(self.contentView.centerY);
         }];
        
        [self.labelTitle makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.imageViewIcon.right).with.offset(8);
             make.right.equalTo(self.contentView.right).with.offset(-11);
             make.centerY.equalTo(self.contentView.centerY);
         }];
    }
    else
    {
        self.labelTitle.textAlignment = NSTextAlignmentCenter;
        
        [self.labelTitle makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.contentView.left).with.offset(11);
             make.right.equalTo(self.contentView.right).with.offset(-11);
             make.centerY.equalTo(self.contentView.centerY);
         }];
    }
}

- (UIImageView *)imageViewLine
{
    if (!_imageViewLine)
    {
        _imageViewLine = [UIImageView new];
        _imageViewLine.backgroundColor = UIColorFromRGB(0xDDDDDD);
        _imageViewLine.alpha = 0.2;
    }
    return _imageViewLine;
}

- (UIImageView *)imageViewIcon
{
    if (!_imageViewIcon)
    {
        _imageViewIcon = [UIImageView new];
    }
    return _imageViewIcon;
}

- (UILabel *)labelTitle
{
    if (!_labelTitle)
    {
        _labelTitle = [UILabel new];
        _labelTitle.font = FS4;
        _labelTitle.textColor = FC6;
    }
    return _labelTitle;
}

@end

//////////////////////////////////////////////////////////////////////////

@interface KDPlusMenuView ()
<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableViewMain;
@property (nonatomic, strong) UIImageView *imageViewMask;
@property (nonatomic, strong) UIImageView *imageViewTriangle;
@property (nonatomic, strong) UIView *viewTableBG;
@property (nonatomic, strong) UIView *viewTableInnerBG; // = tableview frame
@property (nonatomic, assign) CGPoint centerViewTableBG;
@property (nonatomic, strong) UIImageView *imageViewTableViewBG;
//@property (nonatomic, strong) NSLayoutConstraint *lcTableViewHeight;
@property (nonatomic, assign) float fTableViewHeight;

@property (nonatomic, strong) NSMutableArray *mArrayViewTableBGConstraints;
@property (nonatomic, strong) NSString *strViewTableBGVFL;
@end

@implementation KDPlusMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.imageViewMask];
        
        [self.imageViewMask makeConstraints:^(MASConstraintMaker *make)
         {
             make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
         }];
        self.strViewTableBGVFL = @"[$(160)]-5-|,V:|-6-[$]";
        [self addSubview:self.viewTableBG];
        
        [self.viewTableBG makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.mas_equalTo(160);
             make.right.equalTo(self.right).with.offset(-5);
             make.top.equalTo(self.top).with.offset(6);
             make.height.mas_equalTo(300);
         }];
        
        [self.viewTableBG addSubview:self.imageViewTriangle];
        
        [self.imageViewTriangle makeConstraints:^(MASConstraintMaker *make)
         {
             make.width.mas_equalTo(10);
             make.right.equalTo(self.viewTableBG.right).with.offset(-13);
             make.top.equalTo(self.viewTableBG.top).with.offset(0);
             make.height.mas_equalTo(5);
         }];
        
        [self.viewTableBG addSubview:self.viewTableInnerBG];
        
        [self.viewTableInnerBG makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.equalTo(self.viewTableBG.left).with.offset(0);
             make.right.equalTo(self.viewTableBG.right).with.offset(-0);
             make.top.equalTo(self.viewTableBG.top).with.offset(5);
             make.bottom.equalTo(self.viewTableBG.bottom).with.offset(-0);
         }];
        
        [self.viewTableInnerBG addSubview:self.imageViewTableViewBG];
        
        [self.imageViewTableViewBG makeConstraints:^(MASConstraintMaker *make)
         {
             make.edges.equalTo(self.viewTableInnerBG).with.insets(UIEdgeInsetsZero);
         }];
        
        [self.viewTableInnerBG addSubview:self.tableViewMain];
        
        [self.tableViewMain makeConstraints:^(MASConstraintMaker *make)
         {
             make.edges.equalTo(self.viewTableInnerBG).with.insets(UIEdgeInsetsZero);
         }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTapped:)];
        [self.tableViewMain addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.centerViewTableBG = self.viewTableBG.center;
}

- (void)shrinkTable
{
    
    if (isAboveiOS8)
    {
        self.viewTableBG.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.viewTableBG.center = CGPointMake(ScreenFullWidth-30, 0);
    }
    else
    {
        CABasicAnimation* ba = [CABasicAnimation animationWithKeyPath:@"transform"];
        //    ba.autoreverses = YES;
        ba.duration = 0;
        ba.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)];
        [self.viewTableBG.layer addAnimation:ba forKey:nil];
        
        self.viewTableBG.center = CGPointMake(ScreenFullWidth-30, 0);
    }
    
}

- (void)restoreTable
{
    
    if (isAboveiOS8)
    {
        self.viewTableBG.transform = CGAffineTransformIdentity;
        self.viewTableBG.center = self.centerViewTableBG;
    }
    else
    {
        CABasicAnimation* ba = [CABasicAnimation animationWithKeyPath:@"transform"];
        //    ba.autoreverses = YES;
        ba.duration = 0;
        ba.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        [self.viewTableBG.layer addAnimation:ba forKey:nil];
        
        self.viewTableBG.center = self.centerViewTableBG;
    }
}

- (UITableView *)tableViewMain
{
    if (!_tableViewMain)
    {
        _tableViewMain = [UITableView new];
        _tableViewMain.delegate = self;
        _tableViewMain.dataSource = self;
        _tableViewMain.bounces = NO;
        _tableViewMain.scrollEnabled = NO;
        _tableViewMain.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableViewMain.backgroundColor = [UIColor clearColor];
    }
    return _tableViewMain;
}

- (UIImageView *)imageViewMask
{
    if (!_imageViewMask)
    {
        _imageViewMask = [UIImageView new];
        _imageViewMask.backgroundColor = [UIColor clearColor];
    }
    return _imageViewMask;
}

- (UIImageView *)imageViewTriangle
{
    if (!_imageViewTriangle)
    {
        _imageViewTriangle = [UIImageView new];
        _imageViewTriangle.image = [UIImage imageNamed:@"message_bg_triangle"];
    }
    return _imageViewTriangle;
}

- (UIView *)viewTableBG
{
    if (!_viewTableBG)
    {
        _viewTableBG = [UIView new];
    }
    return _viewTableBG;
}

- (UIView *)viewTableInnerBG
{
    if (!_viewTableInnerBG)
    {
        _viewTableInnerBG = [UIView new];
        _viewTableInnerBG.clipsToBounds = YES;
        _viewTableInnerBG.layer.cornerRadius = 5;
    }
    return _viewTableInnerBG;
}

- (UIImageView *)imageViewTableViewBG
{
    if (!_imageViewTableViewBG)
    {
        _imageViewTableViewBG = [UIImageView new];
        _imageViewTableViewBG.backgroundColor = UIColorFromRGB(0x4142a);
        _imageViewTableViewBG.alpha = 0.75;
    }
    return _imageViewTableViewBG;
}

- (void)setMArrayModels:(NSMutableArray *)mArrayModels
{
    _mArrayModels = mArrayModels;
    self.fTableViewHeight = self.mArrayModels.count * 45;
    [self.viewTableBG updateConstraints:^(MASConstraintMaker *make)
     {
         make.height.mas_equalTo(self.fTableViewHeight);
     }];
}

#pragma mark - Table View -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mArrayModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyCell";
    KDPlusMenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[KDPlusMenuViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:MyIdentifier];
    }
    
    KDPlusMenuViewModel *model = [self.mArrayModels objectAtIndex:indexPath.row];
    if (model.strImageName) {
        cell.imageViewIcon.image = [UIImage imageNamed:model.strImageName];
    }else if(model.base64StrImage)
    {
        NSData *imageData = [NSData dataFromBase64String:model.base64StrImage];
        if(imageData)
        {
            cell.imageViewIcon.image = [UIImage imageWithData:imageData];
        }
    }
    cell.labelTitle.text = model.strTitle;
    cell.imageViewLine.hidden = indexPath.row == self.mArrayModels.count - 1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDPlusMenuViewModel *model = [self.mArrayModels objectAtIndex:indexPath.row];
    if (model.selection)
    {
        model.selection();
    }
    
    [self.tableViewMain deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.backgroundPressed)
    {
        self.backgroundPressed();
    }
}

- (void)tableTapped:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:self.tableViewMain];
    NSIndexPath *path = [self.tableViewMain indexPathForRowAtPoint:location];
    
    if(path)
    {
        // tap was on existing row, so pass it to the delegate method
        [self tableView:self.tableViewMain didSelectRowAtIndexPath:path];
    }
    else
    {
        if (self.backgroundPressed)
        {
            self.backgroundPressed();
        }
        // handle tap on empty space below existing rows however you want
    }
}

@end
