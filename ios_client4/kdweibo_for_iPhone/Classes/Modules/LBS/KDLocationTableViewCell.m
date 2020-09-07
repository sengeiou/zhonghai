//
//  KDLocationTableViewCell.m
//  kdweibo
//
//  Created by weihao_xu on 14-4-1.
//  Copyright (c) 2014年 www.kingdee.com. All rights reserved.
//

#import "KDLocationTableViewCell.h"

@implementation KDLocationTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.subLabel];
        [self.contentView addSubview:self.accessoryImageView];
        
        [self setUpVFLFunction];
    }
    return self;
}

- (UILabel *)label
{
    if(!_label)
    {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = FS3;
        _label.textColor = FC1;
        _label.backgroundColor = [UIColor clearColor];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _label;
}

-(UILabel *)subLabel
{
    if(!_subLabel)
    {
        _subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.font = FS6;
        _subLabel.textColor = FC2;
        _subLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _subLabel;
}

-(UIImageView *)accessoryImageView
{
    if(!_accessoryImageView)
    {
        _accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _accessoryImageView.image = [UIImage imageNamed:@"task_editor_finish"];
        _accessoryImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _accessoryImageView;
}

- (void)setUpVFLFunction
{
    NSDictionary *views = @{@"label" : self.label,
                            @"subLabel" : self.subLabel,
                            @"accessoryImageView":self.accessoryImageView};
    NSDictionary *metrics = @{@"kHMargin" : @12};
    NSArray *vfls =
    [NSArray arrayWithObjects: @"|-kHMargin-[label]-4-[accessoryImageView(22)]-12-|",
     @"V:|-9-[label(30)]",
     @"V:[subLabel(20)]-9-|",
     @"|-kHMargin-[subLabel]-38-|",
     @"V:[accessoryImageView(22)]", nil];
    
    for (NSString *vfl in vfls) {
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl
                                                                                 options:nil
                                                                                 metrics:metrics
                                                                                   views:views]];
    }
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.accessoryImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
    
    
}


@end
