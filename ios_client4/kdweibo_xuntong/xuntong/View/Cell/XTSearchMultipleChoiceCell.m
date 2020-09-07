//
//  XTSearchMultipleChoiceCell.m
//  XT
//
//  Created by Gil on 13-7-19.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSearchMultipleChoiceCell.h"
#import "XTSelectStateView.h"

@interface XTSearchMultipleChoiceCell ()
@property (nonatomic, strong) XTSelectStateView *selectStateView;
@end

@implementation XTSearchMultipleChoiceCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        XTSelectStateView *selectStateView = [[XTSelectStateView alloc] initWithFrame:CGRectZero];
        self.selectStateView = selectStateView;
        [self addSubview:selectStateView];
    }
    return self;
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated
{
    _checked = checked;
    
    [self.selectStateView setSelected:checked animated:animated];
    
    [self setNeedsLayout];
}

- (void)setChecked:(BOOL)checked
{
    [self setChecked:checked animated:NO];
}

- (void)setPType:(NSInteger)pType {
    if (pType == 2 && self.person.partnerType == 1) {
        self.selectStateView.isCanSelect = NO;
        self.selectStateView.selectStateImageView.image = nil;
    } else if (pType == 3 && self.person.partnerType == 0) {
        self.selectStateView.isCanSelect = NO;
        self.selectStateView.selectStateImageView.image = nil;
    } else {
        self.selectStateView.isCanSelect = YES;
        self.selectStateView.selectStateImageView.image = [XTImageUtil cellSelectStateImageWithState:self.checked];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.selectStateView.frame = CGRectMake(15, 0, 12, 12);
    self.selectStateView.center = CGPointMake(self.selectStateView.center.x, self.frame.size.height/2);
    
    CGRect rect = CGRectZero;
    rect.origin.x += CGRectGetWidth(rect) +  CGRectGetMaxX(self.selectStateView.frame)+15;
    self.headerImageView.frame = CGRectMake(rect.origin.x, self.headerImageView.frame.origin.y, self.headerImageView.frame.size.width, self.headerImageView.frame.size.height);
    
    double  offSetX = CGRectGetMaxX(self.headerImageView.frame) + 10.f;
    self.partnerImageView.frame = CGRectMake(CGRectGetMaxX(self.headerImageView.frame) + 10.f,
                                             CGRectGetMinY(self.nameLabel.frame), self.partnerImageView.frame.size.width, self.partnerImageView.frame.size.height);
    self.partnerImageView.center = CGPointMake(self.partnerImageView.center.x, self.nameLabel.center.y);
    if(![self.person isEmployee])
    {
        //假如是外部员工，那名称就要右移
        self.partnerImageView.hidden = NO;
        offSetX = CGRectGetMaxX(self.partnerImageView.frame) + 5.f;
    }
    else
        self.partnerImageView.hidden = YES;
    
    CGRect nameFrame = self.nameLabel.frame;
    nameFrame.origin.x = offSetX;//rect.origin.x + self.headerImageView.frame.size.width + 7.0;
    self.nameLabel.frame = nameFrame;
    
    CGRect departmentFrame = self.nameLabel.frame;
    departmentFrame.origin.x += (CGRectGetWidth(departmentFrame) + 7.0);
    departmentFrame.size.width = ScreenFullWidth - departmentFrame.origin.x - 5.0;
    self.departmentLabel.frame = departmentFrame;
    nameFrame.origin.y += (nameFrame.size.height + 6.0);
    self.phoneLabel.frame = CGRectMake(nameFrame.origin.x, nameFrame.origin.y, ScreenFullWidth - nameFrame.origin.x - 15.0, self.phoneLabel.frame.size.height);
    
    if((![BOSSetting sharedSetting].supportNotMobile || self.isFromTask) && ![self.person xtAvailable] && self.showGrayStyle)
    {
        self.selectStateView.isCanSelect = NO;
        self.selectStateView.alpha = 0.4;
        self.selectStateView.selectStateImageView.image = [UIImage imageNamed:@"select_photo_origin"];
        
        self.nameLabel.textColor = BOSCOLORWITHRGBA(0xD9D9D9, 1.0);
        self.departmentLabel.textColor = BOSCOLORWITHRGBA(0xD9D9D9, 1.0);
        self.phoneLabel.textColor = BOSCOLORWITHRGBA(0xD9D9D9, 1.0);
    }
    else
    {
        self.selectStateView.isCanSelect = YES;
        self.selectStateView.alpha = 1;
        self.selectStateView.selectStateImageView.image = [XTImageUtil cellSelectStateImageWithState:self.checked];
        
        self.nameLabel.textColor = FC1;
        self.departmentLabel.textColor = FC2;
        self.phoneLabel.textColor = FC2;
    }
}

@end
