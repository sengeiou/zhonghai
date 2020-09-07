//
//  KDMoreSearchCell.m
//  kdweibo
//
//  Created by sevli on 15/8/5.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "KDMoreSearchCell.h"

@interface KDMoreSearchCell()
@property (nonatomic, strong)UILabel *moreLabel;


@end


@implementation KDMoreSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bgColorView.backgroundColor = [UIColor kdBackgroundColor3];
        self.selectedBackgroundView = bgColorView;
        
        self.moreLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.moreLabel];
        
        self.separatorLineStyle = KDTableViewCellSeparatorLineNone;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.moreLabel.frame = CGRectMake(0, 0, ScreenFullWidth, 44.0f);
    self.moreLabel.text = ASLocalizedString(@"XTOrganizationViewController_More");
    self.moreLabel.textAlignment = NSTextAlignmentCenter;
    self.moreLabel.backgroundColor = [UIColor clearColor];
    self.moreLabel.textColor = FC1;
    self.moreLabel.font = FS7;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
