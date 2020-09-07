//
//  XTGroupParticipantsView.m
//  XT
//
//  Created by Gil on 13-7-9.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import "XTGroupParticipantsView.h"
#import "GroupDataModel.h"
#import "XTPersonDetailViewController.h"
#import "BOSConfig.h"
#import "XTDataBaseDao.h"

#define TOP_LINE_TAG      101
#define LEFT_LINE_TAG     102
#define BOTTOM_LINE_TAG   103
#define RIGH_LINE_TAG     104

NS_INLINE UIView * borderView(NSInteger tag) {
    UIView *v = [[UIView alloc] init];
    v.tag = tag;
    v.backgroundColor = RGBCOLOR(0xdd, 0xdd, 0xdd);
    
    return v;
}

@interface XTGroupParticipantsView ()
@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, assign) BOOL deleteButtonHidden;
@end

@implementation XTGroupParticipantsView


- (id)initWithGroup:(GroupDataModel *)group
{
    self = [super initWithFrame:CGRectMake(0, 0, ScreenFullWidth, 0.0)];
    if (self) {
        // Initialization code
        self.backgroundColor = self.backgroundColor = [UIColor kdBackgroundColor2];
        
        self.group = group;
        self.deleteButtonHidden = YES;
        
        [self layoutParticipantsView];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:CGRectMake(0, 0, ScreenFullWidth, frame.size.height)];
}

