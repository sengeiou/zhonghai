//
//  KDChatPersonCell.h
//  kdweibo
//
//  Created by lichao_liu on 7/22/15.
//  Copyright (c) 2015 www.kingdee.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSubscribeCell.h"
@interface KDChatPersonCell : KDSubscribeCell
@property (nonatomic, assign) BOOL isShowDelete;
@property (nonatomic, assign) BOOL shouldSignExternalPerson;
@end
