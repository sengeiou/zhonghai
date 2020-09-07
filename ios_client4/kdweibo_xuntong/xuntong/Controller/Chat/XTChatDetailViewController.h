//
//  XTChatDetailViewController.h
//  XT
//
//  Created by Gil on 13-7-9.
//  Copyright (c) 2013年 Kingdee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTModifyGroupNameViewController.h"
#import "XTChooseContentViewController.h"

@class GroupDataModel;

@interface XTChatDetailModel : NSObject

@property (nonatomic, strong) KDTableViewCell *modelCell;
@property(nonatomic, strong) id block;

@end

@interface XTChatDetailViewController : UIViewController <XTModifyGroupNameViewControllerDelegate,XTChooseContentViewControllerDelegate>

@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, weak) XTChatViewController *chatViewController;

@property (nonatomic, strong) NSMutableArray *selectedPersons;

- (id)initWithGroup:(GroupDataModel *)group;

@end
