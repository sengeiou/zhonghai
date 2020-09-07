//
//  GroupHeadView.m
//  ContactsLite
//
//  Created by kingdee eas on 13-2-21.
//  Copyright (c) 2013年 kingdee eas. All rights reserved.
//

#import "XTGroupHeaderImageView.h"
#import "PersonSimpleDataModel.h"
#import "GroupDataModel.h"
#import "XTPersonHeaderImageView.h"

#define Space_SubViews 2.0
#define Tag_SubViews 99999

@implementation XTGroupHeaderImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 6.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor clearColor];//BOSCOLORWITHRGBA(0xD9D7D7, 1.0);
        /*  http://192.168.0.22/jira/browse/KSSP-15351
         时间线上去掉头像点击打开详情，改为进入会话。
        self.userInteractionEnabled = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toDetail)];
        [self addGestureRecognizer:tap];
         */
    }
    return self;
}

- (void)setGroup:(GroupDataModel *)group
{
    if (_group != group) {
        _group = group;
        
        [self layoutPersonHeaderImageViews];
    }
    
//    if (group.groupType != GroupTypeMany) {
//        self.userInteractionEnabled = YES;
//    } else {
//        self.userInteractionEnabled = NO;
//    }
}

- (void)layoutPersonHeaderImageViews
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *subView = (UIView *)obj;
        if (subView.tag == Tag_SubViews) {
            [subView removeFromSuperview];
        }
    }];
    
    if (self.group.groupType == GroupTypePublic || self.group.groupType == GroupTypeDouble) {
        
        PersonSimpleDataModel *person = nil;
        if ([self.group.participant count] > 0) {
            person = [self.group.participant firstObject];
        }
        else {
            person = [self.group firstParticipant];
        }
        if (person != nil) {
            if ((person.photoUrl == nil || [person.photoUrl isEqualToString:@""])&& (self.group.headerUrl != nil && self.group.headerUrl.length >0 )  ) {
                if(![self.group.headerUrl containsString:@"id=null"])
                    person.photoUrl = self.group.headerUrl;
            }
            XTPersonHeaderImageView *headerImageView = [[XTPersonHeaderImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
            headerImageView.tag = Tag_SubViews;
            [headerImageView cancelCurrentImageLoad];
            headerImageView.person = person;
            [self insertSubview:headerImageView atIndex:0];
            return;
        }
      
    }
    
    if (self.group.headerUrl.length > 0) {
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:self.bounds];
        headerView.tag = Tag_SubViews;
        headerView.backgroundColor = [UIColor clearColor];
        [headerView cancelCurrentImageLoad];
        [headerView setImageWithURL:[NSURL URLWithString:self.group.headerUrl] placeholderImage:[UIImage imageNamed:@"group_default_portrait"]];
        headerView.clipsToBounds = YES;
        headerView.layer.cornerRadius = (ImageViewCornerRadius==-1?(CGRectGetHeight(headerView.frame)/2):ImageViewCornerRadius);
        headerView.layer.shouldRasterize = YES;
        headerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self insertSubview:headerView atIndex:0];
        return;
    }
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:self.bounds];
    headerView.tag = Tag_SubViews;
    headerView.image = [UIImage imageNamed:@"group_default_portrait"];
    [self insertSubview:headerView atIndex:0];
}

/*   http://192.168.0.22/jira/browse/KSSP-15351
     时间线上去掉头像点击打开详情，改为进入会话。
-(void)toDetail
{
    if (self.group.groupType == GroupTypeMany) {
        return;
    }
    
    if ([self.group.participant count] > 0) {
        PersonSimpleDataModel *person = [self.group.participant objectAtIndex:0];
        //帐号已注销
        if (![person accountAvailable]) {
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(groupHeaderClicked:person:)]) {
            [self.delegate groupHeaderClicked:self person:person];
        }
    }
}
 */

@end
