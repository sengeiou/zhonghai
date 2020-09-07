//
//  KDSignInPointCell.m
//  kdweibo
//
//  Created by lichao_liu on 7/17/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import "KDSignInPointCell.h"

@implementation KDSignInPointCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self.contentView addSubview:self.locationLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.iconImageView];
        
        [self setUpVFLFunction];
    }
    return self;
}

- (UILabel *)locationLabel
{
    if(!_locationLabel)
    {
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationLabel.backgroundColor = [UIColor clearColor];
        _locationLabel.font = FS3;
        _locationLabel.textColor = FC1;
        _locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _locationLabel;
}

- (UILabel *)detailLabel
{
    if(!_detailLabel)
    {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = FS6;
        _detailLabel.textColor = FC2;
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _detailLabel;
}

-(UIImageView *)iconImageView
{
    if(!_iconImageView)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@""];
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _iconImageView;
}

- (void)setUpVFLFunction
{
    NSDictionary *views = @{@"locationLabel" : self.locationLabel,
                            @"detailLabel" : self.detailLabel,
                            @"iconImageView":self.iconImageView};
    
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - [NSNumber kdDistance1]*2-7-15;
    NSDictionary *metrics = @{@"kHMargin" : @12,@"kLabelWidth":@(labelWidth)};
    NSArray *vfls =
    [NSArray arrayWithObjects:
     @"V:|-9-[locationLabel(27)]-1-[detailLabel(18)]",
     @"|-38-[locationLabel]-36-|",
      @"|-38-[detailLabel]-36-|",
     @"V:[iconImageView(16)]",
     @"|-12-[iconImageView(14)]", nil];
    
     for (NSString *vfl in vfls) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                                                 options:nil
                                                                                 metrics:metrics
                                                                                   views:views]];
    }
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
}
@end
