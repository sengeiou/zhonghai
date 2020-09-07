//
//  XTPersonContactCell.m
//  XT
//
//  Created by Gil on 13-7-3.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTContactPersonCell.h"
#import "PersonSimpleDataModel.h"

@interface XTContactPersonCell ()
@property (nonatomic, strong) XTPersonHeaderImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *departmentLabel;
@property (nonatomic, strong) UIImageView *separateLineImageView;
@end

@implementation XTContactPersonCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.separateLineSpace = 30.0;
        self.contentView.backgroundColor = BOSCOLORWITHRGBA(0xffffff, 1.0);
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xE5E5E5, 1.0);
        self.selectedBackgroundView = bgColorView;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        //头像
        self.headerImageView = [[XTPersonHeaderImageView alloc] initWithFrame:CGRectMake(14.0, 5.0, 44, 44)];
        [self.contentView addSubview:self.headerImageView];
        self.headerImageView.layer.masksToBounds = YES;
        self.headerImageView.layer.cornerRadius = 5.0;
        self.headerImageView.layer.borderWidth = 1.0;
        self.headerImageView.layer.borderColor = [[UIColor clearColor] CGColor];
        
        CGRect unActivatedFrame = self.headerImageView.unActivatedLabel.frame;
        unActivatedFrame.origin.x += 4;
        unActivatedFrame.origin.y += 6;
        self.headerImageView.unActivatedLabel.frame = unActivatedFrame;
        
        //外部员工图标
        self.partnerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 15, 15)];
        self.partnerImageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
        //self.partnerImageView.backgroundColor = [UIColor blueColor];
        self.partnerImageView.hidden = YES;
        [self.contentView addSubview:self.partnerImageView];
        
        
        CGRect frame = self.headerImageView.frame;
        frame.origin.x += (CGRectGetWidth(frame) + 7.0);
        frame.origin.y += 5.0;
        //姓名或者组名
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+10, 232.0, 26.0)];
        self.nameLabel.font = FS3;
        self.nameLabel.textColor = FC1;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLabel];
        
        frame = self.nameLabel.frame;
        frame.origin.y += (frame.size.height + 5.0);
        self.departmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 232.0, 14.0)];
        self.departmentLabel.font = [UIFont systemFontOfSize:14.0];
        self.departmentLabel.textColor = BOSCOLORWITHRGBA(0xB9B9B9, 1.0);
        self.departmentLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.departmentLabel];
        
        self.separateLineImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
        [self.contentView addSubview:self.separateLineImageView];
        
    }
    return self;
}

-(void)setPerson:(PersonSimpleDataModel *)person
{
    if (_person != person) {
        _person = person;
        
        self.nameLabel.text = self.person.personName;
        self.departmentLabel.text = self.person.department;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //头像
    [self.headerImageView setPerson:self.person];
    
    if (self.person.department.length == 0) {
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.headerImageView.center.y);
    } else {
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.headerImageView.frame.origin.y + 5.0 + self.nameLabel.frame.size.height/2);
    }
    
    self.separateLineImageView.frame = CGRectMake(self.separateLineSpace, CGRectGetHeight(self.bounds) - 0.5, CGRectGetWidth(self.bounds) - self.separateLineSpace, 0.5);
}

@end
