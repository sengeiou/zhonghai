//
//  XTPersonDetailCell.m
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTPersonDetailCell.h"
#import "UIImage+XT.h"

@interface XTPersonDetailCell ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *contactTextLabel;
@property (nonatomic, strong) UIImageView *separateLineImageView;
@end

@implementation XTPersonDetailCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.iconImageView = iconImageView;
        [self.contentView addSubview:iconImageView];
        
        UILabel *contactTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        contactTextLabel.textColor = BOSCOLORWITHRGBA(0x7A7A7A, 1.0);
        contactTextLabel.backgroundColor = [UIColor clearColor];
        self.contactTextLabel = contactTextLabel;
        [self.contentView addSubview:contactTextLabel];
        
        UIImageView *separateLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0)]];
        separateLineImageView.frame = CGRectMake(15.0, 0.0, ScreenFullWidth - 30.0, 1.0);
        self.separateLineImageView = separateLineImageView;
        [self.contentView addSubview:separateLineImageView];
    }
    return self;
}

#pragma mark - set

- (void)setContact:(ContactDataModel *)contact
{
    if (_contact != contact) {
        _contact = contact;
    }
    
    [self setNeedsLayout];
}

- (void)setButtons:(NSArray *)buttons
{
    if (_buttons != buttons) {
        _buttons = buttons;
        
        [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UIButton class]]) {
                [obj removeFromSuperview];
            }
        }];
        
        [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx == 1) {
                *stop = YES;
            }
            [self.contentView addSubview:obj];
        }];
    }
    
    [self setNeedsLayout];
}

#pragma mark - super

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    if (self.buttons != nil) {
        self.iconImageView.hidden = YES;
        self.contactTextLabel.hidden = YES;
        self.separateLineImageView.hidden = YES;
        
        [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx == 1) {
                *stop = YES;
            }
            UIButton *btn = (UIButton *)obj;
            if (idx == 0){
                btn.frame = CGRectMake(15.0, CGRectGetHeight(bounds) - CGRectGetHeight(btn.frame), CGRectGetWidth(btn.frame), CGRectGetHeight(btn.frame));
            } else {
                btn.frame = CGRectMake(ScreenFullWidth - CGRectGetWidth(btn.frame) - 15.0, CGRectGetHeight(bounds) - CGRectGetHeight(btn.frame), CGRectGetWidth(btn.frame), CGRectGetHeight(btn.frame));
            }
         }];
        
    } else {
        self.iconImageView.hidden = NO;
        self.contactTextLabel.hidden = NO;
        self.separateLineImageView.hidden = NO;
        if (self.contact.ctype == ContactEmail) {
            self.iconImageView.image = [XTImageUtil personDetailMailImage];
            self.iconImageView.frame = CGRectMake(15.0, CGRectGetHeight(bounds) - 3.0 - 13.0, 20.0, 13.0);
            
            self.contactTextLabel.font = [UIFont systemFontOfSize:16.0];
            CGRect rect = self.iconImageView.frame;
            rect.origin.x += (CGRectGetWidth(rect) + 10.0);
            rect.size.width = CGRectGetWidth(bounds) - rect.origin.x - 15.0;
            rect.size.height = 18.0;
            rect.origin.y = CGRectGetHeight(bounds) - 3.0 - rect.size.height;
            self.contactTextLabel.frame = rect;
        }else if (!self.buttons && !self.contact)
        {
            self.iconImageView.hidden = YES;
            self.contactTextLabel.hidden = YES;
            self.separateLineImageView.hidden = YES;
        }
        else {
            self.iconImageView.image = [XTImageUtil personDetailPhoneImage];
            self.iconImageView.frame = CGRectMake(15.0, CGRectGetHeight(bounds) - 3.0 - 20.0, 20.0, 20.0);
            
            self.contactTextLabel.font = [UIFont systemFontOfSize:18.0];
            CGRect rect = self.iconImageView.frame;
            rect.origin.x += (CGRectGetWidth(rect) + 10.0);
            rect.size.width = CGRectGetWidth(bounds) - rect.origin.x - 15.0;
            rect.size.height = 18.0;
            rect.origin.y = CGRectGetHeight(bounds) - 3.0 - rect.size.height;
            self.contactTextLabel.frame = rect;
        }
        self.contactTextLabel.text = self.contact.cvalue;
        self.separateLineImageView.frame = CGRectMake(15.0, CGRectGetHeight(bounds) - 1.0, ScreenFullWidth - 30.0, 1.0);
    }
    
    [super layoutSubviews];
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    if (selectionStyle != UITableViewCellSelectionStyleNone) {
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = BOSCOLORWITHRGBA(0xE5E5E5, 1.0);
        self.selectedBackgroundView = bgColorView;
        
    } else {
        
        self.selectedBackgroundView = nil;
        
    }
    
    [super setSelectionStyle:selectionStyle];
}

@end
