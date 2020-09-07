//
//  KDOrganiztionCell.m
//  kdweibo
//
//  Created by KongBo on 15/9/6.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDOrganiztionCell.h"
#import "UIButton+KDV6.h"
@interface KDOrganiztionCell ()
{
    UIButton *editeBtn;
}
@end

@implementation KDOrganiztionCell

- (void)setEditingShowSytle:(BOOL)isEditing
{
    if (isEditing) {
        if (!editeBtn) {
            editeBtn = [UIButton whiteBtnWithTitle:ASLocalizedString(@"编辑")];
            editeBtn.frame = CGRectMake(ScreenFullWidth - editeBtn.frame.size.width - 12, (self.frame.size.height - editeBtn.frame.size.height )/2, editeBtn.frame.size.width, editeBtn.frame.size.height);
            
            [editeBtn addTarget:self action:@selector(editBtnAction:)forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:editeBtn];
        }
        editeBtn.hidden = NO;
        self.disclosureIndicatorView.hidden = YES;
    }
    else
    {
        editeBtn.hidden = YES;
        if (self.accessoryStyle == KDTableViewCellAccessoryStyleNone) {
            self.disclosureIndicatorView.hidden = YES;
        }
        else if (self.accessoryStyle == KDTableViewCellAccessoryStyleDisclosureIndicator)
            self.disclosureIndicatorView.hidden = NO;
    }
}

- (void)editBtnAction:(id)sender
{
    if (self.editeDelegate && [self.editeDelegate respondsToSelector:@selector(didEditingTableViewCell:)]) {
        [self.editeDelegate didEditingTableViewCell:self];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(self.imageView.image)
    {
        CGRect frame = self.imageView.frame;
        frame.size = CGSizeMake(15, 15);
        self.imageView.frame = frame;
        self.imageView.center = CGPointMake(self.imageView.center.x, self.frame.size.height/2);
    }
}

@end
