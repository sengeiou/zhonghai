//
//  XTPersonsCollectionViewCell.m
//  kdweibo
//
//  Created by lichao_liu on 15/3/10.
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import "XTPersonsCollectionViewCell.h"
@interface XTPersonsCollectionViewCell()
@property (nonatomic, strong)XTPersonHeaderCanDeleteView *personHeaderView;
@end

@implementation XTPersonsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.personHeaderView = [[XTPersonHeaderCanDeleteView alloc] initWithFrame:CGRectMake(0, 0, 44, 68)];
        self.personHeaderView.type =  PersonHeaderDeleteTypeNormal;
        [self.contentView addSubview:self.personHeaderView];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setDeleteDelegate:(id<XTPersonHeaderViewDelegate>)deleteDelegate
{
    _deleteDelegate = deleteDelegate;
    self.personHeaderView.delegate = deleteDelegate;
}

- (void)setPersonSimpleModel:(PersonSimpleDataModel *)personSimpleModel
{
    _personSimpleModel = personSimpleModel;
    [self.personHeaderView setPerson:personSimpleModel];
}

@end
