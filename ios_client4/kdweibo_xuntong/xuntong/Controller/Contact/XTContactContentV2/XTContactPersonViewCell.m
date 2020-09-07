//
//  XTContactPersonViewCell.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-18.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "XTContactPersonViewCell.h"
#import "UIView+Blur.h"

#define headerImageViewWidthAndHeight 40.f

@implementation XTContactPersonViewCell
@synthesize headerImageView = headerImageView_;
@synthesize nameLabel = nameLabel_;
@synthesize departmentLabel = departmentLabel_;
@synthesize person = person_;
@synthesize accessoryImageView = accessoryImageView_;
@synthesize isDisplay = isDisplay_;
@synthesize managerImage = managerImage_;
@synthesize parttimejobImage = parttimejobImage_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.isDisplay = YES;
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.contentView.backgroundColor = self.backgroundColor;

        
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xdddddd, 1.0);
        self.selectedBackgroundView = bgColorView;
        
        //头像
        self.headerImageView = [[XTPersonHeaderImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, headerImageViewWidthAndHeight, headerImageViewWidthAndHeight)];
        [self.contentView addSubview:self.headerImageView];
//        self.headerImageView.layer.masksToBounds = YES;
//        self.headerImageView.layer.cornerRadius = 2.0f;
        
        //外部员工图标
        self.partnerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 15, 15)];
        self.partnerImageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
        //self.partnerImageView.backgroundColor = [UIColor blueColor];
        self.partnerImageView.hidden = YES;
        [self.contentView addSubview:self.partnerImageView];

        //姓名或者组名
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.font = FS3;
        self.nameLabel.textColor = FC1;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLabel];
        

        self.departmentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.departmentLabel.font = FS5;
        self.departmentLabel.textColor = FC1;
        self.departmentLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.departmentLabel];
        
        
        accessoryImageView_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_img_vector"]];
        [accessoryImageView_ sizeToFit];
        accessoryImageView_.highlightedImage = [UIImage imageNamed:@"common_img_vector"];
        [self.contentView addSubview:accessoryImageView_];
        
        managerImage_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"college_img_gly"]];
        [managerImage_ sizeToFit];
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.text = ASLocalizedString(@"XTContactPersonViewCell_Admin");
        label.font = [UIFont systemFontOfSize:8.0f];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        label.center = CGPointMake(managerImage_.bounds.size.width / 2, managerImage_.bounds.size.height / 2);
        [managerImage_ addSubview:label];
        [self.contentView addSubview:managerImage_];
        managerImage_.hidden = YES;
        
    //兼职
        parttimejobImage_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"college_img_gly"]];
        [parttimejobImage_ sizeToFit];
        UILabel * parttimejoblabel = [[UILabel alloc]initWithFrame:CGRectZero];
        parttimejoblabel.text = ASLocalizedString(@"XTContactPersonViewCell_ParttimeJob");
        parttimejoblabel.font = [UIFont systemFontOfSize:8.0f];
        parttimejoblabel.textColor = [UIColor whiteColor];
        parttimejoblabel.backgroundColor = [UIColor clearColor];
        [parttimejoblabel sizeToFit];
        parttimejoblabel.center = CGPointMake(parttimejobImage_.bounds.size.width / 2, parttimejobImage_.bounds.size.height / 2);
        [parttimejobImage_ addSubview:parttimejoblabel];
        [self.contentView addSubview:parttimejobImage_];
        parttimejobImage_.hidden = YES;
        
//        [self addBorderAtPosition:KDBorderPositionBottom color:UIColorFromRGB(0xdddddd)];

        self.separatorLineInset = UIEdgeInsetsMake(0, kHeaderWidth_Big + 2 * 10, 0, 0);
    }
    return self;
}

- (void)setAccessoryImageView:(UIImageView *)accessoryImageView{
    if(accessoryImageView != accessoryImageView_){
        accessoryImageView_ = accessoryImageView;
    }
}

-(void)setPerson:(PersonSimpleDataModel *)person
{
    if (person_ != person) {
        person_ = person;
        self.headerImageView.person = person;
        
        //名称和部门
        nameLabel_.text = self.person.personName;
        departmentLabel_.text = self.person.department;
        
    }
    [self setNeedsLayout];
}

- (void)setDisplayDepartment : (BOOL)isDisplayDepartment{
    self.isDisplay = isDisplayDepartment;
    departmentLabel_.hidden = !isDisplay_;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //头像
    CGFloat offsetx = 10.0f;
    CGFloat offsety = 7.5f;
    CGRect rect = CGRectMake(offsetx,(CGRectGetHeight(self.bounds) - headerImageViewWidthAndHeight)/2, headerImageViewWidthAndHeight, headerImageViewWidthAndHeight);
    headerImageView_.frame = rect;
    
    offsetx = CGRectGetMaxX(headerImageView_.frame) + 20.f;
    offsety += 2.f;
    
    [nameLabel_ sizeToFit];
    rect = CGRectMake(offsetx, offsety, nameLabel_.bounds.size.width, nameLabel_.bounds.size.height);
    nameLabel_.frame = rect;
    
    offsetx = CGRectGetMaxX(nameLabel_.frame) + 5.f;
    self.partnerImageView.frame = CGRectMake(offsetx, offsety, self.partnerImageView.frame.size.width, self.partnerImageView.frame.size.height);
    if(![self.person isEmployee]){
        //假如是外部员工，那名称就要右移
        self.partnerImageView.hidden = NO;
    }
    else {
        self.partnerImageView.hidden = YES;
    }
    
    offsety = CGRectGetMaxY(nameLabel_.frame) + 13.f;
    rect = CGRectMake(CGRectGetMinX(nameLabel_.frame), offsety, 232.f, 16.f);
    departmentLabel_ .frame =rect;
    
    accessoryImageView_.center = CGPointMake(CGRectGetWidth(self.contentView.frame) - 13.0f - CGRectGetWidth(accessoryImageView_.frame) * 0.5f, CGRectGetMidY(headerImageView_.frame));
    
    CGFloat width = 0.0f;
    if ( !self.isDisplay) {
        departmentLabel_.text = nil;
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.headerImageView.center.y);
    } else {
        departmentLabel_.text = self.person.department;
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.headerImageView.frame.origin.y + 5.0 + self.nameLabel.frame.size.height/2);
    }
    self.partnerImageView.center = CGPointMake(self.partnerImageView.center.x, self.nameLabel.center.y);
    
    if (person_.isAdmin) {
        if (_showManagerImage)
        {
            self.managerImage.center = CGPointMake(CGRectGetMaxX(self.nameLabel.frame) + 30 + self.managerImage.bounds.size.width / 2, self.nameLabel.center.y);
            self.managerImage.hidden = NO;
            width = CGRectGetWidth(self.managerImage.frame)+10;
        }
     }
    else{
          self.managerImage.hidden = YES;
    }
    if (_showParttimeJob)
    {
        self.parttimejobImage.center = CGPointMake(CGRectGetMaxX(self.nameLabel.frame) + width + 20 + self.parttimejobImage.bounds.size.width / 2, self.nameLabel.center.y);
        self.parttimejobImage.hidden = NO;
    }
    else{
        self.parttimejobImage.hidden = YES;
    }

}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    
    [MESSAGE_CT_COLOR set];
    [path fill];
    
    path = [UIBezierPath bezierPath];
    path.lineWidth = 1.f;
    UIColor *color = UIColorFromRGB(0xdddddd);
    [color set];
    
    [path moveToPoint:CGPointMake(0, CGRectGetHeight(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
    
    
    [path stroke];
}



@end
