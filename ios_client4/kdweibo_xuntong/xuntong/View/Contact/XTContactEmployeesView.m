//
//  XTContactEmployeesView.m
//  XT
//
//  Created by Gil on 13-7-17.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTContactEmployeesView.h"
//#import "KDDetail.h"

@interface XTContactEmployeesView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation XTContactEmployeesView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor kdBackgroundColor1];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(.0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        self.scrollView.scrollEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.backgroundColor = [UIColor kdBackgroundColor2];
        [self addSubview:self.scrollView];
        
        UILabel *dividingLine = [[UILabel alloc] initWithFrame:CGRectMake(.0, CGRectGetHeight(frame)- 0.5, CGRectGetWidth(frame), 0.5)];
        dividingLine.backgroundColor = [UIColor kdDividingLineColor];
        [self addSubview:dividingLine];
    }
    return self;
}

- (void)setPersonIds:(NSArray *)personIds {
    if (_personIds != personIds) {
        _personIds = personIds;
    }
    
    [self layoutEmployeesView];
}

- (void)layoutEmployeesView {
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    float space = 20;
    __block float startX = [NSNumber kdDistance1];
    __block float startY = 8.0;
    float width = 60.0f;
    float height = 80.0f;
    [self.personIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XTPersonHeaderView *personHeaderView = [[XTPersonHeaderView alloc] initWithFrame:CGRectMake(startX, startY, width, height)];
        personHeaderView.delegate = self;
        if([obj isKindOfClass:[PersonSimpleDataModel class]])
            [personHeaderView setPerson:obj];
        else
            [personHeaderView setPerson:[KDCacheHelper personForKey:obj]];
        [self.scrollView addSubview:personHeaderView];
        
        startX = startX + space + width;
    }];
    
    [self.scrollView setContentSize:CGSizeMake(startX, self.scrollView.frame.size.height)];
}

#pragma mark - XTPersonHeaderViewDelegate

- (void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person {
//    [KDDetail toDetailWithPerson:person inController:self.controller];
    if ([_delegate respondsToSelector:@selector(personHeaderClicked:person:)]) {
        [_delegate personHeaderClicked:headerView person:person];
    }
}

@end
