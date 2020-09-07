//
//  XTMyAccountCell.m
//  XT
//
//  Created by kingdee eas on 13-12-4.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTMyHeaderViewCell.h"
#import "BOSConfig.h"

@interface XTMyHeaderViewCell()
@property (nonatomic, retain) UIImageView *separateLineImageView;
@property (nonatomic, copy) NSString *cellType;
@end

@implementation XTMyHeaderViewCell
@synthesize headImageView,nameLabel,xtAccountLabel,bgImageView;


- (id)initWithStyle:(NSString *)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.cellType = style;
        self.separateLineSpace = 30.0;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.imageView.image = nil;
        
        //背景
        bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 194.5)];
        bgImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Setting_info_backgroud.png"]];
        [self addSubview:bgImageView];
        //头像
        headImageView = [[UIImageView alloc] init];
        [headImageView setImageWithURL:[NSURL URLWithString:[BOSConfig sharedConfig].user.photoUrl] placeholderImage:[XTImageUtil headerDefaultImage]];
        headImageView.frame = CGRectMake(17, 151.5, 86.0, 86.0);
        [self addSubview:headImageView];
        headImageView.layer.masksToBounds = YES;
        headImageView.layer.cornerRadius = 43.0;
        headImageView.layer.borderWidth = 4.0;
        headImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        
        if ([self.cellType isEqualToString:@"leftHeadViewType"]) {
            //姓名
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 198, 100, 20)];
            nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];

            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textColor = BOSCOLORWITHRGBA(0x2e343d, 1.0);
            nameLabel.text = [BOSConfig sharedConfig].user.name;
            [self addSubview:nameLabel];
            //讯通号
            xtAccountLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 230, 150, 15)];
            xtAccountLabel.font = [UIFont systemFontOfSize:12.0];
            xtAccountLabel.backgroundColor = [UIColor clearColor];
            xtAccountLabel.textColor = BOSCOLORWITHRGBA(0x2e343d, 1.0);
            xtAccountLabel.text = [NSString stringWithFormat:ASLocalizedString(@"XTMyHeaderViewCell_Num"),KD_APPNAME,[BOSConfig sharedConfig].user.petName];
            xtAccountLabel.hidden = YES;
            [self addSubview:xtAccountLabel];
        }
        else if ([self.cellType isEqualToString:@"rightHeadViewType"]){
            //头像标签
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 100, 20)];
            nameLabel.font = [UIFont systemFontOfSize:16.0];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textColor = BOSCOLORWITHRGBA(0x7A7A7A, 1.0);
            nameLabel.text = ASLocalizedString(@"XTMyHeaderViewCell_Photo");
            [self addSubview:nameLabel];
            //头像右移
            headImageView.frame = CGRectMake(ScreenFullWidth - 85, 10, 51.0, 51.0);
        }
        
        UIImageView *separateLineImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
        self.separateLineImageView = separateLineImageView;
        [self.contentView addSubview:separateLineImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    if (selectionStyle != UITableViewCellSelectionStyleNone) {
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xE5E5E5, 1.0);
        self.selectedBackgroundView = bgColorView;
    } else {
        self.selectedBackgroundView = nil;
    }
    
    [super setSelectionStyle:selectionStyle];
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 15.0, 15.0)];
        accessoryView.image = [XTImageUtil cellAccessoryDisclosureIndicatorImageWithState:UIControlStateNormal];
        accessoryView.highlightedImage = [XTImageUtil cellAccessoryDisclosureIndicatorImageWithState:UIControlStateHighlighted];
        self.accessoryView = accessoryView;
    } else {
        self.accessoryView = nil;
    }
    
    [super setAccessoryType:accessoryType];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    
    if (self.accessoryView != nil) {
        rect = self.accessoryView.frame;
        rect.origin.x = self.bounds.size.width - rect.size.width - (self.separateLineSpace - 15.0);
        self.accessoryView.frame = rect;
    }
    
    self.separateLineImageView.frame = CGRectMake(15.0, CGRectGetHeight(self.bounds) - 1, CGRectGetWidth(self.bounds) - self.separateLineSpace, 1.0);
}

@end