- (void)layoutParticipantsView
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    //将自己添加进去
    PersonSimpleDataModel *currentUser =[[XTDataBaseDao sharedDatabaseDaoInstance] queryPersonWithPersonId:[BOSConfig sharedConfig].user.userId];
    NSMutableArray *tempParticipant = [[NSMutableArray alloc] initWithArray:self.group.participant];
    if(currentUser)
    {
        if (currentUser.status != 3) {
            currentUser.status = 3;
            [[XTDataBaseDao sharedDatabaseDaoInstance] insertPersonSimple:currentUser];
        }
        if(![tempParticipant containsObject:currentUser])
            [tempParticipant insertObject:currentUser atIndex:0];
    }
    
    //计算可以放多少个人员
    NSUInteger participantNum = 12;
    if (self.group.groupType != GroupTypePublic)
    {
        //空出一个位置给＋号
        participantNum--;
        if (self.group.groupType == GroupTypeMany)
        {
            // -  管理员才能看到减号，//空出一个位置给－号
            if ([self.group isManager])
            {
                participantNum--;
            }
        }
    }
    //加上＋－号，总数不得超过12个
    if(tempParticipant.count>participantNum)
        [tempParticipant removeObjectsInRange:NSMakeRange(participantNum, tempParticipant.count-participantNum)];
    
    double headerWidth = 55;//(self.frame.size.width-space*3-offset*2)/4;
    double headerHeight = headerWidth*4/3;
    double space = (self.frame.size.width-headerWidth*4)/5;
    double offset = space;
    __block double startX = offset;
    __block double startY = offset-10;
    [tempParticipant enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (startX > self.frame.size.width - offset - headerWidth) {
            startX = offset;
            startY = startY + space + headerHeight;
        }
        
        PersonSimpleDataModel *person = (PersonSimpleDataModel *)obj;
        XTPersonHeaderCanDeleteView *personHeaderView = [[XTPersonHeaderCanDeleteView alloc] initWithFrame:CGRectMake(startX, startY, headerWidth, headerHeight)];
        personHeaderView.personDetail = YES;
        [personHeaderView setPerson:person];
        personHeaderView.isManager = [self.group.managerIds containsObject:person.personId];
        personHeaderView.type = self.deleteButtonHidden ? PersonHeaderDeleteTypeNormal : PersonHeaderDeleteTypeDeleted;
        personHeaderView.tag = 1;
        //不能删除自己
        if([person.personId isEqualToString:currentUser.personId])
        {
            personHeaderView.tag = 2;
            personHeaderView.type = PersonHeaderDeleteTypeNormal;
        }
        personHeaderView.deleteDelegate = self;
        personHeaderView.delegate = self;
        [self addSubview:personHeaderView];
        
        startX = startX + space + headerWidth;
    }];
    
    if (self.group.groupType != GroupTypePublic) {
        // +
        if (startX > self.frame.size.width - offset - headerWidth) {
            startX = offset;
            startY = startY + space + headerHeight;
        }
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setFrame:CGRectMake(startX, startY, headerWidth, headerWidth)];
        [addBtn setBackgroundImage:[XTImageUtil chatDetailAddImageWithState:UIControlStateNormal] forState:UIControlStateNormal];
        [addBtn setBackgroundImage:[XTImageUtil chatDetailAddImageWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [addBtn addTarget:self action:@selector(addPerson:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.layer.cornerRadius =  8;
        addBtn.layer.masksToBounds = YES;
        [self addSubview:addBtn];
        
        startX = startX + space + headerWidth;
        
        if (self.group.groupType == GroupTypeMany)
        {
            // -  管理员才能看到减号
            if ([self.group isManager])
            {
                if (startX > self.frame.size.width - offset - headerWidth)
                {
                    startX = offset;
                    startY = startY + space + headerHeight;
                }
                
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [deleteBtn setFrame:CGRectMake(startX, startY, headerWidth, headerWidth)];
                [deleteBtn setBackgroundImage:[XTImageUtil chatDetailDeleteImageWithState:UIControlStateNormal] forState:UIControlStateNormal];
                [deleteBtn setBackgroundImage:[XTImageUtil chatDetailDeleteImageWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
                deleteBtn.layer.cornerRadius =  8;
                deleteBtn.layer.masksToBounds = YES;
                deleteBtn.hidden = NO;
                [deleteBtn addTarget:self action:@selector(deletePerson:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:deleteBtn];
                
            }
            
        }
    }
    
    /**/
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, startY + headerHeight + 21.0);
    
    //set up border
    [self addSubview:borderView(TOP_LINE_TAG)];
    [self addSubview:borderView(LEFT_LINE_TAG)];
    [self addSubview:borderView(BOTTOM_LINE_TAG)];
    [self addSubview:borderView(RIGH_LINE_TAG)];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float offset = 0.5f;
    UIView *top = [self viewWithTag:TOP_LINE_TAG];
    if(top) {
        top.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), offset);
    }
    
    UIView *left = [self viewWithTag:LEFT_LINE_TAG];
    if(left) {
        left.frame = CGRectMake(0, 0, offset, CGRectGetHeight(self.bounds));
    }
    
    UIView *bottom = [self viewWithTag:BOTTOM_LINE_TAG];
    bottom.backgroundColor = [UIColor kdTableViewBackgroundColor];
    
    if(bottom) {
        bottom.frame = CGRectMake(12, CGRectGetHeight(self.bounds) - offset, CGRectGetWidth(self.bounds), offset);
    }
    
    UIView *right = [self viewWithTag:RIGH_LINE_TAG];
    if(right) {
        right.frame = CGRectMake(CGRectGetWidth(self.bounds) - offset, 0.0f, offset, CGRectGetHeight(self.bounds));
    }

}

- (void)addPerson:(UIButton *)btn
{
    [self.delegate groupParticipantsViewAddPerson];
}

- (void)deletePerson:(UIButton *)btn
{
//    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[XTPersonHeaderCanDeleteView class]]) {
//            XTPersonHeaderCanDeleteView *headerView = (XTPersonHeaderCanDeleteView *)obj;
//            if (headerView.type == PersonHeaderDeleteTypeNormal && headerView.tag !=2) {
//                headerView.type = PersonHeaderDeleteTypeDeleted;
//                self.deleteButtonHidden = NO;
//            } else {
//                headerView.type = PersonHeaderDeleteTypeNormal;
//                self.deleteButtonHidden = YES;
//            }
//        }
//    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(groupParticipantsViewDeletePerson)]) {
        [self.delegate groupParticipantsViewDeletePerson];
    }
    
}

#pragma mark - XTPersonHeaderCanDeleteViewDelegate

- (void)personHeaderDeleteButtonClicked:(XTPersonHeaderCanDeleteView *)headerView person:(PersonSimpleDataModel *)person
{
    [self.delegate groupParticipantsViewDeletePerson:person];
}

#pragma mark - XTPersonHeaderViewDelegate

- (void)personHeaderClicked:(XTPersonHeaderView *)headerView person:(PersonSimpleDataModel *)person
{
    if ([person isPublicAccount]) {
        XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:YES];
        personDetail.hidesBottomBarWhenPushed = YES;
        [self.controller.navigationController pushViewController:personDetail animated:YES];
    }else
    {
        XTPersonDetailViewController *personDetail = [[XTPersonDetailViewController alloc] initWithSimplePerson:person with:NO]; 
        personDetail.hidesBottomBarWhenPushed = YES;
        [self.controller.navigationController pushViewController:personDetail animated:YES];
    }
}



@end
