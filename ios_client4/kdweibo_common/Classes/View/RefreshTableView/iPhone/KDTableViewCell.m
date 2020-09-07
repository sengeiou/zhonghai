//
//  KDTrendCell.m
//  kdweibo
//
//  Created by shen kuikui on 13-11-27.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import "KDTableViewCell.h"
#import "KDStyleSyntaxSugar.h"
#import "NSNumber+KDV6.h"

//@implementation KDTableViewCell
//
//@synthesize contentEdgeInsets = contentEdgeInsets_;
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}
//
//- (void)setFrame:(CGRect)frame
//{
//    frame.origin.x += contentEdgeInsets_.left;
//    frame.origin.y += contentEdgeInsets_.top;
//    frame.size.width -= (contentEdgeInsets_.left + contentEdgeInsets_.right);
//    frame.size.height -= (contentEdgeInsets_.top + contentEdgeInsets_.bottom);
//    
//    [super setFrame:frame];
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
//
//@end



@interface KDTableViewCell ()
@property (strong, nonatomic) UIView *separatorLineView;
@property (strong, nonatomic) UIImageView *disclosureIndicatorView;
@end

@implementation KDTableViewCell

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:UITableViewCellAccessoryNone];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor kdBackgroundColor2];
        self.contentView.backgroundColor = self.backgroundColor;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bgColorView.backgroundColor = [UIColor kdBackgroundColor3];
        self.selectedBackgroundView = bgColorView;
        
        self.textLabel.textColor = FC1;
        self.textLabel.font = FS3;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.backgroundColor = self.backgroundColor;
        
        self.detailTextLabel.textColor = FC2;
        self.detailTextLabel.font = FS4;
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
        self.detailTextLabel.backgroundColor = self.backgroundColor;
        
        [self.contentView addSubview:self.separatorLineView];
        [self.contentView addSubview:self.disclosureIndicatorView];
        
        self.separatorLineInset = UIEdgeInsetsMake(0, [NSNumber kdDistance1], 0, [NSNumber kdDistance1]);
        self.separatorLineStyle = KDTableViewCellSeparatorLineNone;
        self.accessoryStyle = KDTableViewCellAccessoryStyleNone;
    }
    return self;
}

- (UIView *)separatorLineView {
    if (_separatorLineView == nil) {
        _separatorLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _separatorLineView.backgroundColor = [UIColor kdDividingLineColor];
    }
    return _separatorLineView;
}

- (UIImageView *)disclosureIndicatorView {
    if (_disclosureIndicatorView == nil) {
        _disclosureIndicatorView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _disclosureIndicatorView.image = [UIImage imageNamed:@"common_img_vector"];
    }
    return _disclosureIndicatorView;
}

- (void)setSeparatorLineStyle:(KDTableViewCellSeparatorLineStyle)separatorLineStyle {
    _separatorLineStyle = separatorLineStyle;
    [self setNeedsLayout];
}

