//
//  ProfileViewCell.m
//  kdweibo
//
//  Created by 王 松 on 14-4-25.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "ProfileViewCell.h"

@interface KDProfileCellBackgroundView : UIView

@property (nonatomic, assign) ProfileViewCellPlace cellPlace;

@property (nonatomic, assign) BOOL highlighted;

@property (nonatomic, assign) UIView *highlightedView;

@end

@interface ProfileViewCell ()

@property (nonatomic, retain) KDProfileCellBackgroundView *pBackgroundView;

@property (nonatomic, retain) UIImageView *narrowImageView;

@end

@implementation ProfileViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        _layout = ProfileViewCellLayout_InfoLeft;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupViews
{
    _pBackgroundView = [[KDProfileCellBackgroundView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.frame) - 20.f, 50.f)];
    
    _mainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _mainLabel.backgroundColor = [UIColor clearColor];
    _mainLabel.font = [UIFont boldSystemFontOfSize:16.f];
    
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.font = [UIFont systemFontOfSize:16.f];
    _infoLabel.textAlignment = NSTextAlignmentLeft;
    _infoLabel.textColor = MESSAGE_NAME_COLOR;
    
    _narrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_narrow_v3.png"]];
    [_narrowImageView sizeToFit];
    _narrowImageView.highlightedImage = [UIImage imageNamed:@"profile_edit_arrow.png"];
    
    [_pBackgroundView addSubview:_mainLabel];
    [_pBackgroundView addSubview:_infoLabel];
    [_pBackgroundView addSubview:_narrowImageView];
    [self.contentView addSubview:_pBackgroundView];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

-(void)setShouldHideNarrow:(BOOL)shouldHideNarrow{
    _narrowImageView.hidden = shouldHideNarrow;
}

- (void)setCellPlace:(ProfileViewCellPlace)cellPlace
{
    _cellPlace = cellPlace;
    _pBackgroundView.cellPlace = cellPlace;
}

- (void)setHideNarrow:(BOOL)hideNarrow
{
    _narrowImageView.hidden = hideNarrow;
}

- (void)setLayout:(ProfileViewCellLayout)layout
{
    _layout = layout;
    
    if(layout == ProfileViewCellLayout_InfoLeft) {
        _infoLabel.textAlignment = NSTextAlignmentLeft;
    }else {
        _infoLabel.textAlignment = NSTextAlignmentRight;
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [_mainLabel sizeToFit];
    [_infoLabel sizeToFit];
    _mainLabel.frame = CGRectMake(10.f, (CGRectGetHeight(_pBackgroundView.frame) - CGRectGetHeight(_mainLabel.frame)) * 0.5, CGRectGetWidth(_mainLabel.frame), CGRectGetHeight(_mainLabel.frame));
    
    _infoLabel.frame = CGRectMake(CGRectGetMaxX(_mainLabel.frame) + 10.0f, (CGRectGetHeight(_pBackgroundView.frame) - CGRectGetHeight(_infoLabel.frame)) * 0.5f, CGRectGetWidth(_pBackgroundView.frame) - CGRectGetMaxX(_mainLabel.frame) - 30.0f, CGRectGetHeight(_infoLabel.frame));
//    if (_layout == ProfileViewCellLayout_InfoLeft) {
//        _infoLabel.frame = CGRectMake(CGRectGetMaxX(_mainLabel.frame) + 10.f, (CGRectGetHeight(_pBackgroundView.frame) - CGRectGetHeight(_infoLabel.frame)) * 0.5, CGRectGetWidth(_infoLabel.frame), CGRectGetHeight(_infoLabel.frame));
//    }else {
//        _infoLabel.frame = CGRectMake(CGRectGetWidth(_pBackgroundView.frame) - 20.f - CGRectGetWidth(_infoLabel.frame), (CGRectGetHeight(_pBackgroundView.frame) - CGRectGetHeight(_infoLabel.frame)) * 0.5, CGRectGetWidth(_infoLabel.frame), CGRectGetHeight(_infoLabel.frame));
//    }
    
    _narrowImageView.frame = CGRectMake(CGRectGetWidth(_pBackgroundView.frame) - 13.0f, (CGRectGetHeight(_pBackgroundView.frame) - CGRectGetHeight(_narrowImageView.bounds)) * 0.5f, CGRectGetWidth(_narrowImageView.bounds), CGRectGetHeight(_narrowImageView.bounds));
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:YES];
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self.pBackgroundView setHighlighted:highlighted];
}

- (void)dealloc
{
    //KD_RELEASE_SAFELY(_mainLabel);
    //KD_RELEASE_SAFELY(_infoLabel);
    //[super dealloc];
}

@end

@implementation KDProfileCellBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _highlightedView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 0.5, 0.5)];
        _highlightedView.backgroundColor = RGBCOLOR(241.f, 242.f, 243.f);
        _highlightedView.hidden = YES;
        [self addSubview:_highlightedView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    _highlightedView.hidden = !highlighted;
}

- (void)setCellPlace:(ProfileViewCellPlace)cellPlace{
    _cellPlace = cellPlace;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    path.lineWidth = 1.f;
    
    [MESSAGE_CT_COLOR set];
    [path fill];
    
    path = [UIBezierPath bezierPath];
    UIColor *color = RGBCOLOR(221, 221, 221);
    [color set];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, CGRectGetHeight(rect))];
    [path moveToPoint:CGPointMake(CGRectGetWidth(rect), 0)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
    switch (_cellPlace) {
        case ProfileViewCellPlace_Top:
        {
            [path moveToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), 0)];
            [path moveToPoint:CGPointMake(0, CGRectGetHeight(rect))];
            [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
        }
            break;
        case ProfileViewCellPlace_Bottom:
        {
            [path moveToPoint:CGPointMake(0, CGRectGetHeight(rect))];
            [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
        }
            break;
        case ProfileViewCellPlace_Middle:
        {
            [path moveToPoint:CGPointMake(0, CGRectGetHeight(rect))];
            [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect))];
        }
            break;
    }
//    [path stroke];
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
}

@end
