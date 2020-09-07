//
//  SelectItemView.m
//  kdweibo
//
//  Created by KongBo on 15/9/2.
//  Copyright © 2015年 www.kingdee.com. All rights reserved.
//

#import "KDSelectItemView.h"

@interface KDSelectItemView()
{
    UILabel *itemTitle;
    UIImageView *icon;
    UIButton *bt;
    
    NSUInteger index;
    CGSize titleSize;
}
@end


@implementation KDSelectItemView

- (instancetype)initWithViewStyle:(KDSelectItemViewStyle)viewStyle viewTitle:(NSString *)title atIndex:(NSUInteger)index_
{

    self = [super init];
    if (self) {
        titleSize = [title sizeWithFont:FS4 constrainedToSize:CGSizeMake(MAXFLOAT, itemTitleHeight)];
     
        bt = [[UIButton alloc]initWithFrame:CGRectZero];
        bt.backgroundColor = [UIColor whiteColor];
        [bt addTarget:self action:@selector(didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
        [bt setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateNormal];
        [bt setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor3]] forState:UIControlStateHighlighted];
        [bt setTitle:title forState:UIControlStateNormal];
        [bt setTitleColor:[UIColor colorWithRGB:0xDFEBF2] forState:UIControlStateHighlighted];
        [bt.titleLabel setFont:FS4];
        [self addSubview:bt];
        
        if (viewStyle == SelectItemViewStyleNormal) {
            bt.frame = CGRectMake(0, 0, titleSize.width + 16 + 7 , itemTitleHeight);
            [bt setTitleColor:FC5 forState:UIControlStateNormal];
        
//            [bt setImage:[UIImage imageNamed:@"common_tip_arrow_left"] forState:UIControlStateNormal];
//            [bt setImage:[UIImage imageNamed:@"common_tip_arrow_left"] forState:UIControlStateHighlighted];
            bt.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
            
            bt.layer.cornerRadius = 12;
            bt.layer.borderColor = [UIColor colorWithRGB:0xDCE1E8 ].CGColor;
            bt.layer.borderWidth = 0.5;
            bt.layer.masksToBounds = YES;
            
        }
        else if (viewStyle == SelectItemViewStyleNormalLast)
        {
            bt.frame = CGRectMake(0, 0, titleSize.width , itemTitleHeight);
            [bt setTitleColor:FC1 forState:UIControlStateNormal];
            [bt setTitleColor:FC1 forState:UIControlStateHighlighted];
            [bt setBackgroundImage:[UIImage imageWithColor:[UIColor kdBackgroundColor2]] forState:UIControlStateHighlighted];
        }
        else if(viewStyle == SelectItemViewStyleNormalFirst)
        {
            bt.frame = CGRectMake(0, 0, titleSize.width + 16, itemTitleHeight);
            [bt setTitleColor:FC5 forState:UIControlStateNormal];
            bt.layer.cornerRadius = 12;
            bt.layer.borderColor = [UIColor colorWithRGB:0xDCE1E8 ].CGColor;
            bt.layer.borderWidth = 0.5;
            bt.layer.masksToBounds = YES;
        }
        
        index = index_;
    }
    return self;
}

- (CGSize)getItemViewSize
{
    return bt.frame.size;
}

- (void)didSelectedItem:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SelectItemView: didSelectedAtIndex:)]) {
        [self.delegate SelectItemView:self  didSelectedAtIndex:index];
    }
}
@end
