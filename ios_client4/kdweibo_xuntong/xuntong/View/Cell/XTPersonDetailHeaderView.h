//
//  XTPersonDetailHeaderView.h
//  XT
//
//  Created by Gil on 13-7-24.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XTPersonDetailHeaderViewDelegate;
@class PersonDataModel;
@interface XTPersonDetailHeaderView : UIView
{
    BOOL isPublic;
}
@property (nonatomic, strong) PersonDataModel *person;
@property (nonatomic, weak)  id<XTPersonDetailHeaderViewDelegate> delegate;
//@property (nonatomic, assign, setter = setFollowing:) BOOL isFollowing;
//@property (nonatomic, readonly) UIButton *followButton;

//@property (nonatomic) NSInteger followCount;
//@property (nonatomic) NSInteger fansCount;
//@property (nonatomic) NSInteger statusCount;
//
//- (void)setFollowCount:(NSInteger)followCount FansCount:(NSInteger)fansCount StatusesCount:(NSInteger)sc;
//
//- (void)setShowFollowActivityView:(BOOL)isShown;

- (id)initWithPerson:(PersonDataModel *)person withpublic:(BOOL)ispublic;

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;

@end

@protocol XTPersonDetailHeaderViewDelegate <NSObject>

//- (void)personDetailHeaderViewFavButtonPressed:(XTPersonDetailHeaderView *)headerView;
//- (void)personDetailHeaderViewDepartmentButtonPressed:(XTPersonDetailHeaderView *)headerView;
- (void)personDetailHeaderViewFavoritedButtonPressed:(XTPersonDetailHeaderView *)headerView;
- (void)personDetailHeaderViewAttentionButtonPressed:(XTPersonDetailHeaderView *)headerView;

- (void)personDetailHeaderViewFollowButtonPressed:(XTPersonDetailHeaderView *)headerView;

- (void)personDetailHeaderViewSendCarteButtonPressed:(XTPersonDetailHeaderView *)headerView;

- (void)personDetailHeaderViewSendMessageButtonPressed:(XTPersonDetailHeaderView *)headerView;

- (void)personDetailHeaderViewFriendsButtonPressed:(XTPersonDetailHeaderView *)headerView;
- (void)personDetailHeaderViewFansButtonPressed:(XTPersonDetailHeaderView *)headerView;
- (void)personDetailHeaderViewStatusButtonPressed:(XTPersonDetailHeaderView *)headerView;

@end
