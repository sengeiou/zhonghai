//
//  XTSearchCell.m
//  XT
//
//  Created by Gil on 13-7-15.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTSearchCell.h"
#import "T9SearchResult.h"
#import "T9.h"
#import "BOSSetting.h"

@interface XTSearchCell ()

@property (nonatomic, strong) XTPersonHeaderImageView *headerImageView;
@property (nonatomic, strong) UIImageView *partnerImageView;
@property (nonatomic, strong) RTLabel *nameLabel;
@property (nonatomic, strong) RTLabel *pinyinLabel;
@property (nonatomic, strong) UILabel *departmentLabel;
@property (nonatomic, strong) RTLabel *phoneLabel;
@property (nonatomic, strong) UIImageView *separateLineImageView;

@end

@implementation XTSearchCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.contentView.backgroundColor = BOSCOLORWITHRGBA(0xffffff, 1.0);
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xE5E5E5, 1.0);

        self.selectedBackgroundView = bgColorView;
        
        //头像
        self.headerImageView = [[XTPersonHeaderImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 48.0, 48.0)];
        [self.contentView addSubview:self.headerImageView];
        
        
        //外部员工图标
        self.partnerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 15, 15)];
        self.partnerImageView.image = [UIImage imageNamed:@"message_tip_shang_small"];
        //self.partnerImageView.backgroundColor = [UIColor blueColor];
        self.partnerImageView.hidden = YES;
        [self.contentView addSubview:self.partnerImageView];

        
        CGRect frame = self.headerImageView.frame;
        frame.origin.x += (CGRectGetWidth(frame) + 10.0);
        frame.origin.y += 2.0;
        
        //姓名
        CGFloat height = 20;
        if (isAboveiOS9) {
            height = 24.0;
        }
        //姓名
        self.nameLabel = [[RTLabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 80.0, height)];
        self.nameLabel.font = FS2;
        self.nameLabel.textColor = FC1;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.lineBreakMode = RTTextLineBreakModeCharWrapping;
        [self.contentView addSubview:self.nameLabel];
        
        //电话
        frame = self.nameLabel.frame;
        frame.origin.y += (frame.size.height + 7.0);
        self.phoneLabel = [[RTLabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 232.0, 20.0)];
        self.phoneLabel.font = FS5;
        self.phoneLabel.textColor = FC2;
        self.phoneLabel.backgroundColor = [UIColor clearColor];
        self.phoneLabel.lineBreakMode = RTTextLineBreakModeCharWrapping;
        [self.contentView addSubview:self.phoneLabel];
        
        //部门
        frame = self.nameLabel.frame;
        frame.origin.x += (CGRectGetWidth(frame) + 10.0);
        self.departmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 152.0, 16.0)];
        self.departmentLabel.font = FS5;
        self.departmentLabel.textColor = FC2;
        self.departmentLabel.textAlignment = NSTextAlignmentLeft;
        self.departmentLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.departmentLabel];
        
        //拼音 (和电话共用一个显示位置，交替显示）
        self.pinyinLabel = [[RTLabel alloc] initWithFrame:self.phoneLabel.frame];
        self.pinyinLabel.font = FS5;
        self.pinyinLabel.textColor = FC2;
        self.pinyinLabel.textAlignment = RTTextAlignmentLeft;
        self.pinyinLabel.backgroundColor = [UIColor clearColor];
        self.pinyinLabel.lineBreakMode = RTTextLineBreakModeCharWrapping;
        [self.contentView addSubview:self.pinyinLabel];
        
        self.separateLineImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
        [self.contentView addSubview:self.separateLineImageView];
        
        self.separatorLineInset = UIEdgeInsetsMake(0, kHeaderWidth_Big + 2*10, 0, 0);
    }
    return self;
}

-(void)setSearchResult:(T9SearchResult *)searchResult
{
    if (_searchResult != searchResult) {
        _searchResult = searchResult;
        self.person = [[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithResult:searchResult];
    }
}

-(void)setPerson:(PersonSimpleDataModel *)person
{
    if (_person != person) {
        _person = person;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    //头像
    self.headerImageView.person = self.person;
    
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
    

    CGRect rect = self.headerImageView.frame;
    rect.origin.x = offSetX;
    self.nameLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, ScreenFullWidth - rect.origin.x - 15.0, self.nameLabel.frame.size.height);
   
    
    //姓名
    if ([[BOSSetting sharedSetting] isNetworkOrgTreeInfo]) {
        self.nameLabel.text = self.person.personName;
    }else{
        if (self.person.highlightName != nil) {
            self.nameLabel.text = self.person.highlightName;
        } else {
            self.nameLabel.text = @"";
        }
    }
    
    float width = self.nameLabel.plainText.length * 18.0;
    if (width > ScreenFullWidth / 2) {
        width = ScreenFullWidth / 2 - 30;
    }
    CGRect nameFrame = self.nameLabel.frame;
    nameFrame.size.width = width;
    self.nameLabel.frame = CGRectMake(nameFrame.origin.x, [NSNumber kdDistance1], nameFrame.size.width, nameFrame.size.height);
    //部门
    CGRect departmentFrame = self.nameLabel.frame;
    departmentFrame.origin.x += (CGRectGetWidth(nameFrame) + 10.0);
    departmentFrame.size.width = ScreenFullWidth - departmentFrame.origin.x - 15.0;
    self.departmentLabel.frame = departmentFrame;
    self.departmentLabel.text = self.person.department;
    
    if(![[BOSSetting sharedSetting]isNetworkOrgTreeInfo]){
        //拼音
        if (self.person.highlightFullPinyin != nil) {
            self.pinyinLabel.text = self.person.highlightFullPinyin;
        } else {
            self.pinyinLabel.text = @"";
        }
        
        //电话
        if (self.person.highlightDefaultPhone != nil) {
            self.phoneLabel.text = self.person.highlightDefaultPhone;
        } else {
            self.phoneLabel.text = @"";
        }
        
        if (self.searchResult.type == T9ResultTypeT9)
        {
            [self.pinyinLabel setHidden:NO];
            [self.phoneLabel setHidden:YES];
        }
        else
        {
            [self.pinyinLabel setHidden:YES];
            [self.phoneLabel setHidden:NO];
        }
    }else{
        self.phoneLabel.text = self.person.defaultPhone;
    }
    
//    self.separateLineImageView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 1, ScreenFullWidth, 1.0);
    self.separateLineImageView.frame = CGRectMake(self.separatorLineInset.left, CGRectGetHeight(self.contentView.frame) - 0.5, ScreenFullWidth - self.separatorLineInset.left - self.separatorLineInset.right, 0.5);
    
    
    [super layoutSubviews];
}

@end
