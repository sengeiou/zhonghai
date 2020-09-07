//
//  UITableViewCell+Check.m
//  kdweibo
//
//  Created by fang.jiaxin on 16/12/15.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

#import "UITableViewCell+Check.h"
#import <objc/runtime.h>
#import "UITableView+Check.h"


@implementation UITableViewCell (Check)

-(BOOL)showCheck
{
    return [objc_getAssociatedObject(self, @selector(showCheck)) boolValue];
}

-(void)setShowCheck:(BOOL)showCheck
{
    if(showCheck == self.showCheck)
        return;
    
    objc_setAssociatedObject(self, @selector(showCheck), [NSNumber numberWithBool:showCheck], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if(showCheck)
    {
        if(!self.checkBtn)
        {
            UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
            maskView.tag = 987654;
            maskView.userInteractionEnabled = YES;
            [self addSubview:maskView];
            
            UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            checkBtn.frame = CGRectMake(10, 0, 25, 25);
            [checkBtn setImage:[UIImage imageNamed:@"choose-circle-o"] forState:UIControlStateNormal];
            [checkBtn setImage:[UIImage imageNamed:@"choose_circle_n"] forState:UIControlStateSelected];
            [checkBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:checkBtn];
            
            self.checkBtn = checkBtn;
            self.allowCheck = self.allowCheck;
            self.isCheck = self.isCheck;
        }

        
        self.checkBtn.hidden = NO;
        
        CGRect bounds = self.contentView.bounds;
        bounds.origin.x = -45;
        self.contentView.bounds = bounds;
        self.contentView.userInteractionEnabled = NO;
    }
    else
    {
        UIView *maskView = [self viewWithTag:987654];
        maskView.userInteractionEnabled = NO;
        
        self.checkBtn.hidden = YES;
        
        CGRect bounds = self.contentView.bounds;
        bounds.origin.x = 0;
        self.contentView.bounds = bounds;
        self.contentView.userInteractionEnabled = YES;
    }
}


-(BOOL)allowCheck
{
    return [objc_getAssociatedObject(self, @selector(allowCheck)) boolValue];
}

-(void)setAllowCheck:(BOOL)allowCheck
{
    objc_setAssociatedObject(self, @selector(allowCheck), [NSNumber numberWithBool:allowCheck], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.checkBtn.userInteractionEnabled = allowCheck;
}


-(BOOL)isCheck
{
    return [objc_getAssociatedObject(self, @selector(isCheck)) boolValue];
}

-(void)setIsCheck:(BOOL)isCheck
{
    objc_setAssociatedObject(self, @selector(isCheck), [NSNumber numberWithBool:isCheck], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    
    if(self.parentTableView && self.cellTag)
    {
        //临时存起来
        [self.parentTableView.checkStateDic setObject:[NSNumber numberWithBool:isCheck] forKey:self.cellTag];
    }
    
    self.checkBtn.selected = isCheck;
    self.checkBtn.center = CGPointMake(self.checkBtn.center.x,self.frame.size.height/2);
}

-(UIButton *)checkBtn
{
    return objc_getAssociatedObject(self, @selector(checkBtn));
}

-(void)setCheckBtn:(UIButton *)checkBtn
{
    objc_setAssociatedObject(self, @selector(checkBtn), checkBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)checkBtnClick:(UIButton *)sender
{
    self.isCheck = !self.isCheck;
    if(self.parentTableView.checkBlock)
        self.parentTableView.checkBlock(self);
}

-(id)cellTag
{
    return objc_getAssociatedObject(self, @selector(cellTag));
}

-(void)setCellTag:(id<NSCopying>)cellTag
{
    objc_setAssociatedObject(self, @selector(cellTag), cellTag, OBJC_ASSOCIATION_COPY);
    
    
    if(self.parentTableView && self.cellTag)
    {
        //以cellTag为key给每行check赋值
        id checkState = [self.parentTableView.checkStateDic objectForKey:cellTag];
        self.isCheck = [checkState boolValue];
    }
    
    self.showCheck = self.parentTableView.showCheck;
}

-(UITableView *)parentTableView
{
    return objc_getAssociatedObject(self, @selector(parentTableView));
}

-(void)setParentTableView:(UITableView *)parentTableView
{
    objc_setAssociatedObject(self, @selector(parentTableView), parentTableView, OBJC_ASSOCIATION_ASSIGN);
}

@end
