//
//  XTContactPersonMultipleChoiceCell.m
//  XT
//
//  Created by Gil on 13-7-19.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTContactPersonMultipleChoiceCell.h"
#import "PersonSimpleDataModel.h"

@interface XTContactPersonMultipleChoiceCell ()
@property (nonatomic, strong) XTSelectStateView *selectStateView;
@end

@implementation XTContactPersonMultipleChoiceCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        XTSelectStateView *selectStateView = [[XTSelectStateView alloc] initWithFrame:CGRectZero];
        self.selectStateView = selectStateView;
        [self addSubview:selectStateView];
        
        self.separateLineSpace = 35.0 + 2*10;
//        self.headerImageView.layer.cornerRadius = 3.0f;
    }
    return self;
}

-(void)setHideCheckView:(BOOL)hideCheckView
{
    _hideCheckView = hideCheckView;
    [self setNeedsLayout];
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated
{
    _checked = checked;
    
    [self.selectStateView setSelected:checked animated:animated];
    
//    [self setNeedsLayout];
}

- (void)setChecked:(BOOL)checked
{
    [self setChecked:checked animated:NO];
}

- (void) setAgoraSelected:(BOOL)agoraSelected
{
//     [self.selectStateView setAgoraSelected:agoraSelected];
    _agoraSelected = agoraSelected;
    [self setNeedsLayout];
}

- (void)setPerson:(PersonSimpleDataModel *)person
{
    [super setPerson:person];
    
    self.nameLabel.text = self.person.personName;
    self.departmentLabel.text = self.person.jobTitle;
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

#define HEAD_IMAGE_VIEW_WIDTH_AND_HEIGHT (48.0f)
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat offSetX = (self.hideCheckView?10:55.0f);
    CGFloat offSetY = 8.5f;
    
    CGRect rect = CGRectMake(offSetX, offSetY, HEAD_IMAGE_VIEW_WIDTH_AND_HEIGHT, HEAD_IMAGE_VIEW_WIDTH_AND_HEIGHT);
    
    self.headerImageView.frame = rect;
    
    offSetX = CGRectGetMaxX(self.headerImageView.frame) + 10.f;
    self.partnerImageView.frame = CGRectMake(offSetX, 0, self.partnerImageView.frame.size.width, self.partnerImageView.frame.size.height);
    if(![self.person isEmployee])
    {
        //假如是外部员工，那名称就要右移
        self.partnerImageView.hidden = NO;
        offSetX = CGRectGetMaxX(self.partnerImageView.frame) + 5.f;
    }
    else
        self.partnerImageView.hidden = YES;
    
//    [self.departmentLabel sizeToFit];
    
//    rect = CGRectMake(offSetX, offSetY + 2.f, 240, 16.f);
//    self.nameLabel.frame = rect;
    
    rect = self.headerImageView.frame; 
    rect.origin.x = offSetX;//(CGRectGetWidth(rect) + 7.0);
    //rect.origin.y += 5.0;
    self.nameLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, ScreenFullWidth - rect.origin.x - 15.0, self.nameLabel.frame.size.height);
    if (self.departmentLabel.text.length == 0) {
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.headerImageView.center.y);
    } else {
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, 12 + self.nameLabel.frame.size.height/2);
    }
    
    rect = self.nameLabel.frame;
    rect.origin.x = CGRectGetMinX(self.partnerImageView.frame);
    rect.origin.y += (rect.size.height + 5.0);
    self.departmentLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, ScreenFullWidth - rect.origin.x - 15.0, self.departmentLabel.frame.size.height);
    [self.selectStateView sizeToFit];
    self.selectStateView.backgroundColor = [UIColor redColor];
    self.selectStateView.frame = CGRectMake((self.headerImageView.frame.origin.x - self.selectStateView.bounds.size.width) * 0.5,
                                            (CGRectGetHeight(self.frame) - self.selectStateView.bounds.size.height) * 0.5f,
                                            self.selectStateView.bounds.size.width,
                                            self.selectStateView.bounds.size.height);
    self.selectStateView.hidden = self.hideCheckView;
    
    self.partnerImageView.center = CGPointMake(self.partnerImageView.center.x, self.nameLabel.center.y);
    
    if (_agoraSelected) {
        self.selectStateView.selectStateImageView.image = [UIImage imageNamed:@"common_btn_check_disable"];
    }
    else
    {
        if((((![BOSSetting sharedSetting].supportNotMobile || self.isFromTask) && ![self.person xtAvailable]) || ![self.person accountAvailable]) && self.showGrayStyle)
        {
            self.selectStateView.isCanSelect = NO;
            self.selectStateView.alpha = 0.4;
            self.selectStateView.selectStateImageView.image = [UIImage imageNamed:@"select_photo_origin"];
            
            self.nameLabel.textColor = BOSCOLORWITHRGBA(0xD9D9D9, 1.0);;
            self.departmentLabel.textColor = BOSCOLORWITHRGBA(0xD9D9D9, 1.0);
        }
        else
        {
            self.selectStateView.isCanSelect = YES;
            self.selectStateView.alpha = 1;
            self.selectStateView.selectStateImageView.image = [XTImageUtil cellSelectStateImageWithState:self.checked];
            
            self.nameLabel.textColor = FC1;
            self.departmentLabel.textColor = BOSCOLORWITHRGBA(0xB9B9B9, 1.0);
        }
    }
}

@end
