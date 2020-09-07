//
//  XTSelectContactsView.m
//  XT
//
//  Created by Gil on 14-4-10.
//  Copyright (c) 2014年 Kingdee. All rights reserved.
//

#import "XTSelectContactsView.h"
#import "XTAddressBookModel.h"
#import "UIImage+XT.h"

@interface XTSelectContactsView ()

@property (nonatomic, strong) NSMutableArray *contacts;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation XTSelectContactsView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *separateLineImageView = [[UIImageView alloc] initWithImage:[XTImageUtil cellSeparateLineImage]];
        separateLineImageView.frame = CGRectMake(0.0, 0.0, frame.size.width, 1.0);
        [self addSubview:separateLineImageView];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(2.0, 3.0, 254.0, frame.size.height - 5.0)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView = scrollView;
        [self addSubview:scrollView];
        
        CGRect rect = self.scrollView.frame;
        rect.origin.y = 7.0;
        rect.size.width = 60.0;
        rect.size.height = 30.0;
        rect.origin.x = CGRectGetWidth(frame) - (CGRectGetWidth(rect) + 2.0);
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmBtn setFrame:rect];
        [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setTitleColor:BOSCOLORWITHRGBA(0xD3E4F0, 1.0) forState:UIControlStateHighlighted];
        [confirmBtn setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x0088C0, 1.0)] forState:UIControlStateHighlighted];
        [confirmBtn addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.confirmButton = confirmBtn;
        [self confirmButtonTitle];
        [self addSubview:confirmBtn];
    }
    return self;
}

#pragma mark - get

- (NSMutableArray *)contacts
{
    if (_contacts == nil) {
        _contacts = [[NSMutableArray alloc] init];
    }
    return _contacts;
}

#pragma mark - add or delete contact

- (void)addContact:(XTAddressBookModel *)contact
{
    if ([self.contacts containsObject:contact]) {
        return;
    }
    
    [self.dataSource selectContactsViewDidAddContact:contact];
    
    [self.contacts addObject:contact];
    [self layoutPersonViewWithAddContact:contact];
}

- (void)deleteContact:(XTAddressBookModel *)contact
{
    if (![self.contacts containsObject:contact]) {
        return;
    }
    
    [self.dataSource selectContactsViewDidDeleteContact:contact];
    
    int index = [self.contacts indexOfObject:contact];
    [self.contacts removeObjectAtIndex:index];
    [self layoutPersonViewWithDeleteContactIndex:index];
}

#pragma mark - btn

- (void)confirmButtonPressed:(UIButton *)btn
{
    [self.delegate selectContactViewDidConfirm:self.contacts];
}

- (void)tapHandle:(XTSelectContactButton *)btn
{
    [self deleteContact:btn.contact];
}

#pragma mark - layout

- (void)layoutPersonViewWithAddContact:(XTAddressBookModel *)contact
{
    XTSelectContactButton *nameBtn = [XTSelectContactButton buttonWithType:UIButtonTypeCustom];
    [nameBtn setFrame:CGRectMake(-57.0, 7.0, 55.0, 25.0)];
    [nameBtn addTarget:self action:@selector(tapHandle:) forControlEvents:UIControlEventTouchUpInside];
    nameBtn.contact = contact;
    [self.scrollView addSubview:nameBtn];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            UIView *subView = (UIView *)obj;
            
            CGRect rect = subView.frame;
            rect.origin.x += 57.0;
            subView.frame = rect;
            
        }];
        
    } completion:^(BOOL finished) {
        
        [self.scrollView setContentSize:CGSizeMake([self.contacts count] * 57.0 - 2.0, self.scrollView.bounds.size.height)];
        [self confirmButtonTitle];
        
    }];
}

- (void)layoutPersonViewWithDeleteContactIndex:(int)index
{
    UIView *deleteSubView = [self.scrollView.subviews objectAtIndex:index];
    [deleteSubView removeFromSuperview];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (idx < index) {
                UIView *subView = (UIView *)obj;
                
                CGRect rect = subView.frame;
                rect.origin.x -= 57.0;
                subView.frame = rect;
            }
            
        }];
        
    } completion:^(BOOL finished) {
        
        [self.scrollView setContentSize:CGSizeMake([self.contacts count] * 57.0 - 2.0, self.scrollView.bounds.size.height)];
        
        [self confirmButtonTitle];
        
    }];
}

- (void)confirmButtonTitle
{
    NSString *title = ASLocalizedString(@"Global_Sure");
    if ([self.contacts count] < 1) {
        [self.confirmButton setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x7A7A7A, 1.0)] forState:UIControlStateNormal];
        self.confirmButton.enabled = NO;
    } else {
        [self.confirmButton setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x00AAF0, 1.0)] forState:UIControlStateNormal];
        self.confirmButton.enabled = YES;
    }
    
    if ([self.contacts count] > 0) {
        title = [title stringByAppendingFormat:@" (%lu)",(unsigned long)[self.contacts count]];
    }
    [self.confirmButton setTitle:title forState:UIControlStateNormal];
}

@end

@implementation XTSelectContactButton

+ (id)buttonWithType:(UIButtonType)buttonType
{
    UIButton *btn = [super buttonWithType:UIButtonTypeCustom];
    if (btn) {
        [btn setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0xF0F0F0, 1.0)] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:BOSCOLORWITHRGBA(0x00AAF0, 1.0)] forState:UIControlStateHighlighted];
        [btn.layer setBorderWidth:1.0];
        [btn.layer setBorderColor:BOSCOLORWITHRGBA(0x06A3EC, 1.0).CGColor];
        [btn.layer setCornerRadius:3.0];
        [btn setTitleColor:BOSCOLORWITHRGBA(0x06A3EC, 1.0) forState:UIControlStateNormal];
        [btn setTitleColor:BOSCOLORWITHRGBA(0xD1EAFB, 1.0) forState:UIControlStateHighlighted];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    }
    return btn;
}

- (void)setContact:(XTAddressBookModel *)contact
{
    if (_contact != contact) {
        _contact = contact;
    }
    [self setTitle:contact.name forState:UIControlStateNormal];
}

@end
