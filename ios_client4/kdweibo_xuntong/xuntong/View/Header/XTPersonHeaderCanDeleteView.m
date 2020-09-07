//
//  XTPersonHeaderCanDeleteView.m
//  XT
//
//  Created by Gil on 13-7-9.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTPersonHeaderCanDeleteView.h"

@interface XTPersonHeaderCanDeleteView()

@property (nonatomic, strong) UILabel *managerLabel;
@end

@implementation XTPersonHeaderCanDeleteView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.deleteView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 15.0, -7.0, 23.0, 23.0)];
        [self.deleteView setImage:[XTImageUtil chatDetailDeletePersonImageWithState:UIControlStateNormal]];
        [self.deleteView setHighlightedImage:[XTImageUtil chatDetailDeletePersonImageWithState:UIControlStateHighlighted]];
        [self addSubview:self.deleteView];
        
        self.managerLabel = [[UILabel alloc] init];
        self.managerLabel.layer.cornerRadius = 2.5f;
        self.managerLabel.layer.masksToBounds = YES;
        self.managerLabel.font = [UIFont systemFontOfSize:7];
        self.managerLabel.text = ASLocalizedString(@"XTContactPersonViewCell_Admin");
        self.managerLabel.textColor = FC6;
        self.managerLabel.backgroundColor = FC5;
        self.managerLabel.textAlignment = NSTextAlignmentCenter;
        self.managerLabel.hidden = YES; //管理员才显
        self.managerLabel.frame = CGRectMake(CGRectGetMaxX(self.personHeaderImageView.frame) - 27, CGRectGetMaxY(self.personHeaderImageView.frame) - 9, 25, 11);
        
        [self addSubview:self.managerLabel];
        
        self.type = PersonHeaderDeleteTypeNormal;
    }
    return self;
}

- (void)setType:(PersonHeaderDeleteType)type
{
    _type = type;
    
    if (type == PersonHeaderDeleteTypeDeleted) {
        [self.deleteView setHidden:NO];
    } else {
        [self.deleteView setHidden:YES];
    }
}

- (void)setIsManager:(BOOL)isManager {
    _isManager = isManager;
    if (_isManager) {
        self.managerLabel.hidden = NO;
        self.personNameLabel.textColor = FC5;
    } else {
        self.managerLabel.hidden = YES;
        self.personNameLabel.textColor = FC1;
    }
}

- (void)tapHeaderView
{
    if (self.type == PersonHeaderDeleteTypeDeleted) {
        if (self.deleteDelegate && [self.deleteDelegate respondsToSelector:@selector(personHeaderDeleteButtonClicked:person:)]) {
            [self.deleteDelegate personHeaderDeleteButtonClicked:self person:self.person];
        }
        return;
    }
    
    [super tapHeaderView];
}

@end
