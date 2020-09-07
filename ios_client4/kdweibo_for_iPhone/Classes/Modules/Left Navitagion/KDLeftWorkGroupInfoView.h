//
//  KDLeftWorkGroupInfoView.h
//  kdweibo
//
//  Created by bird on 13-12-13.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDUser.h"

@protocol KDLeftWorkGroupInfoViewDelegate <NSObject>
- (void)hideLeftView;
- (void)showCommunitySearchViewController:(NSArray *)communities;

- (void)createTeamButtonClicked;
- (void)joinTeamButtonClicked;
- (void)invitedTeamsClicked;
@end

@interface KDLeftWorkGroupInfoView : UIView

@property (nonatomic, weak) id<KDLeftWorkGroupInfoViewDelegate> delegate;
@property (nonatomic, retain) KDUser *user;
@property (nonatomic, retain) NSArray *groups;

- (void)sortGroups;
- (void)setInfoCount:(NSInteger)count;
@end
