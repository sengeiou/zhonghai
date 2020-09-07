//
//  KDUserPortraitGroupView.h
//  kdweibo
//
//  Created by bird on 13-11-23.
//  Copyright (c) 2013年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDUserAvatarView.h"

@protocol KDUserPortraitDelegate <NSObject>

- (void)editorContactsWithUsers:(NSArray *)users;
@end

@interface KDUserPortraitGroupView : UIView
{
    NSMutableArray *users_;
    NSMutableArray *avatarViews_;
    NSMutableArray *avatarLabels_;
    
    UIButton *addExecuteBtn_;
    
    
    UIView *backgroundView_;
    
    NSMutableArray *selectedUsers_;
    
    BOOL editable_;
}
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) id<KDUserPortraitDelegate> delegate;

- (NSMutableArray *)getCurrentUsers;
+ (float)heightForUserPortraitGroupView:(NSArray *)users canbeEdit:(BOOL)editable;
@end
