//
//  KDLeftMenuCell.m
//  KDLeftMenu
//
//  Created by 王 松 on 14-4-16.
//  Copyright (c) 2014年 Song.wang. All rights reserved.
//

#import "KDLeftMenuCell.h"

#import "KDLeftMenuButton.h"

const int kKDLeftMenuCellButtonPerRow = 3;

@implementation KDLeftMenuCell
{
    NSMutableArray *_buttons;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _buttons = [NSMutableArray array];// retain];
    }
    return self;
}

- (void)setModels:(NSArray *)models
{
    if (_models != models) {
        _models = [models copy];
        [self setButtonViews];
    }
}

- (void)setButtonViews
{
    [_buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [((UIButton *)obj) removeFromSuperview];
    }];
    [_buttons removeAllObjects];
    int colnums = (int)MIN(kKDLeftMenuCellButtonPerRow, _models.count);
    for (NSInteger i = 0; i < colnums; i++) {
        KDLeftMenuButton *button = [KDLeftMenuButton buttonWithModel:_models[i]];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x999da5) forState:UIControlStateHighlighted];
        button.tag = i;
        [_buttons addObject:button];
        [self.contentView addSubview:button];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat centerY = CGRectGetMidY(self.bounds);
//    CGFloat colnumWidth = CGRectGetWidth(self.frame) / kKDLeftMenuCellButtonPerRow;
    [_buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KDLeftMenuButton *button = (KDLeftMenuButton *)obj;
        CGFloat width = self.contentView.frame.size.width;
        CGFloat centerX = width / 2;
        CGFloat constant = 18;
        if ([[BOSConfig sharedConfig].user.userId isEqualToString:[BOSConfig sharedConfig].mainUser.userId]) {
            constant = 22;
        }
        if (isAboveiPhone6) {
            constant = 22;
        }
        if (isiPhone6Plus) {
            constant = 22;
        }
        switch (idx) {
            case 0:
                centerX = (width) / 4 - constant;
                break;
            case 2:
                centerX = (width) / 4 * 3 + constant;
                break;
            case 1:
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
           button.center = CGPointMake(centerX, centerY);
        });
    }];
}

- (void)buttonTapped:(KDLeftMenuButton *)button
{
    if ([_delegate respondsToSelector:@selector(leftMenuCell:sender:atIndex:)]) {
        [_delegate leftMenuCell:self sender:button atIndex:button.tag];
    }
}

- (void)dealloc
{
//    [_models release];
//    [_buttons release];
    //[super dealloc];
}

@end
