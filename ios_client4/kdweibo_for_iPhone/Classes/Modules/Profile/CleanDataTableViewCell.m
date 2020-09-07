//
//  CleanDataTableViewCell.m
//  kdweibo
//
//  Created by wenjie_lee on 15/7/23.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "CleanDataTableViewCell.h"
#import "KDCommon.h"

@interface CleanDataTableViewCell ()

@property (nonatomic, retain) UIImageView *displayImageView;
@property (nonatomic, retain) UILabel  *displayLabel;
@property (nonatomic, retain) UIImageView  *selectImageView;
@property (nonatomic, strong) XTSelectStateView *selectStateView;
@end

@implementation CleanDataTableViewCell
//@synthesize  selected = _selected;

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         XTSelectStateView *selectStateView = [[XTSelectStateView alloc] initWithFrame:CGRectZero];
        self.selectStateView = selectStateView;
        [self addSubview:selectStateView];
        [self setupViews];
         self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.separatorLineStyle = KDTableViewCellSeparatorLineSpace;
        self.separatorLineInset = UIEdgeInsetsMake(0, 91.0, 0, 0);
    }
    return self;
}

- (void)setupViews
{
    self.displayImageView=[[UIImageView alloc] initWithFrame:CGRectZero];
    self.displayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.displayLabel.backgroundColor = [UIColor clearColor];
    self.displayLabel.font = [UIFont systemFontOfSize:17.f];
    self.displayLabel.textAlignment = NSTextAlignmentLeft;
    self.displayLabel.textColor = RGBCOLOR(60,60,60);
    
    [self addSubview:self.displayImageView];
    [self addSubview:self.displayLabel];
}

-(void)displayWithText:(NSString *)text Image:(NSString *)image andSize:(NSString *)size;
{
    NSString *displayTitle = nil;
    displayTitle = [NSString stringWithFormat:@"%@  (%@)", text, size];
    self.displayLabel.text = displayTitle;
    self.displayImageView.image = [UIImage imageNamed:image];
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated
{
    _checked = checked;
    
    [self.selectStateView setSelected:checked animated:animated];
    
}

- (void)setChecked:(BOOL)checked
{
    [self setChecked:checked animated:NO];
}

#define HEAD_IMAGE_VIEW_WIDTH_AND_HEIGHT (48.0f)
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat offsetX = 44.0;
    CGFloat height = super.contentView.bounds.size.height;
    
    CGRect rect = CGRectZero;
    offsetX += rect.size.width;
    rect = CGRectMake(offsetX, (height - 30.0) * 0.5,  35.0, 35.0);
    self.displayImageView.frame = rect;
    offsetX += rect.size.width + 12;
    
    rect = CGRectMake(offsetX, (height - 40.0) * 0.5,  CGRectGetWidth(self.frame) - 50, 48.0);
    
    self.displayLabel.frame = rect;
    
    rect = self.selectImageView.frame;
    rect.size.width=20;
    rect.size.height = 20;
//    offsetX = super.bounds.size.width - rect.size.width - 20.f;
    offsetX = 12.0;
    rect.origin = CGPointMake(offsetX, (height - rect.size.height) * 0.5 + 5);
    
    [self.selectStateView sizeToFit];
    self.selectStateView.frame = rect;

}


@end
