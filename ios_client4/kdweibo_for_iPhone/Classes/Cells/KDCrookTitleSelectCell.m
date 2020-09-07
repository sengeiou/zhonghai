//
//  KDCrookTitleSelectCell.m
//  kdweibo
//
//  Created by bird on 14-4-22.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDCrookTitleSelectCell.h"

@interface KDCrookTitleSelectCell()

@property (nonatomic, retain) UIImageView *crookView;
@property (nonatomic, retain) UIView      *externView;
@end

@implementation KDCrookTitleSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        [super.contentView addSubview:_titleLabel];
        
        _companyIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _companyIdLabel.backgroundColor = [UIColor clearColor];
        _companyIdLabel.font = [UIFont systemFontOfSize:14];
        _companyIdLabel.textColor = RGBCOLOR(174.f, 174.f, 174.f);
        _companyIdLabel.highlightedTextColor = [UIColor whiteColor];
        [super.contentView addSubview:_companyIdLabel];


        _crookView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_crookView sizeToFit];
        [super.contentView addSubview:_crookView];
        
        _externView = [[UIView alloc] initWithFrame:CGRectZero];
        _externView.backgroundColor = MESSAGE_LINE_COLOR;
        [super.contentView addSubview:_externView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        super.contentView.backgroundColor = MESSAGE_CT_COLOR;
    }
    return self;
}
- (void)dealloc
{
    //KD_RELEASE_SAFELY(_companyIdLabel);
    //KD_RELEASE_SAFELY(_titleLabel);
    //KD_RELEASE_SAFELY(_crookView);
    //KD_RELEASE_SAFELY(_externView);
    
    //[super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds   = super.contentView.bounds;
    CGRect frame    = bounds;
    
    frame.size      = CGSizeMake(ScreenFullWidth- 70, 23);
    frame.origin.x  = 15.f;
    frame.origin.y  = (bounds.size.height - 2*frame.size.height)*0.5;
    
    _titleLabel.frame = frame;
    
    frame.origin.y = CGRectGetMaxY(frame);
    _companyIdLabel.frame = frame;
    
    frame.origin.x = CGRectGetMaxX(frame) +17.f;
    frame.size.width = 23.f;
    frame.origin.y = (bounds.size.height - frame.size.height)*0.5;
    _crookView.frame = frame;
    
    frame.origin.y = CGRectGetHeight(bounds) - 0.5f;
    frame.origin.x = 0.f;
    frame.size = CGSizeMake(bounds.size.width, 0.5f);
    _externView.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.contentView.backgroundColor = highlighted?[UIColor colorWithRed:26/255.0 green:133/255.0 blue:1.0 alpha:1.0f]:[UIColor clearColor];
    _titleLabel.highlighted = highlighted;
}
- (void)hideCrookView:(BOOL)hidden{
    [_crookView setHidden:hidden];
}
- (void)setIsSelected:(BOOL)selected
{
    if (selected)
        [_crookView setImage:[UIImage imageNamed:@"choose_circle_n"]];
    else
        [_crookView setImage:[UIImage imageNamed:@"choose-circle-o"]];
}
- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}
@end
