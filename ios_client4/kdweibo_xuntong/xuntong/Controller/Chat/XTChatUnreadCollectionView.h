//
//  XTChatUnreadCollectionView.h
//  kdweibo
//
//  Copyright (c) 2015年 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupDataModel.h"
@interface XTChatUnreadCollectionView : UIViewController
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) GroupDataModel *group;
@property (nonatomic, assign) BOOL bGrayRemindeButton; //KSSP-26644 放开限制
- (void)setReadArray:(NSArray *)readArray UnreadArray:(NSArray *)unreadArray;
@end