- (void)setAccessoryStyle:(KDTableViewCellAccessoryStyle)accessoryStyle {
    _accessoryStyle = accessoryStyle;
    self.disclosureIndicatorView.hidden = (accessoryStyle == KDTableViewCellAccessoryStyleNone);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.disclosureIndicatorView.frame = CGRectMake(ScreenFullWidth - [NSNumber kdDistance1] - 7.0, (CGRectGetHeight(self.contentView.frame) - 13.0) / 2, 7, 13);
    
    CGRect imageFrame = CGRectZero;
    if (self.imageView.image) {
        imageFrame = self.imageView.frame;
        imageFrame.origin.x = [NSNumber kdDistance1];
        self.imageView.frame = imageFrame;
    }
    CGRect textLabelFrame = CGRectZero;
    if (self.textLabel.text.length > 0) {
        [self.textLabel sizeToFit];
        textLabelFrame = self.textLabel.frame;
    }
    CGRect detailTextLabelFrame = CGRectZero;
    if (self.detailTextLabel.text.length > 0) {
        [self.detailTextLabel sizeToFit];
        detailTextLabelFrame = self.detailTextLabel.frame;
    }
    
    if (!CGRectEqualToRect(textLabelFrame, CGRectZero) && !CGRectEqualToRect(detailTextLabelFrame, CGRectZero)) {
        //textLabel 和 detailTextLabel 都有
        CGFloat space = ScreenFullWidth - CGRectGetMaxX(imageFrame) - 3 * [NSNumber kdDistance1];
        if (!self.disclosureIndicatorView.hidden) {
            space -= ([NSNumber kdDistance1] + CGRectGetWidth(self.disclosureIndicatorView.frame));
        }
        //屏幕不够放
        if (space < CGRectGetWidth(textLabelFrame) + CGRectGetWidth(detailTextLabelFrame)) {
            if (space <= CGRectGetWidth(textLabelFrame)) {
                if (CGRectGetWidth(detailTextLabelFrame) < 0.4 * space) {
                    textLabelFrame.size.width = space - CGRectGetWidth(detailTextLabelFrame);
                }
                else {
                    textLabelFrame.size.width = 0.6 * space;
                    detailTextLabelFrame.size.width = 0.4 * space;
                }
            }
            else {
                detailTextLabelFrame.size.width = space - CGRectGetWidth(textLabelFrame);
            }
            textLabelFrame = CGRectMake(CGRectGetMaxX(imageFrame) + [NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(textLabelFrame)) / 2, CGRectGetWidth(textLabelFrame), CGRectGetHeight(textLabelFrame));
            detailTextLabelFrame = CGRectMake(CGRectGetMaxX(textLabelFrame) + [NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(detailTextLabelFrame)) / 2, CGRectGetWidth(detailTextLabelFrame), CGRectGetHeight(detailTextLabelFrame));
        }
        else {
            textLabelFrame = CGRectMake(CGRectGetMaxX(imageFrame) + [NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(textLabelFrame)) / 2, CGRectGetWidth(textLabelFrame), CGRectGetHeight(textLabelFrame));
            CGFloat detailTextLabelX = ScreenFullWidth - [NSNumber kdDistance1] - CGRectGetWidth(detailTextLabelFrame);
            if (!self.disclosureIndicatorView.hidden) {
                detailTextLabelX -= ([NSNumber kdDistance1] + CGRectGetWidth(self.disclosureIndicatorView.frame));
            }
            detailTextLabelFrame = CGRectMake(detailTextLabelX, (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(detailTextLabelFrame)) / 2, CGRectGetWidth(detailTextLabelFrame), CGRectGetHeight(detailTextLabelFrame));
        }
        
        self.textLabel.frame = textLabelFrame;
        self.detailTextLabel.frame = detailTextLabelFrame;
    }
    else if (!CGRectEqualToRect(textLabelFrame, CGRectZero)) {
        //只有 textLabel
        CGFloat width = ScreenFullWidth - CGRectGetMaxX(imageFrame) - 2 * [NSNumber kdDistance1];
        if (!self.disclosureIndicatorView.hidden) {
            width -= ([NSNumber kdDistance1] + CGRectGetWidth(self.disclosureIndicatorView.frame));
        }
        textLabelFrame = CGRectMake(CGRectGetMaxX(imageFrame) + [NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(textLabelFrame)) / 2, width, CGRectGetHeight(textLabelFrame));
        self.textLabel.frame = textLabelFrame;
        self.detailTextLabel.frame = detailTextLabelFrame;
    }
    else if (!CGRectEqualToRect(detailTextLabelFrame, CGRectZero)) {
        //只有 textLabel
        CGFloat width = ScreenFullWidth - CGRectGetMaxX(imageFrame) - 2 * [NSNumber kdDistance1];
        if (!self.disclosureIndicatorView.hidden) {
            width -= ([NSNumber kdDistance1] + CGRectGetWidth(self.disclosureIndicatorView.frame));
        }
        detailTextLabelFrame = CGRectMake(CGRectGetMaxX(imageFrame) + [NSNumber kdDistance1], (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(detailTextLabelFrame)) / 2, width, CGRectGetHeight(detailTextLabelFrame));
        self.textLabel.frame = textLabelFrame;
        self.detailTextLabel.frame = detailTextLabelFrame;
    }
    else {
        self.textLabel.frame = textLabelFrame;
        self.detailTextLabel.frame = detailTextLabelFrame;
    }
    
    switch (self.separatorLineStyle) {
        case KDTableViewCellSeparatorLineNone:
            self.separatorLineView.hidden = YES;
            break;
            
        case KDTableViewCellSeparatorLineTop:
            self.separatorLineView.hidden = NO;
            self.separatorLineView.frame = CGRectMake(.0, CGRectGetHeight(self.contentView.frame) - 0.5, ScreenFullWidth, 0.5);
            break;
            
        case KDTableViewCellSeparatorLineSpace:
            self.separatorLineView.hidden = NO;
//            self.separatorLineView.frame = CGRectMake([NSNumber kdDistance1], CGRectGetHeight(self.contentView.frame) - 0.5, ScreenFullWidth - [NSNumber kdDistance1], 0.5);
            self.separatorLineView.frame = CGRectMake(self.separatorLineInset.left, CGRectGetHeight(self.contentView.frame) - 0.5, ScreenFullWidth - self.separatorLineInset.left, 0.5);
            break;
            
        default:
            break;
    }
}

@end